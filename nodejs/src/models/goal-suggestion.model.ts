import pool from '../config/database';

export interface GoalSuggestion {
  id: string;
  userId: string;
  domain: string;
  currentGoal: number;
  suggestedGoal: number;
  direction: 'increase' | 'decrease';
  reason: string;
  confidence: number;
  evidence: Record<string, unknown>;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: Date;
  respondedAt: Date | null;
}

interface GoalSuggestionRow {
  id: string;
  user_id: string;
  domain: string;
  current_goal: number;
  suggested_goal: number;
  direction: string;
  reason: string;
  confidence: string;
  evidence: Record<string, unknown>;
  status: string;
  created_at: Date;
  responded_at: Date | null;
}

function rowToSuggestion(row: GoalSuggestionRow): GoalSuggestion {
  return {
    id: row.id,
    userId: row.user_id,
    domain: row.domain,
    currentGoal: row.current_goal,
    suggestedGoal: row.suggested_goal,
    direction: row.direction as 'increase' | 'decrease',
    reason: row.reason,
    confidence: parseFloat(row.confidence),
    evidence: row.evidence,
    status: row.status as GoalSuggestion['status'],
    createdAt: row.created_at,
    respondedAt: row.responded_at,
  };
}

export const goalSuggestionModel = {
  async ensureTable(): Promise<void> {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS goal_suggestions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        domain VARCHAR(50) NOT NULL,
        current_goal DECIMAL NOT NULL,
        suggested_goal DECIMAL NOT NULL,
        direction VARCHAR(10) NOT NULL,
        reason TEXT NOT NULL,
        confidence DECIMAL(3,2) DEFAULT 0.50,
        evidence JSONB DEFAULT '{}',
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        responded_at TIMESTAMPTZ
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_goal_suggestions_user
      ON goal_suggestions(user_id, status)
    `);
  },

  async findPending(userId: string): Promise<GoalSuggestion[]> {
    const result = await pool.query<GoalSuggestionRow>(
      `SELECT * FROM goal_suggestions
       WHERE user_id = $1 AND status = 'pending'
       ORDER BY created_at DESC`,
      [userId]
    );
    return result.rows.map(rowToSuggestion);
  },

  async findAll(userId: string, limit = 20): Promise<GoalSuggestion[]> {
    const result = await pool.query<GoalSuggestionRow>(
      `SELECT * FROM goal_suggestions
       WHERE user_id = $1
       ORDER BY created_at DESC LIMIT $2`,
      [userId, limit]
    );
    return result.rows.map(rowToSuggestion);
  },

  async create(
    userId: string,
    input: Omit<GoalSuggestion, 'id' | 'userId' | 'status' | 'createdAt' | 'respondedAt'>,
  ): Promise<GoalSuggestion> {
    const result = await pool.query<GoalSuggestionRow>(
      `INSERT INTO goal_suggestions (user_id, domain, current_goal, suggested_goal, direction, reason, confidence, evidence)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [userId, input.domain, input.currentGoal, input.suggestedGoal, input.direction, input.reason, input.confidence, JSON.stringify(input.evidence)]
    );
    return rowToSuggestion(result.rows[0]);
  },

  async respond(userId: string, id: string, status: 'accepted' | 'rejected'): Promise<GoalSuggestion | null> {
    const result = await pool.query<GoalSuggestionRow>(
      `UPDATE goal_suggestions
       SET status = $1, responded_at = NOW()
       WHERE id = $2 AND user_id = $3
       RETURNING *`,
      [status, id, userId]
    );
    return result.rows.length > 0 ? rowToSuggestion(result.rows[0]) : null;
  },

  async wasRecentlyRejected(userId: string, domain: string, days = 30): Promise<boolean> {
    const result = await pool.query<{ count: string }>(
      `SELECT COUNT(*) as count FROM goal_suggestions
       WHERE user_id = $1 AND domain = $2 AND status = 'rejected'
         AND responded_at > NOW() - INTERVAL '${days} days'`,
      [userId, domain]
    );
    return parseInt(result.rows[0].count) > 0;
  },
};
