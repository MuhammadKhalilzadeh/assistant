import pool from '../config/database';

export interface Insight {
  id: string;
  type: 'correlation' | 'pattern' | 'anomaly' | 'trend' | 'suggestion';
  domains: string[];
  title: string;
  description: string;
  confidence: number;
  data: Record<string, unknown>;
  dismissed: boolean;
  expiresAt: Date | null;
  createdAt: Date;
}

interface InsightRow {
  id: string;
  type: string;
  domains: string[];
  title: string;
  description: string;
  confidence: number;
  data: Record<string, unknown>;
  dismissed: boolean;
  expires_at: Date | null;
  created_at: Date;
}

function rowToInsight(row: InsightRow): Insight {
  return {
    id: row.id,
    type: row.type as Insight['type'],
    domains: row.domains,
    title: row.title,
    description: row.description,
    confidence: row.confidence,
    data: row.data,
    dismissed: row.dismissed,
    expiresAt: row.expires_at,
    createdAt: row.created_at,
  };
}

export const insightModel = {
  async ensureTable(): Promise<void> {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS insights (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(20) NOT NULL,
        domains TEXT[] DEFAULT '{}',
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        confidence DECIMAL(3,2) DEFAULT 0.5,
        data JSONB DEFAULT '{}',
        dismissed BOOLEAN DEFAULT FALSE,
        expires_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_insights_user_id ON insights(user_id)
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_insights_type ON insights(type)
    `);
  },

  async findByUserId(userId: string, limit = 20, offset = 0): Promise<Insight[]> {
    const result = await pool.query<InsightRow>(
      `SELECT id, type, domains, title, description, confidence, data, dismissed, expires_at, created_at
       FROM insights
       WHERE user_id = $1 AND dismissed = FALSE
         AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows.map(rowToInsight);
  },

  async findByType(userId: string, type: string): Promise<Insight[]> {
    const result = await pool.query<InsightRow>(
      `SELECT id, type, domains, title, description, confidence, data, dismissed, expires_at, created_at
       FROM insights
       WHERE user_id = $1 AND type = $2 AND dismissed = FALSE
         AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
       ORDER BY created_at DESC`,
      [userId, type]
    );
    return result.rows.map(rowToInsight);
  },

  async create(
    userId: string,
    input: {
      type: Insight['type'];
      domains: string[];
      title: string;
      description: string;
      confidence?: number;
      data?: Record<string, unknown>;
      expiresAt?: Date;
    }
  ): Promise<Insight> {
    const result = await pool.query<InsightRow>(
      `INSERT INTO insights (user_id, type, domains, title, description, confidence, data, expires_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, type, domains, title, description, confidence, data, dismissed, expires_at, created_at`,
      [
        userId,
        input.type,
        input.domains,
        input.title,
        input.description,
        input.confidence ?? 0.5,
        JSON.stringify(input.data ?? {}),
        input.expiresAt ?? null,
      ]
    );
    return rowToInsight(result.rows[0]);
  },

  async dismiss(userId: string, id: string): Promise<boolean> {
    const result = await pool.query(
      'UPDATE insights SET dismissed = TRUE WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    return (result.rowCount ?? 0) > 0;
  },

  async deleteExpired(): Promise<number> {
    const result = await pool.query(
      'DELETE FROM insights WHERE expires_at IS NOT NULL AND expires_at < CURRENT_TIMESTAMP'
    );
    return result.rowCount ?? 0;
  },
};
