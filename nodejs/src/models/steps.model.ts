import pool from '../config/database';

export interface StepRecord {
  id: string;
  date: string;
  steps: number;
  goal: number;
  distanceKm: number;
  caloriesBurned: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface StepRecordRow {
  id: string;
  date: Date;
  steps: number;
  goal: number;
  distance_km: number;
  calories_burned: number;
  created_at: Date;
  updated_at: Date;
}

export interface StepsGoal {
  id: string;
  dailyGoal: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface StepsGoalRow {
  id: string;
  daily_goal: number;
  created_at: Date;
  updated_at: Date;
}

export interface StepsStats {
  todaySteps: number;
  dailyGoal: number;
  weeklyAverageSteps: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  totalDistanceKm: number;
  totalCaloriesBurned: number;
}

export interface StepsDailySummary {
  date: string;
  steps: number;
  goal: number;
  goalMet: boolean;
  distanceKm: number;
  caloriesBurned: number;
}

export interface CreateStepRecordInput {
  date: string;
  steps: number;
  goal?: number;
  distanceKm?: number;
  caloriesBurned?: number;
}

export interface UpdateStepRecordInput {
  steps?: number;
  goal?: number;
  distanceKm?: number;
  caloriesBurned?: number;
}

export interface UpdateStepsGoalInput {
  dailyGoal: number;
}

function rowToRecord(row: StepRecordRow): StepRecord {
  return {
    id: row.id,
    date: new Date(row.date).toISOString().split('T')[0],
    steps: row.steps,
    goal: row.goal,
    distanceKm: row.distance_km,
    caloriesBurned: row.calories_burned,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function rowToGoal(row: StepsGoalRow): StepsGoal {
  return {
    id: row.id,
    dailyGoal: row.daily_goal,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const stepsModel = {
  async getRecordForDate(userId: string, date?: string): Promise<StepRecord | null> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<StepRecordRow>(
      `SELECT id, date, steps, goal, distance_km, calories_burned, created_at, updated_at
       FROM step_records WHERE user_id = $1 AND date = $2`,
      [userId, targetDate]
    );
    if (!result.rows[0]) return null;
    return rowToRecord(result.rows[0]);
  },

  async findById(userId: string, id: string): Promise<StepRecord | null> {
    const result = await pool.query<StepRecordRow>(
      `SELECT id, date, steps, goal, distance_km, calories_burned, created_at, updated_at
       FROM step_records WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!result.rows[0]) return null;
    return rowToRecord(result.rows[0]);
  },

  async create(userId: string, input: CreateStepRecordInput): Promise<StepRecord> {
    const goal = input.goal || (await this.getGoal(userId)).dailyGoal;
    const distanceKm = input.distanceKm ?? (input.steps * 0.0008);
    const caloriesBurned = input.caloriesBurned ?? Math.round(input.steps * 0.04);

    // Upsert: insert or update if date already exists for this user
    const result = await pool.query<StepRecordRow>(
      `INSERT INTO step_records (user_id, date, steps, goal, distance_km, calories_burned)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (user_id, date) DO UPDATE SET
         steps = $3, goal = $4, distance_km = $5, calories_burned = $6,
         updated_at = CURRENT_TIMESTAMP
       RETURNING id, date, steps, goal, distance_km, calories_burned, created_at, updated_at`,
      [userId, input.date, input.steps, goal, distanceKm, caloriesBurned]
    );
    return rowToRecord(result.rows[0]);
  },

  async addSteps(userId: string, stepsToAdd: number): Promise<StepRecord> {
    const today = new Date().toISOString().split('T')[0];
    const goal = (await this.getGoal(userId)).dailyGoal;
    const existing = await this.getRecordForDate(userId, today);
    const newSteps = (existing?.steps || 0) + stepsToAdd;
    const distanceKm = newSteps * 0.0008;
    const caloriesBurned = Math.round(newSteps * 0.04);

    const result = await pool.query<StepRecordRow>(
      `INSERT INTO step_records (user_id, date, steps, goal, distance_km, calories_burned)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (user_id, date) DO UPDATE SET
         steps = $3, goal = $4, distance_km = $5, calories_burned = $6,
         updated_at = CURRENT_TIMESTAMP
       RETURNING id, date, steps, goal, distance_km, calories_burned, created_at, updated_at`,
      [userId, today, newSteps, goal, distanceKm, caloriesBurned]
    );
    return rowToRecord(result.rows[0]);
  },

  async update(userId: string, id: string, input: UpdateStepRecordInput): Promise<StepRecord | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | string)[] = [];
    let paramIndex = 1;

    if (input.steps !== undefined) {
      updates.push(`steps = $${paramIndex++}`);
      values.push(input.steps);
    }
    if (input.goal !== undefined) {
      updates.push(`goal = $${paramIndex++}`);
      values.push(input.goal);
    }
    if (input.distanceKm !== undefined) {
      updates.push(`distance_km = $${paramIndex++}`);
      values.push(input.distanceKm);
    }
    if (input.caloriesBurned !== undefined) {
      updates.push(`calories_burned = $${paramIndex++}`);
      values.push(input.caloriesBurned);
    }

    values.push(id);
    values.push(userId);
    await pool.query(
      `UPDATE step_records SET ${updates.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex}`,
      values
    );
    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM step_records WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(userId: string): Promise<StepsGoal> {
    const result = await pool.query<StepsGoalRow>(`
      SELECT id, daily_goal, created_at, updated_at
      FROM steps_goals WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1
    `, [userId]);
    if (!result.rows[0]) {
      const insertResult = await pool.query<StepsGoalRow>(
        `INSERT INTO steps_goals (user_id, daily_goal) VALUES ($1, 10000)
         RETURNING id, daily_goal, created_at, updated_at`,
        [userId]
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(userId: string, input: UpdateStepsGoalInput): Promise<StepsGoal> {
    const goal = await this.getGoal(userId);
    await pool.query(
      `UPDATE steps_goals SET daily_goal = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND user_id = $3`,
      [input.dailyGoal, goal.id, userId]
    );
    return this.getGoal(userId);
  },

  async getStats(userId: string): Promise<StepsStats> {
    const goal = await this.getGoal(userId);
    const today = new Date().toISOString().split('T')[0];

    const todayRecord = await this.getRecordForDate(userId, today);
    const todaySteps = todayRecord?.steps || 0;

    const weeklyResult = await pool.query<{ avg: string; total_dist: string; total_cal: string }>(`
      SELECT COALESCE(AVG(steps), 0) as avg,
             COALESCE(SUM(distance_km), 0) as total_dist,
             COALESCE(SUM(calories_burned), 0) as total_cal
      FROM step_records WHERE user_id = $1 AND date >= CURRENT_DATE - INTERVAL '7 days'
    `, [userId]);

    const { currentStreak, bestStreak } = await this.calculateStreaks(userId, goal.dailyGoal);

    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT COUNT(*) FILTER (WHERE steps >= goal) as days_met, COUNT(*) as total_days
      FROM step_records WHERE user_id = $1 AND date >= CURRENT_DATE - INTERVAL '30 days'
    `, [userId]);
    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      todaySteps,
      dailyGoal: goal.dailyGoal,
      weeklyAverageSteps: Math.round(parseFloat(weeklyResult.rows[0].avg)),
      currentStreak,
      bestStreak,
      goalCompletionRate,
      totalDistanceKm: Math.round(parseFloat(weeklyResult.rows[0].total_dist) * 100) / 100,
      totalCaloriesBurned: Math.round(parseFloat(weeklyResult.rows[0].total_cal)),
    };
  },

  async calculateStreaks(userId: string, dailyGoal: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ date: Date; steps: number }>(`
      SELECT date, steps FROM step_records WHERE user_id = $1 ORDER BY date DESC
    `, [userId]);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);

    const dateMap = new Map<string, number>();
    for (const row of result.rows) {
      dateMap.set(new Date(row.date).toISOString().split('T')[0], row.steps);
    }

    const todayStr = today.toISOString().split('T')[0];
    if ((dateMap.get(todayStr) || 0) < dailyGoal) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dStr = checkDate.toISOString().split('T')[0];
      if ((dateMap.get(dStr) || 0) >= dailyGoal) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    const sortedDates = Array.from(dateMap.keys()).sort();
    for (const d of sortedDates) {
      if ((dateMap.get(d) || 0) >= dailyGoal) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }

    return { currentStreak, bestStreak };
  },

  async getLast7Days(userId: string): Promise<StepsDailySummary[]> {
    const goal = await this.getGoal(userId);
    const summaries: StepsDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      const record = await this.getRecordForDate(userId, dateStr);

      summaries.push({
        date: dateStr,
        steps: record?.steps || 0,
        goal: record?.goal || goal.dailyGoal,
        goalMet: (record?.steps || 0) >= (record?.goal || goal.dailyGoal),
        distanceKm: record?.distanceKm || 0,
        caloriesBurned: record?.caloriesBurned || 0,
      });
    }
    return summaries;
  },
};
