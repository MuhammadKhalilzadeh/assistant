import pool from '../config/database';

export interface InboxMessage {
  id: string;
  service: string;
  sender: string;
  subject: string;
  preview: string;
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

function rowToMessage(row: InboxMessageRow): InboxMessage {
  return {
    id: row.id,
    service: row.service,
    sender: row.sender,
    subject: row.subject,
    preview: row.preview,
    isRead: row.is_read,
    isStarred: row.is_starred,
    receivedAt: row.received_at,
    createdAt: row.created_at,
  };
}

export const inboxModel = {
  async getMessages(filters?: { service?: string; isRead?: boolean }): Promise<InboxMessage[]> {
    let query = `SELECT id, service, sender, subject, preview, is_read, is_starred, received_at, created_at
                 FROM inbox_messages WHERE 1=1`;
    const values: (string | boolean)[] = [];
    let paramIndex = 1;

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

  async findById(id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `SELECT id, service, sender, subject, preview, is_read, is_starred, received_at, created_at
       FROM inbox_messages WHERE id = $1`,
      [id]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async create(input: CreateInboxMessageInput): Promise<InboxMessage> {
    const result = await pool.query<InboxMessageRow>(
      `INSERT INTO inbox_messages (service, sender, subject, preview, is_read, is_starred, received_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, service, sender, subject, preview, is_read, is_starred, received_at, created_at`,
      [
        input.service || 'General',
        input.sender,
        input.subject,
        input.preview || '',
        input.isRead || false,
        input.isStarred || false,
        input.receivedAt ? new Date(input.receivedAt) : new Date(),
      ]
    );

    return rowToMessage(result.rows[0]);
  },

  async update(id: string, input: UpdateInboxMessageInput): Promise<InboxMessage | null> {
    const existing = await this.findById(id);
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
    await pool.query(
      `UPDATE inbox_messages SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );

    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM inbox_messages WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async markAsRead(id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `UPDATE inbox_messages SET is_read = TRUE WHERE id = $1
       RETURNING id, service, sender, subject, preview, is_read, is_starred, received_at, created_at`,
      [id]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async toggleStar(id: string): Promise<InboxMessage | null> {
    const result = await pool.query<InboxMessageRow>(
      `UPDATE inbox_messages SET is_starred = NOT is_starred WHERE id = $1
       RETURNING id, service, sender, subject, preview, is_read, is_starred, received_at, created_at`,
      [id]
    );

    if (!result.rows[0]) return null;
    return rowToMessage(result.rows[0]);
  },

  async getStats(): Promise<InboxStats> {
    const totalResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages'
    );
    const unreadResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages WHERE is_read = FALSE'
    );
    const starredResult = await pool.query<{ count: string }>(
      'SELECT COUNT(*) as count FROM inbox_messages WHERE is_starred = TRUE'
    );
    const servicesResult = await pool.query<{ service: string }>(
      'SELECT DISTINCT service FROM inbox_messages ORDER BY service'
    );

    return {
      totalMessages: parseInt(totalResult.rows[0].count),
      unreadCount: parseInt(unreadResult.rows[0].count),
      starredCount: parseInt(starredResult.rows[0].count),
      services: servicesResult.rows.map(r => r.service),
    };
  },
};
