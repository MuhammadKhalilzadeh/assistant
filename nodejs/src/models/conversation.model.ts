import pool from '../config/database';

export interface ConversationMessage {
  id: string;
  role: string;
  content: string;
  createdAt: Date;
}

export interface Conversation {
  id: string;
  userId: string;
  title: string | null;
  messages: ConversationMessage[];
  createdAt: Date;
  updatedAt: Date;
}

interface ConversationRow {
  id: string;
  user_id: string;
  title: string | null;
  created_at: Date;
  updated_at: Date;
}

interface MessageRow {
  id: string;
  conversation_id: string;
  role: string;
  content: string;
  created_at: Date;
}

function rowToConversation(row: ConversationRow, messages: MessageRow[] = []): Conversation {
  return {
    id: row.id,
    userId: row.user_id,
    title: row.title,
    messages: messages.map((m) => ({
      id: m.id,
      role: m.role,
      content: m.content,
      createdAt: m.created_at,
    })),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const conversationModel = {
  async create(userId: string, title?: string): Promise<Conversation> {
    const result = await pool.query<ConversationRow>(
      `INSERT INTO conversations (user_id, title)
       VALUES ($1, $2)
       RETURNING *`,
      [userId, title || null]
    );
    return rowToConversation(result.rows[0]);
  },

  async findById(id: string, userId: string): Promise<Conversation | null> {
    const convResult = await pool.query<ConversationRow>(
      `SELECT * FROM conversations WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!convResult.rows[0]) return null;

    const msgResult = await pool.query<MessageRow>(
      `SELECT * FROM conversation_messages WHERE conversation_id = $1 ORDER BY created_at ASC`,
      [id]
    );

    return rowToConversation(convResult.rows[0], msgResult.rows);
  },

  async findByUserId(userId: string, limit: number = 20, offset: number = 0): Promise<Conversation[]> {
    const result = await pool.query<ConversationRow>(
      `SELECT * FROM conversations WHERE user_id = $1 ORDER BY updated_at DESC LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows.map((row) => rowToConversation(row));
  },

  async addMessage(conversationId: string, role: string, content: string): Promise<ConversationMessage> {
    const result = await pool.query<MessageRow>(
      `INSERT INTO conversation_messages (conversation_id, role, content)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [conversationId, role, content]
    );

    // Update conversation's updated_at
    await pool.query(
      `UPDATE conversations SET updated_at = CURRENT_TIMESTAMP WHERE id = $1`,
      [conversationId]
    );

    const row = result.rows[0];
    return {
      id: row.id,
      role: row.role,
      content: row.content,
      createdAt: row.created_at,
    };
  },

  async delete(id: string, userId: string): Promise<boolean> {
    const result = await pool.query(
      `DELETE FROM conversations WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    return (result.rowCount ?? 0) > 0;
  },
};
