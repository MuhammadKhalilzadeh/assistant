/**
 * Auto-Action Engine: executes approved actions on the user's behalf
 * based on their configured autonomy level.
 *
 * Autonomy levels:
 *   suggest_only  - Queue insight card in app, no execution
 *   ask_first     - Send notification, user must approve
 *   auto_with_notify - Execute + notify + enable undo
 *   full_auto     - Execute silently (only for low-risk: reminders/nudges)
 *
 * Safety rules:
 *   - Goal changes: never full_auto, always at least ask_first
 *   - Data creation: max auto_with_notify
 *   - Data deletion: always ask_first
 *   - Max 3 auto-actions per day
 */

import pool from '../../config/database';
import { notificationService } from '../notification/notification.service';
import { logger } from '../../config/logger';

export type AutonomyLevel = 'suggest_only' | 'ask_first' | 'auto_with_notify' | 'full_auto';

export interface AutoAction {
  id: string;
  userId: string;
  actionType: string;
  payload: Record<string, unknown>;
  reason: string;
  autonomyLevel: AutonomyLevel;
  status: 'pending_approval' | 'executed' | 'rejected' | 'undone';
  createdAt: Date;
  executedAt: Date | null;
}

/** Maximum risk level allowed per autonomy level */
const MAX_RISK: Record<string, AutonomyLevel> = {
  goal_change: 'ask_first',      // Never auto for goals
  data_create: 'auto_with_notify',
  data_delete: 'ask_first',      // Always ask for deletions
  reminder: 'full_auto',
  navigation: 'full_auto',
};

export const autoActionService = {
  async ensureTable(): Promise<void> {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS auto_action_log (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        action_type VARCHAR(50) NOT NULL,
        payload JSONB NOT NULL DEFAULT '{}',
        reason TEXT NOT NULL,
        autonomy_level VARCHAR(20) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending_approval',
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        executed_at TIMESTAMPTZ
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auto_action_log_user
      ON auto_action_log(user_id, status, created_at)
    `);
  },

  /**
   * Get the user's configured autonomy level (defaults to suggest_only).
   */
  async getUserAutonomyLevel(userId: string): Promise<AutonomyLevel> {
    try {
      const result = await pool.query<{ autonomy_level: string }>(
        `SELECT autonomy_level FROM user_agent_settings WHERE user_id = $1`,
        [userId]
      );
      return (result.rows[0]?.autonomy_level as AutonomyLevel) || 'suggest_only';
    } catch {
      return 'suggest_only';
    }
  },

  /**
   * Propose an auto-action. Based on autonomy level, it may:
   * - Queue for approval (ask_first, suggest_only)
   * - Execute immediately (auto_with_notify, full_auto)
   */
  async propose(
    userId: string,
    actionType: string,
    riskCategory: string,
    payload: Record<string, unknown>,
    reason: string,
  ): Promise<AutoAction | null> {
    // Check daily limit
    const todayCount = await this.getTodayActionCount(userId);
    if (todayCount >= 3) {
      logger.debug({ userId }, 'Daily auto-action limit reached');
      return null;
    }

    const userLevel = await this.getUserAutonomyLevel(userId);
    const maxAllowed = MAX_RISK[riskCategory] || 'ask_first';

    // Determine effective level (user level capped by max risk)
    const levelOrder: AutonomyLevel[] = ['suggest_only', 'ask_first', 'auto_with_notify', 'full_auto'];
    const userIdx = levelOrder.indexOf(userLevel);
    const maxIdx = levelOrder.indexOf(maxAllowed);
    const effectiveLevel = levelOrder[Math.min(userIdx, maxIdx)];

    // Log the action
    const result = await pool.query<{
      id: string;
      user_id: string;
      action_type: string;
      payload: Record<string, unknown>;
      reason: string;
      autonomy_level: string;
      status: string;
      created_at: Date;
      executed_at: Date | null;
    }>(
      `INSERT INTO auto_action_log (user_id, action_type, payload, reason, autonomy_level, status)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        userId,
        actionType,
        JSON.stringify(payload),
        reason,
        effectiveLevel,
        effectiveLevel === 'auto_with_notify' || effectiveLevel === 'full_auto'
          ? 'executed'
          : 'pending_approval',
      ]
    );

    const row = result.rows[0];
    const action: AutoAction = {
      id: row.id,
      userId: row.user_id,
      actionType: row.action_type,
      payload: row.payload,
      reason: row.reason,
      autonomyLevel: row.autonomy_level as AutonomyLevel,
      status: row.status as AutoAction['status'],
      createdAt: row.created_at,
      executedAt: row.executed_at,
    };

    // Notify if auto-executed
    if (action.status === 'executed' && effectiveLevel === 'auto_with_notify') {
      await notificationService.send({
        userId,
        title: `Jarvis: ${actionType}`,
        body: `${reason}\n\nThis was done automatically. You can undo this in the app.`,
        category: 'insight',
      });
    }

    return action;
  },

  /**
   * Get today's auto-action count.
   */
  async getTodayActionCount(userId: string): Promise<number> {
    try {
      const result = await pool.query<{ count: string }>(
        `SELECT COUNT(*) as count FROM auto_action_log
         WHERE user_id = $1 AND created_at >= CURRENT_DATE`,
        [userId]
      );
      return parseInt(result.rows[0]?.count ?? '0');
    } catch {
      return 0;
    }
  },

  /**
   * Get pending actions for user approval.
   */
  async getPendingActions(userId: string): Promise<AutoAction[]> {
    const result = await pool.query<{
      id: string; user_id: string; action_type: string; payload: Record<string, unknown>;
      reason: string; autonomy_level: string; status: string; created_at: Date; executed_at: Date | null;
    }>(
      `SELECT * FROM auto_action_log
       WHERE user_id = $1 AND status = 'pending_approval'
       ORDER BY created_at DESC`,
      [userId]
    );
    return result.rows.map(row => ({
      id: row.id,
      userId: row.user_id,
      actionType: row.action_type,
      payload: row.payload,
      reason: row.reason,
      autonomyLevel: row.autonomy_level as AutonomyLevel,
      status: row.status as AutoAction['status'],
      createdAt: row.created_at,
      executedAt: row.executed_at,
    }));
  },

  /**
   * Approve or reject a pending action.
   */
  async respond(userId: string, actionId: string, approve: boolean): Promise<void> {
    const status = approve ? 'executed' : 'rejected';
    await pool.query(
      `UPDATE auto_action_log SET status = $1, executed_at = CASE WHEN $1 = 'executed' THEN NOW() ELSE NULL END
       WHERE id = $2 AND user_id = $3`,
      [status, actionId, userId]
    );
  },

  /**
   * Undo an executed auto-action.
   */
  async undo(userId: string, actionId: string): Promise<void> {
    await pool.query(
      `UPDATE auto_action_log SET status = 'undone' WHERE id = $1 AND user_id = $2`,
      [actionId, userId]
    );
  },
};
