import pool from '../config/database';

/**
 * Convert JavaScript's day of week (0=Sunday, 6=Saturday) to
 * ISO convention (0=Monday, 6=Sunday) used by the Flutter frontend.
 */
function jsToIsoDay(jsDay: number): number {
  return (jsDay + 6) % 7;
}

export interface Habit {
  id: string;
  name: string;
  description: string | null;
  icon: string;
  category: string;
  frequency: string;
  targetDays: number[];
  streak: number;
  bestStreak: number;
  completedDates: string[];
  isCompletedToday: boolean;
  createdAt: Date;
}

export interface HabitRow {
  id: string;
  name: string;
  description: string | null;
  icon: string;
  category: string;
  frequency: string;
  target_days: number[];
  streak: number;
  best_streak: number;
  created_at: Date;
}

export interface CreateHabitInput {
  name: string;
  description?: string | null;
  icon?: string;
  category?: string;
  frequency?: string;
  targetDays?: number[];
}

export interface UpdateHabitInput {
  name?: string;
  description?: string | null;
  icon?: string;
  category?: string;
  frequency?: string;
  targetDays?: number[];
}

function rowToHabit(row: HabitRow, completedDates: string[] = [], isCompletedToday: boolean = false): Habit {
  return {
    id: row.id,
    name: row.name,
    description: row.description,
    icon: row.icon,
    category: row.category,
    frequency: row.frequency,
    targetDays: row.target_days,
    streak: row.streak,
    bestStreak: row.best_streak,
    completedDates,
    isCompletedToday,
    createdAt: row.created_at,
  };
}

export const habitModel = {
  async findAll(): Promise<Habit[]> {
    const result = await pool.query<HabitRow>(`
      SELECT id, name, description, icon, category, frequency, target_days, streak, best_streak, created_at
      FROM habits
      ORDER BY created_at DESC
    `);

    const habits: Habit[] = [];

    for (const row of result.rows) {
      const completionsResult = await pool.query<{ completed_date: Date }>(
        `SELECT completed_date FROM habit_completions WHERE habit_id = $1 ORDER BY completed_date DESC`,
        [row.id]
      );

      const completedDates = completionsResult.rows.map(r => {
        const date = new Date(r.completed_date);
        return date.toISOString().split('T')[0];
      });

      const today = new Date().toISOString().split('T')[0];
      const isCompletedToday = completedDates.includes(today);

      habits.push(rowToHabit(row, completedDates, isCompletedToday));
    }

    return habits;
  },

  async findById(id: string): Promise<Habit | null> {
    const result = await pool.query<HabitRow>(
      `SELECT id, name, description, icon, category, frequency, target_days, streak, best_streak, created_at
       FROM habits WHERE id = $1`,
      [id]
    );

    if (!result.rows[0]) return null;

    const row = result.rows[0];
    const completionsResult = await pool.query<{ completed_date: Date }>(
      `SELECT completed_date FROM habit_completions WHERE habit_id = $1 ORDER BY completed_date DESC`,
      [id]
    );

    const completedDates = completionsResult.rows.map(r => {
      const date = new Date(r.completed_date);
      return date.toISOString().split('T')[0];
    });

    const today = new Date().toISOString().split('T')[0];
    const isCompletedToday = completedDates.includes(today);

    return rowToHabit(row, completedDates, isCompletedToday);
  },

  async create(input: CreateHabitInput): Promise<Habit> {
    const result = await pool.query<{ id: string }>(
      `INSERT INTO habits (name, description, icon, category, frequency, target_days)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id`,
      [
        input.name,
        input.description || null,
        input.icon || 'check_circle',
        input.category || 'other',
        input.frequency || 'daily',
        input.targetDays || [0, 1, 2, 3, 4, 5, 6],
      ]
    );
    const habit = await this.findById(result.rows[0].id);
    return habit!;
  },

  async update(id: string, input: UpdateHabitInput): Promise<Habit | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | number[] | null)[] = [];
    let paramIndex = 1;

    if (input.name !== undefined) {
      updates.push(`name = $${paramIndex++}`);
      values.push(input.name);
    }
    if (input.description !== undefined) {
      updates.push(`description = $${paramIndex++}`);
      values.push(input.description);
    }
    if (input.icon !== undefined) {
      updates.push(`icon = $${paramIndex++}`);
      values.push(input.icon);
    }
    if (input.category !== undefined) {
      updates.push(`category = $${paramIndex++}`);
      values.push(input.category);
    }
    if (input.frequency !== undefined) {
      updates.push(`frequency = $${paramIndex++}`);
      values.push(input.frequency);
    }
    if (input.targetDays !== undefined) {
      updates.push(`target_days = $${paramIndex++}`);
      values.push(input.targetDays);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE habits SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );

    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM habits WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async toggleComplete(id: string): Promise<Habit | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const today = new Date().toISOString().split('T')[0];

    // Check if completion exists for today
    const existingCompletion = await pool.query(
      `SELECT id FROM habit_completions WHERE habit_id = $1 AND completed_date = $2`,
      [id, today]
    );

    if (existingCompletion.rows.length > 0) {
      // Delete existing completion (un-complete)
      await pool.query(
        `DELETE FROM habit_completions WHERE habit_id = $1 AND completed_date = $2`,
        [id, today]
      );
    } else {
      // Insert new completion
      await pool.query(
        `INSERT INTO habit_completions (habit_id, completed_date) VALUES ($1, $2)`,
        [id, today]
      );
    }

    // Recalculate streak
    const streak = await this.calculateStreak(id);

    // Update best_streak if current streak exceeds it
    await pool.query(
      `UPDATE habits SET streak = $1, best_streak = GREATEST(best_streak, $1) WHERE id = $2`,
      [streak, id]
    );

    return this.findById(id);
  },

  async calculateStreak(habitId: string): Promise<number> {
    // Get all completion dates for this habit, ordered by date descending
    const result = await pool.query<{ completed_date: Date }>(
      `SELECT completed_date FROM habit_completions
       WHERE habit_id = $1
       ORDER BY completed_date DESC`,
      [habitId]
    );

    if (result.rows.length === 0) return 0;

    const completedDates = result.rows.map(r => {
      const date = new Date(r.completed_date);
      return date.toISOString().split('T')[0];
    });

    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Start from today and count backwards
    const checkDate = new Date(today);

    // If today is not completed, start from yesterday
    const todayStr = today.toISOString().split('T')[0];
    if (!completedDates.includes(todayStr)) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // Count consecutive days
    while (true) {
      const dateStr = checkDate.toISOString().split('T')[0];
      if (completedDates.includes(dateStr)) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    return streak;
  },

  async getStats(): Promise<{
    totalHabits: number;
    completedToday: number;
    totalForToday: number;
    maxStreak: number;
    maxBestStreak: number;
    weeklyCompletionRate: number;
  }> {
    // Get total habits
    const totalResult = await pool.query<{ count: string }>('SELECT COUNT(*) as count FROM habits');
    const totalHabits = parseInt(totalResult.rows[0].count);

    if (totalHabits === 0) {
      return {
        totalHabits: 0,
        completedToday: 0,
        totalForToday: 0,
        maxStreak: 0,
        maxBestStreak: 0,
        weeklyCompletionRate: 0,
      };
    }

    // Get today's day of week in ISO convention (0 = Monday, 6 = Sunday)
    const today = new Date();
    const dayOfWeek = jsToIsoDay(today.getDay());
    const todayStr = today.toISOString().split('T')[0];

    // Get habits that should be done today (where targetDays contains today's day)
    const habitsForTodayResult = await pool.query<{ id: string }>(
      `SELECT id FROM habits WHERE $1 = ANY(target_days)`,
      [dayOfWeek]
    );
    const totalForToday = habitsForTodayResult.rows.length;
    const habitIdsForToday = habitsForTodayResult.rows.map(r => r.id);

    // Get completed today
    let completedToday = 0;
    if (habitIdsForToday.length > 0) {
      const completedResult = await pool.query<{ count: string }>(
        `SELECT COUNT(*) as count FROM habit_completions
         WHERE habit_id = ANY($1) AND completed_date = $2`,
        [habitIdsForToday, todayStr]
      );
      completedToday = parseInt(completedResult.rows[0].count);
    }

    // Get max current streak and max best streak
    const streakResult = await pool.query<{ max_streak: string; max_best_streak: string }>(
      `SELECT COALESCE(MAX(streak), 0) as max_streak, COALESCE(MAX(best_streak), 0) as max_best_streak FROM habits`
    );
    const maxStreak = parseInt(streakResult.rows[0].max_streak);
    const maxBestStreak = parseInt(streakResult.rows[0].max_best_streak);

    // Calculate weekly completion rate
    // For each day in the past week, count expected vs completed
    let expectedCompletions = 0;
    let actualCompletions = 0;

    for (let i = 0; i < 7; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(checkDate.getDate() - i);
      const checkDayOfWeek = jsToIsoDay(checkDate.getDay());
      const checkDateStr = checkDate.toISOString().split('T')[0];

      // Count habits expected for this day
      const expectedResult = await pool.query<{ count: string }>(
        `SELECT COUNT(*) as count FROM habits WHERE $1 = ANY(target_days)`,
        [checkDayOfWeek]
      );
      expectedCompletions += parseInt(expectedResult.rows[0].count);

      // Count actual completions for this day
      const actualResult = await pool.query<{ count: string }>(
        `SELECT COUNT(*) as count FROM habit_completions WHERE completed_date = $1`,
        [checkDateStr]
      );
      actualCompletions += parseInt(actualResult.rows[0].count);
    }

    const weeklyCompletionRate = expectedCompletions > 0
      ? Math.round((actualCompletions / expectedCompletions) * 100) / 100
      : 0;

    return {
      totalHabits,
      completedToday,
      totalForToday,
      maxStreak,
      maxBestStreak,
      weeklyCompletionRate,
    };
  },
};
