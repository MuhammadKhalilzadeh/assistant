import pool from '../config/database';

export interface Exercise {
  name: string;
  sets: number;
  reps: number;
  weight: number | null;
}

export interface WorkoutSession {
  id: string;
  type: string;
  startTime: Date;
  endTime: Date | null;
  durationMinutes: number;
  caloriesBurned: number;
  exercises: Exercise[];
  notes: string | null;
  createdAt: Date;
}

export interface WorkoutSessionRow {
  id: string;
  type: string;
  start_time: Date;
  end_time: Date | null;
  duration_minutes: number;
  calories_burned: number;
  exercises: Exercise[];
  notes: string | null;
  created_at: Date;
}

export interface WorkoutGoal {
  id: string;
  weeklyMinutesGoal: number;
  weeklySessionsGoal: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface WorkoutGoalRow {
  id: string;
  weekly_minutes_goal: number;
  weekly_sessions_goal: number;
  created_at: Date;
  updated_at: Date;
}

export interface WorkoutStats {
  weeklyMinutes: number;
  weeklySessions: number;
  weeklyCalories: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  workoutsByType: Record<string, number>;
}

export interface WorkoutDailySummary {
  date: string;
  totalMinutes: number;
  totalCalories: number;
  sessionCount: number;
  goalMet: boolean;
}

export interface CreateWorkoutSessionInput {
  type: string;
  startTime?: string;
  endTime?: string | null;
  durationMinutes?: number;
  caloriesBurned?: number;
  exercises?: Exercise[];
  notes?: string | null;
}

export interface UpdateWorkoutSessionInput {
  type?: string;
  startTime?: string;
  endTime?: string | null;
  durationMinutes?: number;
  caloriesBurned?: number;
  exercises?: Exercise[];
  notes?: string | null;
}

export interface UpdateWorkoutGoalInput {
  weeklyMinutesGoal: number;
  weeklySessionsGoal?: number;
}

function rowToSession(row: WorkoutSessionRow): WorkoutSession {
  return {
    id: row.id,
    type: row.type,
    startTime: row.start_time,
    endTime: row.end_time,
    durationMinutes: row.duration_minutes,
    caloriesBurned: row.calories_burned,
    exercises: row.exercises || [],
    notes: row.notes,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: WorkoutGoalRow): WorkoutGoal {
  return {
    id: row.id,
    weeklyMinutesGoal: row.weekly_minutes_goal,
    weeklySessionsGoal: row.weekly_sessions_goal,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const workoutModel = {
  async getSessionsForDate(userId: string, date?: string): Promise<WorkoutSession[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<WorkoutSessionRow>(`
      SELECT id, type, start_time, end_time, duration_minutes, calories_burned, exercises, notes, created_at
      FROM workout_sessions WHERE DATE(start_time) = $1 AND user_id = $2
      ORDER BY start_time DESC
    `, [targetDate, userId]);
    return result.rows.map(rowToSession);
  },

  async findById(userId: string, id: string): Promise<WorkoutSession | null> {
    const result = await pool.query<WorkoutSessionRow>(
      `SELECT id, type, start_time, end_time, duration_minutes, calories_burned, exercises, notes, created_at
       FROM workout_sessions WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!result.rows[0]) return null;
    return rowToSession(result.rows[0]);
  },

  async create(userId: string, input: CreateWorkoutSessionInput): Promise<WorkoutSession> {
    const result = await pool.query<WorkoutSessionRow>(
      `INSERT INTO workout_sessions (user_id, type, start_time, end_time, duration_minutes, calories_burned, exercises, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, type, start_time, end_time, duration_minutes, calories_burned, exercises, notes, created_at`,
      [
        userId,
        input.type,
        input.startTime ? new Date(input.startTime) : new Date(),
        input.endTime ? new Date(input.endTime) : null,
        input.durationMinutes || 0,
        input.caloriesBurned || 0,
        JSON.stringify(input.exercises || []),
        input.notes || null,
      ]
    );
    return rowToSession(result.rows[0]);
  },

  async update(userId: string, id: string, input: UpdateWorkoutSessionInput): Promise<WorkoutSession | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number | Date | null)[] = [];
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
    if (input.caloriesBurned !== undefined) {
      updates.push(`calories_burned = $${paramIndex++}`);
      values.push(input.caloriesBurned);
    }
    if (input.exercises !== undefined) {
      updates.push(`exercises = $${paramIndex++}`);
      values.push(JSON.stringify(input.exercises));
    }
    if (input.notes !== undefined) {
      updates.push(`notes = $${paramIndex++}`);
      values.push(input.notes);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    values.push(userId);
    await pool.query(
      `UPDATE workout_sessions SET ${updates.join(', ')} WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1}`,
      values
    );
    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM workout_sessions WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(userId: string): Promise<WorkoutGoal> {
    const result = await pool.query<WorkoutGoalRow>(`
      SELECT id, weekly_minutes_goal, weekly_sessions_goal, created_at, updated_at
      FROM workout_goals WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1
    `, [userId]);
    if (!result.rows[0]) {
      const insertResult = await pool.query<WorkoutGoalRow>(
        `INSERT INTO workout_goals (user_id, weekly_minutes_goal, weekly_sessions_goal) VALUES ($1, 150, 5)
         RETURNING id, weekly_minutes_goal, weekly_sessions_goal, created_at, updated_at`,
        [userId]
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(userId: string, input: UpdateWorkoutGoalInput): Promise<WorkoutGoal> {
    const goal = await this.getGoal(userId);
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | string)[] = [];
    let paramIndex = 1;

    updates.push(`weekly_minutes_goal = $${paramIndex++}`);
    values.push(input.weeklyMinutesGoal);

    if (input.weeklySessionsGoal !== undefined) {
      updates.push(`weekly_sessions_goal = $${paramIndex++}`);
      values.push(input.weeklySessionsGoal);
    }

    values.push(goal.id);
    values.push(userId);
    await pool.query(
      `UPDATE workout_goals SET ${updates.join(', ')} WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1}`,
      values
    );
    return this.getGoal(userId);
  },

  async getStats(userId: string): Promise<WorkoutStats> {
    const goal = await this.getGoal(userId);

    const weeklyResult = await pool.query<{ total_min: string; total_sessions: string; total_cal: string }>(`
      SELECT COALESCE(SUM(duration_minutes), 0) as total_min,
             COUNT(*) as total_sessions,
             COALESCE(SUM(calories_burned), 0) as total_cal
      FROM workout_sessions WHERE start_time >= CURRENT_DATE - INTERVAL '7 days' AND user_id = $1
    `, [userId]);

    const typeResult = await pool.query<{ type: string; count: string }>(`
      SELECT type, COUNT(*) as count FROM workout_sessions
      WHERE start_time >= CURRENT_DATE - INTERVAL '7 days' AND user_id = $1 GROUP BY type
    `, [userId]);
    const workoutsByType: Record<string, number> = {};
    for (const row of typeResult.rows) {
      workoutsByType[row.type] = parseInt(row.count);
    }

    const { currentStreak, bestStreak } = await this.calculateStreaks(userId);

    const weeklyMinutes = parseInt(weeklyResult.rows[0].total_min);
    const goalCompletionRate = goal.weeklyMinutesGoal > 0
      ? Math.round((weeklyMinutes / goal.weeklyMinutesGoal) * 100) / 100
      : 0;

    return {
      weeklyMinutes,
      weeklySessions: parseInt(weeklyResult.rows[0].total_sessions),
      weeklyCalories: parseInt(weeklyResult.rows[0].total_cal),
      currentStreak,
      bestStreak,
      goalCompletionRate: Math.min(goalCompletionRate, 1),
      workoutsByType,
    };
  },

  async calculateStreaks(userId: string): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ workout_date: Date }>(`
      SELECT DISTINCT DATE(start_time) as workout_date
      FROM workout_sessions WHERE user_id = $1 ORDER BY workout_date DESC
    `, [userId]);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dates = result.rows.map(r => new Date(r.workout_date).toISOString().split('T')[0]);
    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 1;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);
    const todayStr = today.toISOString().split('T')[0];

    if (!dates.includes(todayStr)) {
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      if (!dates.includes(yesterday.toISOString().split('T')[0])) {
        const sortedDates = [...dates].sort();
        for (let i = 1; i < sortedDates.length; i++) {
          const prev = new Date(sortedDates[i - 1]);
          const curr = new Date(sortedDates[i]);
          const diff = Math.round((curr.getTime() - prev.getTime()) / (1000 * 60 * 60 * 24));
          if (diff === 1) tempStreak++;
          else tempStreak = 1;
          bestStreak = Math.max(bestStreak, tempStreak);
        }
        return { currentStreak: 0, bestStreak: Math.max(bestStreak, 1) };
      }
      checkDate.setDate(checkDate.getDate() - 1);
    }

    for (const dateStr of dates) {
      const dStr = checkDate.toISOString().split('T')[0];
      if (dateStr === dStr) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    tempStreak = 1;
    const sortedDates = [...dates].sort();
    for (let i = 1; i < sortedDates.length; i++) {
      const prev = new Date(sortedDates[i - 1]);
      const curr = new Date(sortedDates[i]);
      const diff = Math.round((curr.getTime() - prev.getTime()) / (1000 * 60 * 60 * 24));
      if (diff === 1) tempStreak++;
      else tempStreak = 1;
      bestStreak = Math.max(bestStreak, tempStreak);
    }
    bestStreak = Math.max(bestStreak, currentStreak, 1);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(userId: string): Promise<WorkoutDailySummary[]> {
    const goal = await this.getGoal(userId);
    const dailyGoalMinutes = Math.round(goal.weeklyMinutesGoal / 7);
    const summaries: WorkoutDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total_min: string; total_cal: string; count: string }>(
        `SELECT COALESCE(SUM(duration_minutes), 0) as total_min,
                COALESCE(SUM(calories_burned), 0) as total_cal,
                COUNT(*) as count
         FROM workout_sessions WHERE DATE(start_time) = $1 AND user_id = $2`,
        [dateStr, userId]
      );

      const totalMinutes = parseInt(result.rows[0].total_min);
      summaries.push({
        date: dateStr,
        totalMinutes,
        totalCalories: parseInt(result.rows[0].total_cal),
        sessionCount: parseInt(result.rows[0].count),
        goalMet: totalMinutes >= dailyGoalMinutes,
      });
    }
    return summaries;
  },
};
