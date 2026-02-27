import pool from '../config/database';

export interface User {
  id: string;
  googleId: string;
  email: string;
  displayName: string | null;
  photoUrl: string | null;
  nickname: string | null;
  gmailConnected: boolean;
  gmailTokenExpiry: Date | null;
  lastLoginAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

interface UserRow {
  id: string;
  google_id: string;
  email: string;
  display_name: string | null;
  photo_url: string | null;
  nickname: string | null;
  gmail_connected: boolean;
  gmail_token_expiry: Date | null;
  last_login_at: Date;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUserInput {
  googleId: string;
  email: string;
  displayName?: string | null;
  photoUrl?: string | null;
}

export interface GmailTokens {
  accessToken: string;
  refreshToken: string;
  expiry: Date;
}

function rowToUser(row: UserRow): User {
  return {
    id: row.id,
    googleId: row.google_id,
    email: row.email,
    displayName: row.display_name,
    photoUrl: row.photo_url,
    nickname: row.nickname,
    gmailConnected: row.gmail_connected,
    gmailTokenExpiry: row.gmail_token_expiry,
    lastLoginAt: row.last_login_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

const SELECT_USER = `
  SELECT id, google_id, email, display_name, photo_url, nickname,
         gmail_connected, gmail_token_expiry, last_login_at, created_at, updated_at
  FROM users
`;

export const userModel = {
  async create(input: CreateUserInput): Promise<User> {
    const result = await pool.query<UserRow>(
      `INSERT INTO users (google_id, email, display_name, photo_url, nickname)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [input.googleId, input.email, input.displayName || null, input.photoUrl || null, input.nickname || null]
    );
    return rowToUser(result.rows[0]);
  },

  async findById(id: string): Promise<User | null> {
    const result = await pool.query<UserRow>(
      `${SELECT_USER} WHERE id = $1`,
      [id]
    );
    return result.rows[0] ? rowToUser(result.rows[0]) : null;
  },

  async findByGoogleId(googleId: string): Promise<User | null> {
    const result = await pool.query<UserRow>(
      `${SELECT_USER} WHERE google_id = $1`,
      [googleId]
    );
    return result.rows[0] ? rowToUser(result.rows[0]) : null;
  },

  async findByEmail(email: string): Promise<User | null> {
    const result = await pool.query<UserRow>(
      `${SELECT_USER} WHERE email = $1`,
      [email]
    );
    return result.rows[0] ? rowToUser(result.rows[0]) : null;
  },

  async update(id: string, data: { displayName?: string; photoUrl?: string; nickname?: string }): Promise<User | null> {
    const updates: string[] = [];
    const values: (string | null)[] = [];
    let paramIndex = 1;

    if (data.displayName !== undefined) {
      updates.push(`display_name = $${paramIndex++}`);
      values.push(data.displayName);
    }
    if (data.photoUrl !== undefined) {
      updates.push(`photo_url = $${paramIndex++}`);
      values.push(data.photoUrl);
    }
    if (data.nickname !== undefined) {
      updates.push(`nickname = $${paramIndex++}`);
      values.push(data.nickname);
    }

    if (updates.length === 0) return this.findById(id);

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const result = await pool.query<UserRow>(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0] ? rowToUser(result.rows[0]) : null;
  },

  async updateLastLogin(id: string): Promise<void> {
    await pool.query(
      `UPDATE users SET last_login_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = $1`,
      [id]
    );
  },

  async updateRefreshTokenHash(id: string, hash: string | null): Promise<void> {
    await pool.query(
      `UPDATE users SET refresh_token_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`,
      [hash, id]
    );
  },

  async getRefreshTokenHash(id: string): Promise<string | null> {
    const result = await pool.query<{ refresh_token_hash: string | null }>(
      `SELECT refresh_token_hash FROM users WHERE id = $1`,
      [id]
    );
    return result.rows[0]?.refresh_token_hash ?? null;
  },

  async updateGmailTokens(id: string, tokens: GmailTokens): Promise<void> {
    await pool.query(
      `UPDATE users SET
        gmail_access_token = $1,
        gmail_refresh_token = $2,
        gmail_token_expiry = $3,
        gmail_connected = TRUE,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $4`,
      [tokens.accessToken, tokens.refreshToken, tokens.expiry, id]
    );
  },

  async getGmailTokens(id: string): Promise<{ accessToken: string; refreshToken: string; expiry: Date } | null> {
    const result = await pool.query<{
      gmail_access_token: string | null;
      gmail_refresh_token: string | null;
      gmail_token_expiry: Date | null;
    }>(
      `SELECT gmail_access_token, gmail_refresh_token, gmail_token_expiry FROM users WHERE id = $1`,
      [id]
    );
    const row = result.rows[0];
    if (!row?.gmail_access_token || !row?.gmail_refresh_token) return null;
    return {
      accessToken: row.gmail_access_token,
      refreshToken: row.gmail_refresh_token,
      expiry: row.gmail_token_expiry!,
    };
  },

  async disconnectGmail(id: string): Promise<void> {
    await pool.query(
      `UPDATE users SET
        gmail_access_token = NULL,
        gmail_refresh_token = NULL,
        gmail_token_expiry = NULL,
        gmail_connected = FALSE,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [id]
    );
  },
};
