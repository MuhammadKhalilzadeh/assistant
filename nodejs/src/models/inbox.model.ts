import pool from '../config/database';

export interface InboxMessage {
  id: string;
  service: string;
  sender: string;
  subject: string;
  preview: string;
  body: string | null;
  gmailMessageId: string | null;
  isRead: boolean;
  isStarred: boolean;
  receivedAt: Date;
  createdAt: Date;
}

export interface InboxMessageRow {
  id: string;
  service: string;
  sender: string;
  subject: string;
  preview: string;
  body: string | null;
  gmail_message_id: string | null;
  is_read: boolean;
  is_starred: boolean;
  received_at: Date;
  created_at: Date;
}

export interface InboxStats {
  totalMessages: number;
  unreadCount: number;
  starredCount: number;
  services: string[];
}

export interface CreateInboxMessageInput {
  service?: string;
  sender: string;
  subject: string;
  preview?: string;
  body?: string;
  gmailMessageId?: string;
  isRead?: boolean;
  isStarred?: boolean;
  receivedAt?: string;
}

export interface UpdateInboxMessageInput {
  service?: string;
  sender?: string;
  subject?: string;
  preview?: string;
  isRead?: boolean;
  isStarred?: boolean;
}

export interface UpsertGmailMessageInput {
  gmailMessageId: string;
  sender: string;
  subject: string;
  preview?: string;
  body?: string;
  isRead?: boolean;
  isStarred?: boolean;
  receivedAt?: string;
}

function rowToMessage(row: InboxMessageRow): InboxMessage {
  return {
    id: row.id,
    service: row.service,
    sender: row.sender,
    subject: row.subject,
    preview: row.preview,
    body: row.body,
    gmailMessageId: row.gmail_message_id,
    isRead: row.is_read,
    isStarred: row.is_starred,
    receivedAt: row.received_at,
    createdAt: row.created_at,
  };
}

export const inboxModel = {
  async getMessages(userId: string, filters?: { service?: string; isRead?: boolean }): Promise<InboxMessage[]> {
    let query = `SELECT id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at
                 FROM inbox_messages WHERE user_id = $1`;
    const values: (string | boolean)[] = [userId];
    let paramIndex = 2;

    if (filters?.service) {
      query += ` AND service = $${paramIndex++}`;
      values.push(filters.service);
    }
    if (filters?.isRead !== undefined) {
      query += ` AND is_read = $${paramIndex++}`;
      values.push(filters.isRead);
    }

    query += ' ORDER BY received_at DESC';

    const result = await pool.query<InboxMessageRow>(query, values);
    return result.rows.map(rowToMessage);
  },

  async findById(userId: string, id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `SELECT id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at
       FROM inbox_messages WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async create(userId: string, input: CreateInboxMessageInput): Promise<InboxMessage> {
    const result = await pool.query<InboxMessageRow>(
      `INSERT INTO inbox_messages (user_id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at`,
      [
        userId,
        input.service || 'General',
        input.sender,
        input.subject,
        input.preview || '',
        input.body || null,
        input.gmailMessageId || null,
        input.isRead || false,
        input.isStarred || false,
        input.receivedAt ? new Date(input.receivedAt) : new Date(),
      ]
    );

    return rowToMessage(result.rows[0]);
  },

  async update(userId: string, id: string, input: UpdateInboxMessageInput): Promise<InboxMessage | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | boolean)[] = [];
    let paramIndex = 1;

    if (input.service !== undefined) {
      updates.push(`service = $${paramIndex++}`);
      values.push(input.service);
    }
    if (input.sender !== undefined) {
      updates.push(`sender = $${paramIndex++}`);
      values.push(input.sender);
    }
    if (input.subject !== undefined) {
      updates.push(`subject = $${paramIndex++}`);
      values.push(input.subject);
    }
    if (input.preview !== undefined) {
      updates.push(`preview = $${paramIndex++}`);
      values.push(input.preview);
    }
    if (input.isRead !== undefined) {
      updates.push(`is_read = $${paramIndex++}`);
      values.push(input.isRead);
    }
    if (input.isStarred !== undefined) {
      updates.push(`is_starred = $${paramIndex++}`);
      values.push(input.isStarred);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    values.push(userId);
    await pool.query(
      `UPDATE inbox_messages SET ${updates.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex}`,
      values
    );

    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM inbox_messages WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async markAsRead(userId: string, id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `UPDATE inbox_messages SET is_read = TRUE WHERE id = $1 AND user_id = $2
       RETURNING id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at`,
      [id, userId]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async toggleStar(userId: string, id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `UPDATE inbox_messages SET is_starred = NOT is_starred WHERE id = $1 AND user_id = $2
       RETURNING id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at`,
      [id, userId]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async getStats(userId: string): Promise<InboxStats> {
    const totalResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages WHERE user_id = $1',
      [userId]
    );
    const unreadResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages WHERE user_id = $1 AND is_read = FALSE',
      [userId]
    );
    const starredResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages WHERE user_id = $1 AND is_starred = TRUE',
      [userId]
    );
    const servicesResult = await pool.query<{ service: string }>(
      'SELECT DISTINCT service FROM inbox_messages WHERE user_id = $1 ORDER BY service',
      [userId]
    );

    return {
      totalMessages: parseInt(totalResult.rows[0].count),
      unreadCount: parseInt(unreadResult.rows[0].count),
      starredCount: parseInt(starredResult.rows[0].count),
      services: servicesResult.rows.map(r => r.service),
    };
  },

  async upsertGmailMessage(userId: string, data: UpsertGmailMessageInput): Promise<InboxMessage> {
    const result = await pool.query<InboxMessageRow>(
      `INSERT INTO inbox_messages (user_id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at)
       VALUES ($1, 'Gmail', $2, $3, $4, $5, $6, $7, $8, $9)
       ON CONFLICT (gmail_message_id) DO UPDATE SET
         sender = $2, subject = $3, preview = $4, body = $5,
         is_read = $7, is_starred = $8
       RETURNING id, service, sender, subject, preview, body, gmail_message_id, is_read, is_starred, received_at, created_at`,
      [
        userId,
        data.sender,
        data.subject,
        data.preview || '',
        data.body || null,
        data.gmailMessageId,
        data.isRead || false,
        data.isStarred || false,
        data.receivedAt ? new Date(data.receivedAt) : new Date(),
      ]
    );

    return rowToMessage(result.rows[0]);
  },

  async getBody(userId: string, id: string): Promise<string | null> {
    const result = await pool.query<{ body: string | null }>(
      `SELECT body FROM inbox_messages WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!result.rows[0]) return null;
    return result.rows[0].body;
  },

  async updateBody(userId: string, id: string, body: string): Promise<void> {
    await pool.query(
      `UPDATE inbox_messages SET body = $1 WHERE id = $2 AND user_id = $3`,
      [body, id, userId]
    );
  },
};
