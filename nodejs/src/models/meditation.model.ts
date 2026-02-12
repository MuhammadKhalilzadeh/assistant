import pool from '../config/database';

export interface MeditationSession {
  id: string;
  type: string;
  startTime: Date;
  durationMinutes: number;
  isCompleted: boolean;
  notes: string | null;
  createdAt: Date;
}

export interface MeditationSessionRow {
  id: string;
  type: string;
  start_time: Date;
  duration_minutes: number;
  is_completed: boolean;
  notes: string | null;
  created_at: Date;
}

export interface MeditationGoal {
  id: string;
  dailyMinutesGoal: number;
  weeklySessionsGoal: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface MeditationGoalRow {
  id: string;
  daily_minutes_goal: number;
  weekly_sessions_goal: number;
  created_at: Date;
  updated_at: Date;
}

export interface MeditationStats {
  weeklyMinutes: number;
  weeklySessions: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  sessionsByType: Record<string, number>;
  todayMinutes: number;
}

export interface MeditationDailySummary {
  date: string;
  totalMinutes: number;
  sessionCount: number;
  goalMinutes: number;
  goalMet: boolean;
}

export interface CreateMeditationSessionInput {
  type: string;
  startTime?: string;
  durationMinutes: number;
  isCompleted?: boolean;
  notes?: string | null;
}

export interface UpdateMeditationSessionInput {
  type?: string;
  startTime?: string;
  durationMinutes?: number;
  isCompleted?: boolean;
  notes?: string | null;
}

export interface UpdateMeditationGoalInput {
  dailyMinutesGoal: number;
  weeklySessionsGoal?: number;
}

function rowToSession(row: MeditationSessionRow): MeditationSession {
  return {
    id: row.id,
    type: row.type,
    startTime: row.start_time,
    durationMinutes: row.duration_minutes,
    isCompleted: row.is_completed,
    notes: row.notes,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: MeditationGoalRow): MeditationGoal {
  return {
    id: row.id,
    dailyMinutesGoal: row.daily_minutes_goal,
    weeklySessionsGoal: row.weekly_sessions_goal,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const meditationModel = {
  async getSessionsForDate(date?: string): Promise<MeditationSession[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<MeditationSessionRow>(`
      SELECT id, type, start_time, duration_minutes, is_completed, notes, created_at
      FROM meditation_sessions WHERE DATE(start_time) = $1
      ORDER BY start_time DESC
    `, [targetDate]);
    return result.rows.map(rowToSession);
  },

  async findById(id: string): Promise<MeditationSession | null> {
    const result = await pool.query<MeditationSessionRow>(
      `SELECT id, type, start_time, duration_minutes, is_completed, notes, created_at
       FROM meditation_sessions WHERE id = $1`,
      [id]
    );
    if (!result.rows[0]) return null;
    return rowToSession(result.rows[0]);
  },

  async create(input: CreateMeditationSessionInput): Promise<MeditationSession> {
    const result = await pool.query<MeditationSessionRow>(
      `INSERT INTO meditation_sessions (type, start_time, duration_minutes, is_completed, notes)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, type, start_time, duration_minutes, is_completed, notes, created_at`,
      [
        input.type,
        input.startTime ? new Date(input.startTime) : new Date(),
        input.durationMinutes,
        input.isCompleted ?? false,
        input.notes || null,
      ]
    );
    return rowToSession(result.rows[0]);
  },

  async update(id: string, input: UpdateMeditationSessionInput): Promise<MeditationSession | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number | boolean | Date | null)[] = [];
    let paramIndex = 1;

    if (input.type !== undefined) {
      updates.push(`type = $${paramIndex++}`);
      values.push(input.type);
    }
    if (input.startTime !== undefined) {
      updates.push(`start_time = $${paramIndex++}`);
      values.push(new Date(input.startTime));
    }
    if (input.durationMinutes !== undefined) {
      updates.push(`duration_minutes = $${paramIndex++}`);
      values.push(input.durationMinutes);
    }
    if (input.isCompleted !== undefined) {
      updates.push(`is_completed = $${paramIndex++}`);
      values.push(input.isCompleted);
    }
    if (input.notes !== undefined) {
      updates.push(`notes = $${paramIndex++}`);
      values.push(input.notes);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE meditation_sessions SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.findById(id);
  },

  async markComplete(id: string): Promise<MeditationSession | null> {
    const existing = await this.findById(id);
    if (!existing) return null;
    await pool.query(
      `UPDATE meditation_sessions SET is_completed = TRUE WHERE id = $1`,
      [id]
    );
    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM meditation_sessions WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(): Promise<MeditationGoal> {
    const result = await pool.query<MeditationGoalRow>(`
      SELECT id, daily_minutes_goal, weekly_sessions_goal, created_at, updated_at
      FROM meditation_goals ORDER BY created_at DESC LIMIT 1
    `);
    if (!result.rows[0]) {
      const insertResult = await pool.query<MeditationGoalRow>(
        `INSERT INTO meditation_goals (daily_minutes_goal, weekly_sessions_goal) VALUES (10, 7)
         RETURNING id, daily_minutes_goal, weekly_sessions_goal, created_at, updated_at`
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(input: UpdateMeditationGoalInput): Promise<MeditationGoal> {
    const goal = await this.getGoal();
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | string)[] = [];
    let paramIndex = 1;

    updates.push(`daily_minutes_goal = $${paramIndex++}`);
    values.push(input.dailyMinutesGoal);

    if (input.weeklySessionsGoal !== undefined) {
      updates.push(`weekly_sessions_goal = $${paramIndex++}`);
      values.push(input.weeklySessionsGoal);
    }

    values.push(goal.id);
    await pool.query(
      `UPDATE meditation_goals SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.getGoal();
  },

  async getStats(): Promise<MeditationStats> {
    const goal = await this.getGoal();

    // Weekly totals
    const weeklyResult = await pool.query<{ total_min: string; total_sessions: string }>(`
      SELECT COALESCE(SUM(duration_minutes), 0) as total_min, COUNT(*) as total_sessions
      FROM meditation_sessions
      WHERE start_time >= CURRENT_DATE - INTERVAL '7 days' AND is_completed = TRUE
    `);

    // Today minutes
    const todayResult = await pool.query<{ total: string }>(`
      SELECT COALESCE(SUM(duration_minutes), 0) as total
      FROM meditation_sessions
      WHERE DATE(start_time) = CURRENT_DATE AND is_completed = TRUE
    `);

    // Sessions by type
    const typeResult = await pool.query<{ type: string; count: string }>(`
      SELECT type, COUNT(*) as count FROM meditation_sessions
      WHERE start_time >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY type
    `);
    const sessionsByType: Record<string, number> = {};
    for (const row of typeResult.rows) {
      sessionsByType[row.type] = parseInt(row.count);
    }

    const { currentStreak, bestStreak } = await this.calculateStreaks(goal.dailyMinutesGoal);

    // Goal completion rate
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE daily_total >= $1) as days_met,
        COUNT(*) as total_days
      FROM (
        SELECT DATE(start_time) as session_date, SUM(duration_minutes) as daily_total
        FROM meditation_sessions
        WHERE start_time >= CURRENT_DATE - INTERVAL '30 days' AND is_completed = TRUE
        GROUP BY DATE(start_time)
      ) daily_totals
    `, [goal.dailyMinutesGoal]);
    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      weeklyMinutes: parseInt(weeklyResult.rows[0].total_min),
      weeklySessions: parseInt(weeklyResult.rows[0].total_sessions),
      currentStreak,
      bestStreak,
      goalCompletionRate,
      sessionsByType,
      todayMinutes: parseInt(todayResult.rows[0].total),
    };
  },

  async calculateStreaks(dailyMinutesGoal: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ session_date: Date; daily_total: string }>(`
      SELECT DATE(start_time) as session_date, SUM(duration_minutes) as daily_total
      FROM meditation_sessions WHERE is_completed = TRUE
      GROUP BY DATE(start_time) ORDER BY session_date DESC
    `);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dateMap = new Map<string, number>();
    for (const row of result.rows) {
      dateMap.set(new Date(row.session_date).toISOString().split('T')[0], parseInt(row.daily_total));
    }

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);
    const todayStr = today.toISOString().split('T')[0];

    if ((dateMap.get(todayStr) || 0) < dailyMinutesGoal) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dStr = checkDate.toISOString().split('T')[0];
      if ((dateMap.get(dStr) || 0) >= dailyMinutesGoal) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    const sortedDates = Array.from(dateMap.keys()).sort();
    for (const d of sortedDates) {
      if ((dateMap.get(d) || 0) >= dailyMinutesGoal) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    bestStreak = Math.max(bestStreak, currentStreak);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(): Promise<MeditationDailySummary[]> {
    const goal = await this.getGoal();
    const summaries: MeditationDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total_min: string; count: string }>(
        `SELECT COALESCE(SUM(duration_minutes), 0) as total_min, COUNT(*) as count
         FROM meditation_sessions WHERE DATE(start_time) = $1 AND is_completed = TRUE`,
        [dateStr]
      );

      const totalMinutes = parseInt(result.rows[0].total_min);
      summaries.push({
        date: dateStr,
        totalMinutes,
        sessionCount: parseInt(result.rows[0].count),
        goalMinutes: goal.dailyMinutesGoal,
        goalMet: totalMinutes >= goal.dailyMinutesGoal,
      });
    }
    return summaries;
  },
};
