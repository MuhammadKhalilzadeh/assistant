import pool from '../config/database';

export interface FocusTimerSession {
  id: string;
  type: string;
  startTime: Date;
  endTime: Date | null;
  durationMinutes: number;
  isCompleted: boolean;
  task: string | null;
  createdAt: Date;
}

export interface FocusTimerSessionRow {
  id: string;
  type: string;
  start_time: Date;
  end_time: Date | null;
  duration_minutes: number;
  is_completed: boolean;
  task: string | null;
  created_at: Date;
}

export interface FocusTimerGoal {
  id: string;
  dailyGoalSessions: number;
  focusDuration: number;
  shortBreakDuration: number;
  longBreakDuration: number;
  sessionsBeforeLongBreak: number;
  autoStartBreaks: boolean;
  autoStartFocus: boolean;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface FocusTimerGoalRow {
  id: string;
  daily_goal_sessions: number;
  focus_duration: number;
  short_break_duration: number;
  long_break_duration: number;
  sessions_before_long_break: number;
  auto_start_breaks: boolean;
  auto_start_focus: boolean;
  sound_enabled: boolean;
  vibration_enabled: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface FocusTimerStats {
  todaySessions: number;
  todayMinutes: number;
  weeklySessions: number;
  weeklyMinutes: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  sessionsByType: Record<string, number>;
}

export interface FocusTimerDailySummary {
  date: string;
  totalMinutes: number;
  sessionCount: number;
  goalSessions: number;
  goalMet: boolean;
}

export interface CreateFocusTimerSessionInput {
  type: string;
  startTime?: string;
  endTime?: string | null;
  durationMinutes: number;
  isCompleted?: boolean;
  task?: string | null;
}

export interface UpdateFocusTimerSessionInput {
  type?: string;
  startTime?: string;
  endTime?: string | null;
  durationMinutes?: number;
  isCompleted?: boolean;
  task?: string | null;
}

export interface UpdateFocusTimerGoalInput {
  dailyGoalSessions?: number;
  focusDuration?: number;
  shortBreakDuration?: number;
  longBreakDuration?: number;
  sessionsBeforeLongBreak?: number;
  autoStartBreaks?: boolean;
  autoStartFocus?: boolean;
  soundEnabled?: boolean;
  vibrationEnabled?: boolean;
}

function rowToSession(row: FocusTimerSessionRow): FocusTimerSession {
  return {
    id: row.id,
    type: row.type,
    startTime: row.start_time,
    endTime: row.end_time,
    durationMinutes: row.duration_minutes,
    isCompleted: row.is_completed,
    task: row.task,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: FocusTimerGoalRow): FocusTimerGoal {
  return {
    id: row.id,
    dailyGoalSessions: row.daily_goal_sessions,
    focusDuration: row.focus_duration,
    shortBreakDuration: row.short_break_duration,
    longBreakDuration: row.long_break_duration,
    sessionsBeforeLongBreak: row.sessions_before_long_break,
    autoStartBreaks: row.auto_start_breaks,
    autoStartFocus: row.auto_start_focus,
    soundEnabled: row.sound_enabled,
    vibrationEnabled: row.vibration_enabled,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const focusTimerModel = {
  async getSessionsForDate(date?: string): Promise<FocusTimerSession[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<FocusTimerSessionRow>(`
      SELECT id, type, start_time, end_time, duration_minutes, is_completed, task, created_at
      FROM focus_timer_sessions WHERE DATE(start_time) = $1
      ORDER BY start_time DESC
    `, [targetDate]);
    return result.rows.map(rowToSession);
  },

  async findById(id: string): Promise<FocusTimerSession | null> {
    const result = await pool.query<FocusTimerSessionRow>(
      `SELECT id, type, start_time, end_time, duration_minutes, is_completed, task, created_at
       FROM focus_timer_sessions WHERE id = $1`,
      [id]
    );
    if (!result.rows[0]) return null;
    return rowToSession(result.rows[0]);
  },

  async create(input: CreateFocusTimerSessionInput): Promise<FocusTimerSession> {
    const result = await pool.query<FocusTimerSessionRow>(
      `INSERT INTO focus_timer_sessions (type, start_time, end_time, duration_minutes, is_completed, task)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, type, start_time, end_time, duration_minutes, is_completed, task, created_at`,
      [
        input.type,
        input.startTime ? new Date(input.startTime) : new Date(),
        input.endTime ? new Date(input.endTime) : null,
        input.durationMinutes,
        input.isCompleted ?? false,
        input.task || null,
      ]
    );
    return rowToSession(result.rows[0]);
  },

  async update(id: string, input: UpdateFocusTimerSessionInput): Promise<FocusTimerSession | null> {
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
    if (input.endTime !== undefined) {
      updates.push(`end_time = $${paramIndex++}`);
      values.push(input.endTime ? new Date(input.endTime) : null);
    }
    if (input.durationMinutes !== undefined) {
      updates.push(`duration_minutes = $${paramIndex++}`);
      values.push(input.durationMinutes);
    }
    if (input.isCompleted !== undefined) {
      updates.push(`is_completed = $${paramIndex++}`);
      values.push(input.isCompleted);
    }
    if (input.task !== undefined) {
      updates.push(`task = $${paramIndex++}`);
      values.push(input.task);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE focus_timer_sessions SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.findById(id);
  },

  async markComplete(id: string): Promise<FocusTimerSession | null> {
    const existing = await this.findById(id);
    if (!existing) return null;
    await pool.query(
      `UPDATE focus_timer_sessions SET is_completed = TRUE, end_time = CURRENT_TIMESTAMP WHERE id = $1`,
      [id]
    );
    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM focus_timer_sessions WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(): Promise<FocusTimerGoal> {
    const result = await pool.query<FocusTimerGoalRow>(`
      SELECT id, daily_goal_sessions, focus_duration, short_break_duration, long_break_duration,
             sessions_before_long_break, auto_start_breaks, auto_start_focus,
             sound_enabled, vibration_enabled, created_at, updated_at
      FROM focus_timer_goals ORDER BY created_at DESC LIMIT 1
    `);
    if (!result.rows[0]) {
      const insertResult = await pool.query<FocusTimerGoalRow>(
        `INSERT INTO focus_timer_goals (daily_goal_sessions, focus_duration, short_break_duration, long_break_duration, sessions_before_long_break)
         VALUES (8, 25, 5, 15, 4)
         RETURNING id, daily_goal_sessions, focus_duration, short_break_duration, long_break_duration,
                   sessions_before_long_break, auto_start_breaks, auto_start_focus,
                   sound_enabled, vibration_enabled, created_at, updated_at`
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(input: UpdateFocusTimerGoalInput): Promise<FocusTimerGoal> {
    const goal = await this.getGoal();
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | boolean | string)[] = [];
    let paramIndex = 1;

    if (input.dailyGoalSessions !== undefined) {
      updates.push(`daily_goal_sessions = $${paramIndex++}`);
      values.push(input.dailyGoalSessions);
    }
    if (input.focusDuration !== undefined) {
      updates.push(`focus_duration = $${paramIndex++}`);
      values.push(input.focusDuration);
    }
    if (input.shortBreakDuration !== undefined) {
      updates.push(`short_break_duration = $${paramIndex++}`);
      values.push(input.shortBreakDuration);
    }
    if (input.longBreakDuration !== undefined) {
      updates.push(`long_break_duration = $${paramIndex++}`);
      values.push(input.longBreakDuration);
    }
    if (input.sessionsBeforeLongBreak !== undefined) {
      updates.push(`sessions_before_long_break = $${paramIndex++}`);
      values.push(input.sessionsBeforeLongBreak);
    }
    if (input.autoStartBreaks !== undefined) {
      updates.push(`auto_start_breaks = $${paramIndex++}`);
      values.push(input.autoStartBreaks);
    }
    if (input.autoStartFocus !== undefined) {
      updates.push(`auto_start_focus = $${paramIndex++}`);
      values.push(input.autoStartFocus);
    }
    if (input.soundEnabled !== undefined) {
      updates.push(`sound_enabled = $${paramIndex++}`);
      values.push(input.soundEnabled);
    }
    if (input.vibrationEnabled !== undefined) {
      updates.push(`vibration_enabled = $${paramIndex++}`);
      values.push(input.vibrationEnabled);
    }

    if (values.length === 0) return goal;

    values.push(goal.id);
    await pool.query(
      `UPDATE focus_timer_goals SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.getGoal();
  },

  async getStats(): Promise<FocusTimerStats> {
    const goal = await this.getGoal();

    // Today totals
    const todayResult = await pool.query<{ total_min: string; total_sessions: string }>(`
      SELECT COALESCE(SUM(duration_minutes), 0) as total_min, COUNT(*) as total_sessions
      FROM focus_timer_sessions
      WHERE DATE(start_time) = CURRENT_DATE AND is_completed = TRUE AND type = 'focus'
    `);

    // Weekly totals
    const weeklyResult = await pool.query<{ total_min: string; total_sessions: string }>(`
      SELECT COALESCE(SUM(duration_minutes), 0) as total_min, COUNT(*) as total_sessions
      FROM focus_timer_sessions
      WHERE start_time >= CURRENT_DATE - INTERVAL '7 days' AND is_completed = TRUE AND type = 'focus'
    `);

    // Sessions by type
    const typeResult = await pool.query<{ type: string; count: string }>(`
      SELECT type, COUNT(*) as count FROM focus_timer_sessions
      WHERE start_time >= CURRENT_DATE - INTERVAL '7 days' AND is_completed = TRUE
      GROUP BY type
    `);
    const sessionsByType: Record<string, number> = {};
    for (const row of typeResult.rows) {
      sessionsByType[row.type] = parseInt(row.count);
    }

    const { currentStreak, bestStreak } = await this.calculateStreaks(goal.dailyGoalSessions);

    // Goal completion rate
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE daily_total >= $1) as days_met,
        COUNT(*) as total_days
      FROM (
        SELECT DATE(start_time) as session_date, COUNT(*) as daily_total
        FROM focus_timer_sessions
        WHERE start_time >= CURRENT_DATE - INTERVAL '30 days' AND is_completed = TRUE AND type = 'focus'
        GROUP BY DATE(start_time)
      ) daily_totals
    `, [goal.dailyGoalSessions]);
    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      todaySessions: parseInt(todayResult.rows[0].total_sessions),
      todayMinutes: parseInt(todayResult.rows[0].total_min),
      weeklySessions: parseInt(weeklyResult.rows[0].total_sessions),
      weeklyMinutes: parseInt(weeklyResult.rows[0].total_min),
      currentStreak,
      bestStreak,
      goalCompletionRate,
      sessionsByType,
    };
  },

  async calculateStreaks(dailyGoalSessions: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ session_date: Date; daily_total: string }>(`
      SELECT DATE(start_time) as session_date, COUNT(*) as daily_total
      FROM focus_timer_sessions WHERE is_completed = TRUE AND type = 'focus'
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

    if ((dateMap.get(todayStr) || 0) < dailyGoalSessions) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dStr = checkDate.toISOString().split('T')[0];
      if ((dateMap.get(dStr) || 0) >= dailyGoalSessions) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    const sortedDates = Array.from(dateMap.keys()).sort();
    for (const d of sortedDates) {
      if ((dateMap.get(d) || 0) >= dailyGoalSessions) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    bestStreak = Math.max(bestStreak, currentStreak);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(): Promise<FocusTimerDailySummary[]> {
    const goal = await this.getGoal();
    const summaries: FocusTimerDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total_min: string; count: string }>(
        `SELECT COALESCE(SUM(duration_minutes), 0) as total_min, COUNT(*) as count
         FROM focus_timer_sessions WHERE DATE(start_time) = $1 AND is_completed = TRUE AND type = 'focus'`,
        [dateStr]
      );

      const totalMinutes = parseInt(result.rows[0].total_min);
      const sessionCount = parseInt(result.rows[0].count);
      summaries.push({
        date: dateStr,
        totalMinutes,
        sessionCount,
        goalSessions: goal.dailyGoalSessions,
        goalMet: sessionCount >= goal.dailyGoalSessions,
      });
    }
    return summaries;
  },
};
