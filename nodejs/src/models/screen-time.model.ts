import pool from '../config/database';

export interface ScreenTimeRecord {
  id: string;
  date: string;
  totalMinutes: number;
  pickups: number;
  note: string | null;
  appUsage: AppUsageEntry[];
  createdAt: Date;
}

export interface ScreenTimeRecordRow {
  id: string;
  date: Date;
  total_minutes: number;
  pickups: number;
  note: string | null;
  created_at: Date;
}

export interface AppUsageEntry {
  id: string;
  appName: string;
  category: string;
  minutesUsed: number;
  iconName: string;
}

export interface AppUsageRow {
  id: string;
  screen_time_id: string;
  app_name: string;
  category: string;
  minutes_used: number;
  icon_name: string;
}

export interface ScreenTimeGoal {
  id: string;
  dailyLimitMinutes: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface ScreenTimeGoalRow {
  id: string;
  daily_limit_minutes: number;
  created_at: Date;
  updated_at: Date;
}

export interface ScreenTimeStats {
  todayMinutes: number;
  todayPickups: number;
  dailyLimitMinutes: number;
  dailyAverageMinutes: number;
  averagePickups: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  appUsageBreakdown: Record<string, number>;
}

export interface ScreenTimeDailySummary {
  date: string;
  totalMinutes: number;
  pickups: number;
  limitMinutes: number;
  underLimit: boolean;
}

export interface CreateScreenTimeInput {
  date: string;
  totalMinutes: number;
  pickups?: number;
  note?: string | null;
  appUsage?: { appName: string; category?: string; minutesUsed: number; iconName?: string }[];
}

export interface UpdateScreenTimeInput {
  totalMinutes?: number;
  pickups?: number;
  note?: string | null;
  appUsage?: { appName: string; category?: string; minutesUsed: number; iconName?: string }[];
}

export interface UpdateScreenTimeGoalInput {
  dailyLimitMinutes: number;
}

function rowToRecord(row: ScreenTimeRecordRow, appUsage: AppUsageEntry[] = []): ScreenTimeRecord {
  return {
    id: row.id,
    date: new Date(row.date).toISOString().split('T')[0],
    totalMinutes: row.total_minutes,
    pickups: row.pickups,
    note: row.note,
    appUsage,
    createdAt: row.created_at,
  };
}

function rowToAppUsage(row: AppUsageRow): AppUsageEntry {
  return {
    id: row.id,
    appName: row.app_name,
    category: row.category,
    minutesUsed: row.minutes_used,
    iconName: row.icon_name,
  };
}

function rowToGoal(row: ScreenTimeGoalRow): ScreenTimeGoal {
  return {
    id: row.id,
    dailyLimitMinutes: row.daily_limit_minutes,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const screenTimeModel = {
  async getAppUsageForRecord(userId: string, recordId: string): Promise<AppUsageEntry[]> {
    const result = await pool.query<AppUsageRow>(
      `SELECT au.id, au.screen_time_id, au.app_name, au.category, au.minutes_used, au.icon_name
       FROM app_usage au
       JOIN screen_time_records str ON au.screen_time_id = str.id
       WHERE au.screen_time_id = $1 AND str.user_id = $2
       ORDER BY au.minutes_used DESC`,
      [recordId, userId]
    );
    return result.rows.map(rowToAppUsage);
  },

  async getByDate(userId: string, date?: string): Promise<ScreenTimeRecord | null> {
    const targetDate = date || new Date().toISOString().split('T')[0];

    const result = await pool.query<ScreenTimeRecordRow>(
      `SELECT id, date, total_minutes, pickups, note, created_at
       FROM screen_time_records WHERE date = $1 AND user_id = $2`,
      [targetDate, userId]
    );

    if (!result.rows[0]) return null;

    const appUsage = await this.getAppUsageForRecord(userId, result.rows[0].id);
    return rowToRecord(result.rows[0], appUsage);
  },

  async findById(userId: string, id: string): Promise<ScreenTimeRecord | null> {
    const result = await pool.query<ScreenTimeRecordRow>(
      `SELECT id, date, total_minutes, pickups, note, created_at
       FROM screen_time_records WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (!result.rows[0]) return null;

    const appUsage = await this.getAppUsageForRecord(userId, result.rows[0].id);
    return rowToRecord(result.rows[0], appUsage);
  },

  async create(userId: string, input: CreateScreenTimeInput): Promise<ScreenTimeRecord> {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const result = await client.query<ScreenTimeRecordRow>(
        `INSERT INTO screen_time_records (user_id, date, total_minutes, pickups, note)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (user_id, date) DO UPDATE SET
           total_minutes = EXCLUDED.total_minutes,
           pickups = EXCLUDED.pickups,
           note = COALESCE(EXCLUDED.note, screen_time_records.note)
         RETURNING id, date, total_minutes, pickups, note, created_at`,
        [userId, input.date, input.totalMinutes, input.pickups || 0, input.note || null]
      );

      const recordId = result.rows[0].id;

      // Delete existing app usage for upsert
      await client.query('DELETE FROM app_usage WHERE screen_time_id = $1', [recordId]);

      // Insert app usage entries
      const appUsageEntries: AppUsageEntry[] = [];
      if (input.appUsage && input.appUsage.length > 0) {
        for (const app of input.appUsage) {
          const appResult = await client.query<AppUsageRow>(
            `INSERT INTO app_usage (screen_time_id, user_id, app_name, category, minutes_used, icon_name)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, screen_time_id, app_name, category, minutes_used, icon_name`,
            [recordId, userId, app.appName, app.category || 'other', app.minutesUsed, app.iconName || 'apps']
          );
          appUsageEntries.push(rowToAppUsage(appResult.rows[0]));
        }
      }

      await client.query('COMMIT');
      return rowToRecord(result.rows[0], appUsageEntries);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  },

  async update(userId: string, id: string, input: UpdateScreenTimeInput): Promise<ScreenTimeRecord | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const updates: string[] = [];
      const values: (string | number | null)[] = [];
      let paramIndex = 1;

      if (input.totalMinutes !== undefined) {
        updates.push(`total_minutes = $${paramIndex++}`);
        values.push(input.totalMinutes);
      }
      if (input.pickups !== undefined) {
        updates.push(`pickups = $${paramIndex++}`);
        values.push(input.pickups);
      }
      if (input.note !== undefined) {
        updates.push(`note = $${paramIndex++}`);
        values.push(input.note);
      }

      if (updates.length > 0) {
        values.push(id);
        const idParam = paramIndex++;
        values.push(userId);
        const userIdParam = paramIndex;
        await client.query(
          `UPDATE screen_time_records SET ${updates.join(', ')} WHERE id = $${idParam} AND user_id = $${userIdParam}`,
          values
        );
      }

      // Update app usage if provided
      if (input.appUsage !== undefined) {
        await client.query('DELETE FROM app_usage WHERE screen_time_id = $1', [id]);
        for (const app of input.appUsage) {
          await client.query(
            `INSERT INTO app_usage (screen_time_id, user_id, app_name, category, minutes_used, icon_name)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [id, userId, app.appName, app.category || 'other', app.minutesUsed, app.iconName || 'apps']
          );
        }
      }

      await client.query('COMMIT');
      return this.findById(userId, id);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM screen_time_records WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(userId: string): Promise<ScreenTimeGoal> {
    const result = await pool.query<ScreenTimeGoalRow>(`
      SELECT id, daily_limit_minutes, created_at, updated_at
      FROM screen_time_goals
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT 1
    `, [userId]);

    if (!result.rows[0]) {
      const insertResult = await pool.query<ScreenTimeGoalRow>(
        `INSERT INTO screen_time_goals (user_id, daily_limit_minutes)
         VALUES ($1, 180)
         RETURNING id, daily_limit_minutes, created_at, updated_at`,
        [userId]
      );
      return rowToGoal(insertResult.rows[0]);
    }

    return rowToGoal(result.rows[0]);
  },

  async updateGoal(userId: string, input: UpdateScreenTimeGoalInput): Promise<ScreenTimeGoal> {
    const goal = await this.getGoal(userId);

    await pool.query(
      `UPDATE screen_time_goals SET daily_limit_minutes = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND user_id = $3`,
      [input.dailyLimitMinutes, goal.id, userId]
    );

    return this.getGoal(userId);
  },

  async getStats(userId: string): Promise<ScreenTimeStats> {
    const goal = await this.getGoal(userId);
    const today = new Date().toISOString().split('T')[0];

    // Get today's record
    const todayResult = await pool.query<{ total_minutes: number; pickups: number }>(
      `SELECT COALESCE(total_minutes, 0) as total_minutes, COALESCE(pickups, 0) as pickups
       FROM screen_time_records WHERE date = $1 AND user_id = $2`,
      [today, userId]
    );
    const todayMinutes = todayResult.rows[0]?.total_minutes ?? 0;
    const todayPickups = todayResult.rows[0]?.pickups ?? 0;

    // Get weekly averages (last 7 days)
    const weeklyResult = await pool.query<{ avg_minutes: string; avg_pickups: string }>(`
      SELECT
        COALESCE(AVG(total_minutes), 0) as avg_minutes,
        COALESCE(AVG(pickups), 0) as avg_pickups
      FROM screen_time_records
      WHERE date >= CURRENT_DATE - INTERVAL '7 days' AND user_id = $1
    `, [userId]);
    const dailyAverageMinutes = Math.round(parseFloat(weeklyResult.rows[0].avg_minutes) * 10) / 10;
    const averagePickups = Math.round(parseFloat(weeklyResult.rows[0].avg_pickups) * 10) / 10;

    // Calculate streaks (days under limit)
    const { currentStreak, bestStreak } = await this.calculateStreaks(userId, goal.dailyLimitMinutes);

    // Goal completion rate (last 30 days - days under limit)
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE total_minutes <= $1) as days_met,
        COUNT(*) as total_days
      FROM screen_time_records
      WHERE date >= CURRENT_DATE - INTERVAL '30 days' AND user_id = $2
    `, [goal.dailyLimitMinutes, userId]);

    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    // App usage breakdown for today
    const appBreakdownResult = await pool.query<{ app_name: string; minutes_used: number }>(`
      SELECT au.app_name, au.minutes_used
      FROM app_usage au
      JOIN screen_time_records str ON au.screen_time_id = str.id
      WHERE str.date = $1 AND str.user_id = $2
      ORDER BY au.minutes_used DESC
    `, [today, userId]);

    const appUsageBreakdown: Record<string, number> = {};
    for (const row of appBreakdownResult.rows) {
      appUsageBreakdown[row.app_name] = row.minutes_used;
    }

    return {
      todayMinutes,
      todayPickups,
      dailyLimitMinutes: goal.dailyLimitMinutes,
      dailyAverageMinutes,
      averagePickups,
      currentStreak,
      bestStreak,
      goalCompletionRate,
      appUsageBreakdown,
    };
  },

  async calculateStreaks(userId: string, dailyLimitMinutes: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ date: Date; total_minutes: number }>(`
      SELECT date, total_minutes
      FROM screen_time_records
      WHERE user_id = $1
      ORDER BY date DESC
    `, [userId]);

    if (result.rows.length === 0) {
      return { currentStreak: 0, bestStreak: 0 };
    }

    const dailyData = new Map<string, number>();
    for (const row of result.rows) {
      const dateStr = new Date(row.date).toISOString().split('T')[0];
      dailyData.set(dateStr, row.total_minutes);
    }

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    // Calculate current streak
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const checkDate = new Date(today);

    // If today has no data yet, start from yesterday
    const todayStr = today.toISOString().split('T')[0];
    if (!dailyData.has(todayStr)) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dateStr = checkDate.toISOString().split('T')[0];
      const minutes = dailyData.get(dateStr);

      if (minutes !== undefined && minutes <= dailyLimitMinutes) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    // Calculate best streak
    const sortedDates = Array.from(dailyData.keys()).sort();
    for (let i = 0; i < sortedDates.length; i++) {
      const minutes = dailyData.get(sortedDates[i]) || 0;

      if (minutes <= dailyLimitMinutes) {
        if (i > 0) {
          const prevDate = new Date(sortedDates[i - 1]);
          const currDate = new Date(sortedDates[i]);
          const diffDays = Math.round((currDate.getTime() - prevDate.getTime()) / (1000 * 60 * 60 * 24));
          tempStreak = diffDays === 1 ? tempStreak + 1 : 1;
        } else {
          tempStreak = 1;
        }
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }

    return { currentStreak, bestStreak };
  },

  async getHistory(userId: string): Promise<ScreenTimeDailySummary[]> {
    const goal = await this.getGoal(userId);
    const summaries: ScreenTimeDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total_minutes: number; pickups: number }>(
        `SELECT total_minutes, pickups FROM screen_time_records WHERE date = $1 AND user_id = $2`,
        [dateStr, userId]
      );

      const totalMinutes = result.rows[0]?.total_minutes ?? 0;
      const pickups = result.rows[0]?.pickups ?? 0;

      summaries.push({
        date: dateStr,
        totalMinutes,
        pickups,
        limitMinutes: goal.dailyLimitMinutes,
        underLimit: totalMinutes <= goal.dailyLimitMinutes,
      });
    }

    return summaries;
  },
};
