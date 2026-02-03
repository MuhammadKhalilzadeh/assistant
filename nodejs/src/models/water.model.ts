import pool from '../config/database';

export interface WaterLog {
  id: string;
  amountMl: number;
  beverageType: string;
  note: string | null;
  loggedAt: Date;
  createdAt: Date;
}

export interface WaterLogRow {
  id: string;
  amount_ml: number;
  beverage_type: string;
  note: string | null;
  logged_at: Date;
  created_at: Date;
}

export interface HydrationGoal {
  id: string;
  dailyGoalMl: number;
  reminderIntervalMinutes: number;
  remindersEnabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface HydrationGoalRow {
  id: string;
  daily_goal_ml: number;
  reminder_interval_minutes: number;
  reminders_enabled: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface WaterStats {
  todayIntakeMl: number;
  dailyGoalMl: number;
  weeklyAverageMl: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
}

export interface DailySummary {
  date: string;
  totalMl: number;
  goalMl: number;
  goalMet: boolean;
  logCount: number;
}

export interface CreateWaterLogInput {
  amountMl: number;
  beverageType?: string;
  note?: string | null;
  loggedAt?: string;
}

export interface UpdateWaterLogInput {
  amountMl?: number;
  beverageType?: string;
  note?: string | null;
  loggedAt?: string;
}

export interface UpdateGoalInput {
  dailyGoalMl: number;
  reminderIntervalMinutes?: number;
  remindersEnabled?: boolean;
}

function rowToWaterLog(row: WaterLogRow): WaterLog {
  return {
    id: row.id,
    amountMl: row.amount_ml,
    beverageType: row.beverage_type,
    note: row.note,
    loggedAt: row.logged_at,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: HydrationGoalRow): HydrationGoal {
  return {
    id: row.id,
    dailyGoalMl: row.daily_goal_ml,
    reminderIntervalMinutes: row.reminder_interval_minutes,
    remindersEnabled: row.reminders_enabled,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const waterModel = {
  async getLogsForDate(date?: string): Promise<WaterLog[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];

    const result = await pool.query<WaterLogRow>(`
      SELECT id, amount_ml, beverage_type, note, logged_at, created_at
      FROM water_logs
      WHERE DATE(logged_at) = $1
      ORDER BY logged_at DESC
    `, [targetDate]);

    return result.rows.map(rowToWaterLog);
  },

  async findById(id: string): Promise<WaterLog | null> {
    const result = await pool.query<WaterLogRow>(
      `SELECT id, amount_ml, beverage_type, note, logged_at, created_at
       FROM water_logs WHERE id = $1`,
      [id]
    );

    if (!result.rows[0]) return null;
    return rowToWaterLog(result.rows[0]);
  },

  async create(input: CreateWaterLogInput): Promise<WaterLog> {
    const result = await pool.query<WaterLogRow>(
      `INSERT INTO water_logs (amount_ml, beverage_type, note, logged_at)
       VALUES ($1, $2, $3, $4)
       RETURNING id, amount_ml, beverage_type, note, logged_at, created_at`,
      [
        input.amountMl,
        input.beverageType || 'water',
        input.note || null,
        input.loggedAt ? new Date(input.loggedAt) : new Date(),
      ]
    );

    return rowToWaterLog(result.rows[0]);
  },

  async update(id: string, input: UpdateWaterLogInput): Promise<WaterLog | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number | Date | null)[] = [];
    let paramIndex = 1;

    if (input.amountMl !== undefined) {
      updates.push(`amount_ml = $${paramIndex++}`);
      values.push(input.amountMl);
    }
    if (input.beverageType !== undefined) {
      updates.push(`beverage_type = $${paramIndex++}`);
      values.push(input.beverageType);
    }
    if (input.note !== undefined) {
      updates.push(`note = $${paramIndex++}`);
      values.push(input.note);
    }
    if (input.loggedAt !== undefined) {
      updates.push(`logged_at = $${paramIndex++}`);
      values.push(new Date(input.loggedAt));
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE water_logs SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );

    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM water_logs WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(): Promise<HydrationGoal> {
    const result = await pool.query<HydrationGoalRow>(`
      SELECT id, daily_goal_ml, reminder_interval_minutes, reminders_enabled, created_at, updated_at
      FROM hydration_goals
      ORDER BY created_at DESC
      LIMIT 1
    `);

    if (!result.rows[0]) {
      // Create default goal if none exists
      const insertResult = await pool.query<HydrationGoalRow>(
        `INSERT INTO hydration_goals (daily_goal_ml, reminder_interval_minutes, reminders_enabled)
         VALUES (3000, 60, TRUE)
         RETURNING id, daily_goal_ml, reminder_interval_minutes, reminders_enabled, created_at, updated_at`
      );
      return rowToGoal(insertResult.rows[0]);
    }

    return rowToGoal(result.rows[0]);
  },

  async updateGoal(input: UpdateGoalInput): Promise<HydrationGoal> {
    const goal = await this.getGoal();

    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | boolean)[] = [];
    let paramIndex = 1;

    updates.push(`daily_goal_ml = $${paramIndex++}`);
    values.push(input.dailyGoalMl);

    if (input.reminderIntervalMinutes !== undefined) {
      updates.push(`reminder_interval_minutes = $${paramIndex++}`);
      values.push(input.reminderIntervalMinutes);
    }
    if (input.remindersEnabled !== undefined) {
      updates.push(`reminders_enabled = $${paramIndex++}`);
      values.push(input.remindersEnabled);
    }

    values.push(goal.id as unknown as number); // Type workaround for UUID
    await pool.query(
      `UPDATE hydration_goals SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );

    return this.getGoal();
  },

  async getStats(): Promise<WaterStats> {
    const goal = await this.getGoal();
    const today = new Date().toISOString().split('T')[0];

    // Get today's intake
    const todayResult = await pool.query<{ total: string }>(
      `SELECT COALESCE(SUM(amount_ml), 0) as total FROM water_logs WHERE DATE(logged_at) = $1`,
      [today]
    );
    const todayIntakeMl = parseInt(todayResult.rows[0].total);

    // Get weekly average (last 7 days)
    const weeklyResult = await pool.query<{ avg: string }>(`
      SELECT COALESCE(AVG(daily_total), 0) as avg
      FROM (
        SELECT DATE(logged_at) as log_date, SUM(amount_ml) as daily_total
        FROM water_logs
        WHERE logged_at >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY DATE(logged_at)
      ) daily_totals
    `);
    const weeklyAverageMl = Math.round(parseFloat(weeklyResult.rows[0].avg));

    // Calculate streaks
    const { currentStreak, bestStreak } = await this.calculateStreaks(goal.dailyGoalMl);

    // Calculate goal completion rate (last 30 days)
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE daily_total >= $1) as days_met,
        COUNT(*) as total_days
      FROM (
        SELECT DATE(logged_at) as log_date, SUM(amount_ml) as daily_total
        FROM water_logs
        WHERE logged_at >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(logged_at)
      ) daily_totals
    `, [goal.dailyGoalMl]);

    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      todayIntakeMl,
      dailyGoalMl: goal.dailyGoalMl,
      weeklyAverageMl,
      currentStreak,
      bestStreak,
      goalCompletionRate,
    };
  },

  async calculateStreaks(dailyGoalMl: number): Promise<{ currentStreak: number; bestStreak: number }> {
    // Get daily totals ordered by date descending
    const result = await pool.query<{ log_date: Date; daily_total: string }>(`
      SELECT DATE(logged_at) as log_date, SUM(amount_ml) as daily_total
      FROM water_logs
      GROUP BY DATE(logged_at)
      ORDER BY log_date DESC
    `);

    if (result.rows.length === 0) {
      return { currentStreak: 0, bestStreak: 0 };
    }

    const dailyTotals = new Map<string, number>();
    for (const row of result.rows) {
      const dateStr = new Date(row.log_date).toISOString().split('T')[0];
      dailyTotals.set(dateStr, parseInt(row.daily_total));
    }

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    // Calculate current streak (starting from today or yesterday)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);

    // If today's goal not met yet, start from yesterday
    const todayStr = today.toISOString().split('T')[0];
    const todayTotal = dailyTotals.get(todayStr) || 0;
    if (todayTotal < dailyGoalMl) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // Count current streak
    while (true) {
      const dateStr = checkDate.toISOString().split('T')[0];
      const total = dailyTotals.get(dateStr) || 0;

      if (total >= dailyGoalMl) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    // Calculate best streak by scanning all dates
    const sortedDates = Array.from(dailyTotals.keys()).sort();
    for (let i = 0; i < sortedDates.length; i++) {
      const total = dailyTotals.get(sortedDates[i]) || 0;

      if (total >= dailyGoalMl) {
        // Check if this is consecutive with previous day
        if (i > 0) {
          const prevDate = new Date(sortedDates[i - 1]);
          const currDate = new Date(sortedDates[i]);
          const diffDays = Math.round((currDate.getTime() - prevDate.getTime()) / (1000 * 60 * 60 * 24));

          if (diffDays === 1) {
            tempStreak++;
          } else {
            tempStreak = 1;
          }
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

  async getLast7Days(): Promise<DailySummary[]> {
    const goal = await this.getGoal();
    const summaries: DailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total: string; count: string }>(
        `SELECT COALESCE(SUM(amount_ml), 0) as total, COUNT(*) as count
         FROM water_logs WHERE DATE(logged_at) = $1`,
        [dateStr]
      );

      const totalMl = parseInt(result.rows[0].total);
      const logCount = parseInt(result.rows[0].count);

      summaries.push({
        date: dateStr,
        totalMl,
        goalMl: goal.dailyGoalMl,
        goalMet: totalMl >= goal.dailyGoalMl,
        logCount,
      });
    }

    return summaries;
  },
};
