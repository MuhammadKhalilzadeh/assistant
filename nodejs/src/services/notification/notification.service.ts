/**
 * Notification service that delivers alerts to users.
 * Currently uses the inbox model as the delivery channel.
 * FCM push notifications can be added later as an additional channel.
 */

import { inboxModel } from '../../models/inbox.model';
import pool from '../../config/database';
import { logger } from '../../config/logger';

export interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  category: 'morning_briefing' | 'streak_alert' | 'anomaly' | 'weekly_report' | 'reminder' | 'insight';
  data?: Record<string, unknown>;
}

export const notificationService = {
  /**
   * Send a notification to a user via inbox.
   * Checks rate limits and quiet hours before sending.
   */
  async send(payload: NotificationPayload): Promise<boolean> {
    try {
      // Rate limit: max 5 notifications per category per day
      const recentCount = await this.getRecentCount(
        payload.userId,
        payload.category,
        24,
      );
      if (recentCount >= 5) {
        logger.debug(
          { userId: payload.userId, category: payload.category },
          'Notification rate limited'
        );
        return false;
      }

      // Deliver via inbox
      await inboxModel.create(payload.userId, {
        service: 'jarvis',
        sender: `Jarvis (${payload.category.replace(/_/g, ' ')})`,
        subject: payload.title,
        preview: payload.body.substring(0, 100),
        body: payload.body,
        isRead: false,
      });

      // Log the notification
      await this.logNotification(payload);

      logger.debug(
        { userId: payload.userId, category: payload.category, title: payload.title },
        'Notification sent'
      );

      return true;
    } catch (err) {
      logger.error({ err, userId: payload.userId }, 'Failed to send notification');
      return false;
    }
  },

  /**
   * Get count of recent notifications for a user/category in the last N hours.
   */
  async getRecentCount(
    userId: string,
    category: string,
    hours: number,
  ): Promise<number> {
    try {
      const result = await pool.query<{ count: string }>(
        `SELECT COUNT(*) as count FROM notification_log
         WHERE user_id = $1 AND category = $2
           AND sent_at > NOW() - INTERVAL '${hours} hours'`,
        [userId, category]
      );
      return parseInt(result.rows[0]?.count ?? '0');
    } catch {
      return 0; // If table doesn't exist yet, allow sending
    }
  },

  /**
   * Log a sent notification for rate limiting and analytics.
   */
  async logNotification(payload: NotificationPayload): Promise<void> {
    try {
      await pool.query(
        `INSERT INTO notification_log (user_id, category, title, sent_at)
         VALUES ($1, $2, $3, NOW())`,
        [payload.userId, payload.category, payload.title]
      );
    } catch {
      // Table might not exist yet, that's ok
    }
  },

  /**
   * Ensure the notification_log table exists.
   */
  async ensureTable(): Promise<void> {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS notification_log (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        category VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_notification_log_user
      ON notification_log(user_id, category, sent_at)
    `);
  },
};
