import pool from '../config/database';

export interface HeartRateRecord {
  id: string;
  bpm: number;
  zone: string;
  recordedAt: Date;
  createdAt: Date;
}

export interface HeartRateRecordRow {
  id: string;
  bpm: number;
  zone: string;
  recorded_at: Date;
  created_at: Date;
}

export interface HeartRateGoal {
  id: string;
  targetRestingBpm: number;
  maxBpm: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface HeartRateGoalRow {
  id: string;
  target_resting_bpm: number;
  max_bpm: number;
  created_at: Date;
  updated_at: Date;
}

export interface HeartRateStats {
  averageRestingBpm: number;
  averageActiveBpm: number;
  minBpm: number;
  maxBpm: number;
  currentStreak: number;
  bestStreak: number;
  totalReadings: number;
  zoneDistribution: Record<string, number>;
}

export interface HeartRateDailySummary {
  date: string;
  avgBpm: number;
  minBpm: number;
  maxBpm: number;
  readingCount: number;
}

export interface CreateHeartRateInput {
  bpm: number;
  zone?: string;
  recordedAt?: string;
}

export interface UpdateHeartRateInput {
  bpm?: number;
  zone?: string;
  recordedAt?: string;
}

export interface UpdateHeartRateGoalInput {
  targetRestingBpm: number;
  maxBpm?: number;
}

function calculateZone(bpm: number): string {
  if (bpm < 60) return 'resting';
  if (bpm < 100) return 'warmUp';
  if (bpm < 140) return 'fatBurn';
  if (bpm < 170) return 'cardio';
  return 'peak';
}

function rowToRecord(row: HeartRateRecordRow): HeartRateRecord {
  return {
    id: row.id,
    bpm: row.bpm,
    zone: row.zone,
    recordedAt: row.recorded_at,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: HeartRateGoalRow): HeartRateGoal {
  return {
    id: row.id,
    targetRestingBpm: row.target_resting_bpm,
    maxBpm: row.max_bpm,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const heartRateModel = {
  async getRecordsForDate(userId: string, date?: string): Promise<HeartRateRecord[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<HeartRateRecordRow>(`
      SELECT id, bpm, zone, recorded_at, created_at
      FROM heart_rate_records
      WHERE user_id = $1 AND DATE(recorded_at) = $2
      ORDER BY recorded_at DESC
    `, [userId, targetDate]);
    return result.rows.map(rowToRecord);
  },

  async findById(userId: string, id: string): Promise<HeartRateRecord | null> {
    const result = await pool.query<HeartRateRecordRow>(
      `SELECT id, bpm, zone, recorded_at, created_at FROM heart_rate_records WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!result.rows[0]) return null;
    return rowToRecord(result.rows[0]);
  },

  async create(userId: string, input: CreateHeartRateInput): Promise<HeartRateRecord> {
    const zone = input.zone || calculateZone(input.bpm);
    const result = await pool.query<HeartRateRecordRow>(
      `INSERT INTO heart_rate_records (user_id, bpm, zone, recorded_at)
       VALUES ($1, $2, $3, $4)
       RETURNING id, bpm, zone, recorded_at, created_at`,
      [userId, input.bpm, zone, input.recordedAt ? new Date(input.recordedAt) : new Date()]
    );
    return rowToRecord(result.rows[0]);
  },

  async update(userId: string, id: string, input: UpdateHeartRateInput): Promise<HeartRateRecord | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number | Date)[] = [];
    let paramIndex = 1;

    if (input.bpm !== undefined) {
      updates.push(`bpm = $${paramIndex++}`);
      values.push(input.bpm);
      // Auto-update zone when bpm changes
      const zone = input.zone || calculateZone(input.bpm);
      updates.push(`zone = $${paramIndex++}`);
      values.push(zone);
    } else if (input.zone !== undefined) {
      updates.push(`zone = $${paramIndex++}`);
      values.push(input.zone);
    }
    if (input.recordedAt !== undefined) {
      updates.push(`recorded_at = $${paramIndex++}`);
      values.push(new Date(input.recordedAt));
    }

    if (updates.length === 0) return existing;

    values.push(id);
    values.push(userId);
    await pool.query(
      `UPDATE heart_rate_records SET ${updates.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex}`,
      values
    );
    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM heart_rate_records WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(userId: string): Promise<HeartRateGoal> {
    const result = await pool.query<HeartRateGoalRow>(`
      SELECT id, target_resting_bpm, max_bpm, created_at, updated_at
      FROM heart_rate_goals WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1
    `, [userId]);
    if (!result.rows[0]) {
      const insertResult = await pool.query<HeartRateGoalRow>(
        `INSERT INTO heart_rate_goals (user_id, target_resting_bpm, max_bpm)
         VALUES ($1, 65, 180)
         RETURNING id, target_resting_bpm, max_bpm, created_at, updated_at`,
        [userId]
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(userId: string, input: UpdateHeartRateGoalInput): Promise<HeartRateGoal> {
    const goal = await this.getGoal(userId);
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | string)[] = [];
    let paramIndex = 1;

    updates.push(`target_resting_bpm = $${paramIndex++}`);
    values.push(input.targetRestingBpm);

    if (input.maxBpm !== undefined) {
      updates.push(`max_bpm = $${paramIndex++}`);
      values.push(input.maxBpm);
    }

    values.push(goal.id);
    values.push(userId);
    await pool.query(
      `UPDATE heart_rate_goals SET ${updates.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex}`,
      values
    );
    return this.getGoal(userId);
  },

  async getStats(userId: string): Promise<HeartRateStats> {
    const today = new Date().toISOString().split('T')[0];

    // Get resting average (bpm < 100)
    const restingResult = await pool.query<{ avg: string }>(`
      SELECT COALESCE(AVG(bpm), 0) as avg FROM heart_rate_records
      WHERE user_id = $1 AND bpm < 100 AND recorded_at >= CURRENT_DATE - INTERVAL '7 days'
    `, [userId]);
    const averageRestingBpm = Math.round(parseFloat(restingResult.rows[0].avg) * 10) / 10;

    // Get active average (bpm >= 100)
    const activeResult = await pool.query<{ avg: string }>(`
      SELECT COALESCE(AVG(bpm), 0) as avg FROM heart_rate_records
      WHERE user_id = $1 AND bpm >= 100 AND recorded_at >= CURRENT_DATE - INTERVAL '7 days'
    `, [userId]);
    const averageActiveBpm = Math.round(parseFloat(activeResult.rows[0].avg) * 10) / 10;

    // Get min/max
    const minMaxResult = await pool.query<{ min_bpm: number; max_bpm: number; total: string }>(`
      SELECT COALESCE(MIN(bpm), 0) as min_bpm, COALESCE(MAX(bpm), 0) as max_bpm, COUNT(*) as total
      FROM heart_rate_records
      WHERE user_id = $1 AND recorded_at >= CURRENT_DATE - INTERVAL '7 days'
    `, [userId]);

    // Get zone distribution
    const zoneResult = await pool.query<{ zone: string; count: string }>(`
      SELECT zone, COUNT(*) as count FROM heart_rate_records
      WHERE user_id = $1 AND recorded_at >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY zone
    `, [userId]);
    const zoneDistribution: Record<string, number> = {};
    for (const row of zoneResult.rows) {
      zoneDistribution[row.zone] = parseInt(row.count);
    }

    // Calculate streaks (days with at least one reading)
    const { currentStreak, bestStreak } = await this.calculateStreaks(userId);

    return {
      averageRestingBpm,
      averageActiveBpm,
      minBpm: minMaxResult.rows[0].min_bpm,
      maxBpm: minMaxResult.rows[0].max_bpm,
      currentStreak,
      bestStreak,
      totalReadings: parseInt(minMaxResult.rows[0].total),
      zoneDistribution,
    };
  },

  async calculateStreaks(userId: string): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ log_date: Date }>(`
      SELECT DISTINCT DATE(recorded_at) as log_date
      FROM heart_rate_records
      WHERE user_id = $1
      ORDER BY log_date DESC
    `, [userId]);

    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dates = result.rows.map(r => new Date(r.log_date).toISOString().split('T')[0]);
    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 1;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStr = today.toISOString().split('T')[0];
    const yesterdayDate = new Date(today);
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterdayStr = yesterdayDate.toISOString().split('T')[0];

    // Current streak
    let checkDate = new Date(today);
    if (dates[0] !== todayStr) {
      if (dates[0] === yesterdayStr) {
        checkDate = yesterdayDate;
      } else {
        currentStreak = 0;
        // Still calculate best streak
        for (let i = 1; i < dates.length; i++) {
          const prev = new Date(dates[i - 1]);
          const curr = new Date(dates[i]);
          const diff = Math.round((prev.getTime() - curr.getTime()) / (1000 * 60 * 60 * 24));
          if (diff === 1) {
            tempStreak++;
          } else {
            tempStreak = 1;
          }
          bestStreak = Math.max(bestStreak, tempStreak);
        }
        bestStreak = Math.max(bestStreak, 1);
        return { currentStreak, bestStreak };
      }
    }

    const checkStr = checkDate.toISOString().split('T')[0];
    for (const dateStr of dates) {
      const d = new Date(checkDate);
      const dStr = d.toISOString().split('T')[0];
      if (dateStr === dStr) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    // Best streak
    tempStreak = 1;
    const sortedDates = [...dates].sort();
    for (let i = 1; i < sortedDates.length; i++) {
      const prev = new Date(sortedDates[i - 1]);
      const curr = new Date(sortedDates[i]);
      const diff = Math.round((curr.getTime() - prev.getTime()) / (1000 * 60 * 60 * 24));
      if (diff === 1) {
        tempStreak++;
      } else {
        tempStreak = 1;
      }
      bestStreak = Math.max(bestStreak, tempStreak);
    }
    bestStreak = Math.max(bestStreak, currentStreak, 1);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(userId: string): Promise<HeartRateDailySummary[]> {
    const summaries: HeartRateDailySummary[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ avg_bpm: string; min_bpm: string; max_bpm: string; count: string }>(
        `SELECT COALESCE(AVG(bpm), 0) as avg_bpm, COALESCE(MIN(bpm), 0) as min_bpm,
                COALESCE(MAX(bpm), 0) as max_bpm, COUNT(*) as count
         FROM heart_rate_records WHERE user_id = $1 AND DATE(recorded_at) = $2`,
        [userId, dateStr]
      );

      summaries.push({
        date: dateStr,
        avgBpm: Math.round(parseFloat(result.rows[0].avg_bpm)),
        minBpm: parseInt(result.rows[0].min_bpm),
        maxBpm: parseInt(result.rows[0].max_bpm),
        readingCount: parseInt(result.rows[0].count),
      });
    }
    return summaries;
  },
};
