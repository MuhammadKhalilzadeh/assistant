import pool from '../config/database';

export interface CalorieEntry {
  id: string;
  foodName: string;
  calories: number;
  mealType: string;
  protein: number | null;
  carbs: number | null;
  fat: number | null;
  foodCategory: string | null;
  servingSize: number | null;
  note: string | null;
  loggedAt: Date;
  createdAt: Date;
}

export interface CalorieEntryRow {
  id: string;
  food_name: string;
  calories: number;
  meal_type: string;
  protein: number | null;
  carbs: number | null;
  fat: number | null;
  food_category: string | null;
  serving_size: number | null;
  note: string | null;
  logged_at: Date;
  created_at: Date;
}

export interface NutritionGoal {
  id: string;
  dailyCalorieGoal: number;
  proteinGoalGrams: number;
  carbsGoalGrams: number;
  fatGoalGrams: number;
  remindersEnabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface NutritionGoalRow {
  id: string;
  daily_calorie_goal: number;
  protein_goal_grams: number;
  carbs_goal_grams: number;
  fat_goal_grams: number;
  reminders_enabled: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface NutritionStats {
  todayCalories: number;
  todayProtein: number;
  todayCarbs: number;
  todayFat: number;
  dailyCalorieGoal: number;
  weeklyAverageCalories: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  avgProtein: number;
  avgCarbs: number;
  avgFat: number;
}

export interface DailyNutritionSummary {
  date: string;
  totalCalories: number;
  goalCalories: number;
  totalProtein: number;
  totalCarbs: number;
  totalFat: number;
  entryCount: number;
  goalMet: boolean;
}

export interface CreateCalorieEntryInput {
  foodName: string;
  calories: number;
  mealType: string;
  protein?: number | null;
  carbs?: number | null;
  fat?: number | null;
  foodCategory?: string | null;
  servingSize?: number | null;
  note?: string | null;
  loggedAt?: string;
}

export interface UpdateCalorieEntryInput {
  foodName?: string;
  calories?: number;
  mealType?: string;
  protein?: number | null;
  carbs?: number | null;
  fat?: number | null;
  foodCategory?: string | null;
  servingSize?: number | null;
  note?: string | null;
  loggedAt?: string;
}

export interface UpdateNutritionGoalInput {
  dailyCalorieGoal: number;
  proteinGoalGrams?: number;
  carbsGoalGrams?: number;
  fatGoalGrams?: number;
  remindersEnabled?: boolean;
}

function rowToEntry(row: CalorieEntryRow): CalorieEntry {
  return {
    id: row.id,
    foodName: row.food_name,
    calories: row.calories,
    mealType: row.meal_type,
    protein: row.protein,
    carbs: row.carbs,
    fat: row.fat,
    foodCategory: row.food_category,
    servingSize: row.serving_size,
    note: row.note,
    loggedAt: row.logged_at,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: NutritionGoalRow): NutritionGoal {
  return {
    id: row.id,
    dailyCalorieGoal: row.daily_calorie_goal,
    proteinGoalGrams: row.protein_goal_grams,
    carbsGoalGrams: row.carbs_goal_grams,
    fatGoalGrams: row.fat_goal_grams,
    remindersEnabled: row.reminders_enabled,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const caloriesModel = {
  async getEntriesForDate(userId: string, date?: string): Promise<CalorieEntry[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<CalorieEntryRow>(`
      SELECT id, food_name, calories, meal_type, protein, carbs, fat, food_category, serving_size, note, logged_at, created_at
      FROM calorie_entries WHERE DATE(logged_at) = $1 AND user_id = $2
      ORDER BY logged_at DESC
    `, [targetDate, userId]);
    return result.rows.map(rowToEntry);
  },

  async findById(userId: string, id: string): Promise<CalorieEntry | null> {
    const result = await pool.query<CalorieEntryRow>(
      `SELECT id, food_name, calories, meal_type, protein, carbs, fat, food_category, serving_size, note, logged_at, created_at
       FROM calorie_entries WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (!result.rows[0]) return null;
    return rowToEntry(result.rows[0]);
  },

  async create(userId: string, input: CreateCalorieEntryInput): Promise<CalorieEntry> {
    const result = await pool.query<CalorieEntryRow>(
      `INSERT INTO calorie_entries (user_id, food_name, calories, meal_type, protein, carbs, fat, food_category, serving_size, note, logged_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING id, food_name, calories, meal_type, protein, carbs, fat, food_category, serving_size, note, logged_at, created_at`,
      [
        userId,
        input.foodName,
        input.calories,
        input.mealType,
        input.protein ?? 0,
        input.carbs ?? 0,
        input.fat ?? 0,
        input.foodCategory || 'other',
        input.servingSize || null,
        input.note || null,
        input.loggedAt ? new Date(input.loggedAt) : new Date(),
      ]
    );
    return rowToEntry(result.rows[0]);
  },

  async update(userId: string, id: string, input: UpdateCalorieEntryInput): Promise<CalorieEntry | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number | Date | null)[] = [];
    let paramIndex = 1;

    if (input.foodName !== undefined) {
      updates.push(`food_name = $${paramIndex++}`);
      values.push(input.foodName);
    }
    if (input.calories !== undefined) {
      updates.push(`calories = $${paramIndex++}`);
      values.push(input.calories);
    }
    if (input.mealType !== undefined) {
      updates.push(`meal_type = $${paramIndex++}`);
      values.push(input.mealType);
    }
    if (input.protein !== undefined) {
      updates.push(`protein = $${paramIndex++}`);
      values.push(input.protein);
    }
    if (input.carbs !== undefined) {
      updates.push(`carbs = $${paramIndex++}`);
      values.push(input.carbs);
    }
    if (input.fat !== undefined) {
      updates.push(`fat = $${paramIndex++}`);
      values.push(input.fat);
    }
    if (input.foodCategory !== undefined) {
      updates.push(`food_category = $${paramIndex++}`);
      values.push(input.foodCategory);
    }
    if (input.servingSize !== undefined) {
      updates.push(`serving_size = $${paramIndex++}`);
      values.push(input.servingSize);
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
    values.push(userId);
    await pool.query(
      `UPDATE calorie_entries SET ${updates.join(', ')} WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1}`,
      values
    );
    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM calorie_entries WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(userId: string): Promise<NutritionGoal> {
    const result = await pool.query<NutritionGoalRow>(`
      SELECT id, daily_calorie_goal, protein_goal_grams, carbs_goal_grams, fat_goal_grams, reminders_enabled, created_at, updated_at
      FROM nutrition_goals WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1
    `, [userId]);
    if (!result.rows[0]) {
      const insertResult = await pool.query<NutritionGoalRow>(
        `INSERT INTO nutrition_goals (user_id, daily_calorie_goal, protein_goal_grams, carbs_goal_grams, fat_goal_grams)
         VALUES ($1, 2000, 50, 250, 65)
         RETURNING id, daily_calorie_goal, protein_goal_grams, carbs_goal_grams, fat_goal_grams, reminders_enabled, created_at, updated_at`,
        [userId]
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(userId: string, input: UpdateNutritionGoalInput): Promise<NutritionGoal> {
    const goal = await this.getGoal(userId);
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | boolean | string)[] = [];
    let paramIndex = 1;

    updates.push(`daily_calorie_goal = $${paramIndex++}`);
    values.push(input.dailyCalorieGoal);

    if (input.proteinGoalGrams !== undefined) {
      updates.push(`protein_goal_grams = $${paramIndex++}`);
      values.push(input.proteinGoalGrams);
    }
    if (input.carbsGoalGrams !== undefined) {
      updates.push(`carbs_goal_grams = $${paramIndex++}`);
      values.push(input.carbsGoalGrams);
    }
    if (input.fatGoalGrams !== undefined) {
      updates.push(`fat_goal_grams = $${paramIndex++}`);
      values.push(input.fatGoalGrams);
    }
    if (input.remindersEnabled !== undefined) {
      updates.push(`reminders_enabled = $${paramIndex++}`);
      values.push(input.remindersEnabled);
    }

    values.push(goal.id);
    values.push(userId);
    await pool.query(
      `UPDATE nutrition_goals SET ${updates.join(', ')} WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1}`,
      values
    );
    return this.getGoal(userId);
  },

  async getStats(userId: string): Promise<NutritionStats> {
    const goal = await this.getGoal(userId);
    const today = new Date().toISOString().split('T')[0];

    // Today's totals
    const todayResult = await pool.query<{ total_cal: string; total_protein: string; total_carbs: string; total_fat: string }>(
      `SELECT COALESCE(SUM(calories), 0) as total_cal,
              COALESCE(SUM(protein), 0) as total_protein,
              COALESCE(SUM(carbs), 0) as total_carbs,
              COALESCE(SUM(fat), 0) as total_fat
       FROM calorie_entries WHERE DATE(logged_at) = $1 AND user_id = $2`,
      [today, userId]
    );

    // Weekly averages
    const weeklyResult = await pool.query<{ avg_cal: string; avg_protein: string; avg_carbs: string; avg_fat: string }>(`
      SELECT COALESCE(AVG(daily_cal), 0) as avg_cal,
             COALESCE(AVG(daily_protein), 0) as avg_protein,
             COALESCE(AVG(daily_carbs), 0) as avg_carbs,
             COALESCE(AVG(daily_fat), 0) as avg_fat
      FROM (
        SELECT DATE(logged_at) as log_date,
               SUM(calories) as daily_cal,
               SUM(protein) as daily_protein,
               SUM(carbs) as daily_carbs,
               SUM(fat) as daily_fat
        FROM calorie_entries
        WHERE logged_at >= CURRENT_DATE - INTERVAL '7 days' AND user_id = $1
        GROUP BY DATE(logged_at)
      ) daily_totals
    `, [userId]);

    const { currentStreak, bestStreak } = await this.calculateStreaks(userId, goal.dailyCalorieGoal);

    // Goal completion rate (within 80-120% of goal)
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE daily_cal >= $1 * 0.8 AND daily_cal <= $1 * 1.2) as days_met,
        COUNT(*) as total_days
      FROM (
        SELECT DATE(logged_at) as log_date, SUM(calories) as daily_cal
        FROM calorie_entries
        WHERE logged_at >= CURRENT_DATE - INTERVAL '30 days' AND user_id = $2
        GROUP BY DATE(logged_at)
      ) daily_totals
    `, [goal.dailyCalorieGoal, userId]);
    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      todayCalories: parseInt(todayResult.rows[0].total_cal),
      todayProtein: parseInt(todayResult.rows[0].total_protein),
      todayCarbs: parseInt(todayResult.rows[0].total_carbs),
      todayFat: parseInt(todayResult.rows[0].total_fat),
      dailyCalorieGoal: goal.dailyCalorieGoal,
      weeklyAverageCalories: Math.round(parseFloat(weeklyResult.rows[0].avg_cal)),
      currentStreak,
      bestStreak,
      goalCompletionRate,
      avgProtein: Math.round(parseFloat(weeklyResult.rows[0].avg_protein)),
      avgCarbs: Math.round(parseFloat(weeklyResult.rows[0].avg_carbs)),
      avgFat: Math.round(parseFloat(weeklyResult.rows[0].avg_fat)),
    };
  },

  async calculateStreaks(userId: string, dailyCalorieGoal: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ log_date: Date; daily_cal: string }>(`
      SELECT DATE(logged_at) as log_date, SUM(calories) as daily_cal
      FROM calorie_entries WHERE user_id = $1 GROUP BY DATE(logged_at) ORDER BY log_date DESC
    `, [userId]);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dateMap = new Map<string, number>();
    for (const row of result.rows) {
      dateMap.set(new Date(row.log_date).toISOString().split('T')[0], parseInt(row.daily_cal));
    }

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);
    const todayStr = today.toISOString().split('T')[0];
    const todayCal = dateMap.get(todayStr) || 0;

    // Goal met = within 80-120% of goal
    const isGoalMet = (cal: number) => cal >= dailyCalorieGoal * 0.8 && cal <= dailyCalorieGoal * 1.2;

    if (!isGoalMet(todayCal)) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dStr = checkDate.toISOString().split('T')[0];
      const cal = dateMap.get(dStr);
      if (cal !== undefined && isGoalMet(cal)) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    const sortedDates = Array.from(dateMap.keys()).sort();
    for (const d of sortedDates) {
      const cal = dateMap.get(d) || 0;
      if (isGoalMet(cal)) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    bestStreak = Math.max(bestStreak, currentStreak);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(userId: string): Promise<DailyNutritionSummary[]> {
    const goal = await this.getGoal(userId);
    const summaries: DailyNutritionSummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ total_cal: string; total_protein: string; total_carbs: string; total_fat: string; count: string }>(
        `SELECT COALESCE(SUM(calories), 0) as total_cal,
                COALESCE(SUM(protein), 0) as total_protein,
                COALESCE(SUM(carbs), 0) as total_carbs,
                COALESCE(SUM(fat), 0) as total_fat,
                COUNT(*) as count
         FROM calorie_entries WHERE DATE(logged_at) = $1 AND user_id = $2`,
        [dateStr, userId]
      );

      const totalCalories = parseInt(result.rows[0].total_cal);
      summaries.push({
        date: dateStr,
        totalCalories,
        goalCalories: goal.dailyCalorieGoal,
        totalProtein: parseInt(result.rows[0].total_protein),
        totalCarbs: parseInt(result.rows[0].total_carbs),
        totalFat: parseInt(result.rows[0].total_fat),
        entryCount: parseInt(result.rows[0].count),
        goalMet: totalCalories >= goal.dailyCalorieGoal * 0.8 && totalCalories <= goal.dailyCalorieGoal * 1.2,
      });
    }
    return summaries;
  },
};
