import pool from '../config/database';

export interface MoodEntry {
  id: string;
  mood: string;
  notes: string | null;
  activities: string[];
  recordedAt: Date;
  createdAt: Date;
}

export interface MoodEntryRow {
  id: string;
  mood: string;
  notes: string | null;
  activities: string[];
  recorded_at: Date;
  created_at: Date;
}

export interface MoodGoal {
  id: string;
  dailyEntriesGoal: number;
  targetMood: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface MoodGoalRow {
  id: string;
  daily_entries_goal: number;
  target_mood: string;
  created_at: Date;
  updated_at: Date;
}

export interface MoodStats {
  weeklyAverageMood: number;
  currentStreak: number;
  bestStreak: number;
  totalEntries: number;
  moodDistribution: Record<string, number>;
  commonActivities: Record<string, number>;
}

export interface MoodDailySummary {
  date: string;
  entries: number;
  dominantMood: string | null;
  hasEntry: boolean;
}

export interface CreateMoodEntryInput {
  mood: string;
  notes?: string | null;
  activities?: string[];
  recordedAt?: string;
}

export interface UpdateMoodEntryInput {
  mood?: string;
  notes?: string | null;
  activities?: string[];
  recordedAt?: string;
}

export interface UpdateMoodGoalInput {
  dailyEntriesGoal: number;
  targetMood?: string;
}

const moodValues: Record<string, number> = {
  great: 5,
  good: 4,
  okay: 3,
  bad: 2,
  awful: 1,
};

function rowToEntry(row: MoodEntryRow): MoodEntry {
  return {
    id: row.id,
    mood: row.mood,
    notes: row.notes,
    activities: row.activities || [],
    recordedAt: row.recorded_at,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: MoodGoalRow): MoodGoal {
  return {
    id: row.id,
    dailyEntriesGoal: row.daily_entries_goal,
    targetMood: row.target_mood,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const moodModel = {
  async getEntriesForDate(date?: string): Promise<MoodEntry[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const result = await pool.query<MoodEntryRow>(`
      SELECT id, mood, notes, activities, recorded_at, created_at
      FROM mood_entries WHERE DATE(recorded_at) = $1
      ORDER BY recorded_at DESC
    `, [targetDate]);
    return result.rows.map(rowToEntry);
  },

  async findById(id: string): Promise<MoodEntry | null> {
    const result = await pool.query<MoodEntryRow>(
      `SELECT id, mood, notes, activities, recorded_at, created_at FROM mood_entries WHERE id = $1`,
      [id]
    );
    if (!result.rows[0]) return null;
    return rowToEntry(result.rows[0]);
  },

  async create(input: CreateMoodEntryInput): Promise<MoodEntry> {
    const result = await pool.query<MoodEntryRow>(
      `INSERT INTO mood_entries (mood, notes, activities, recorded_at)
       VALUES ($1, $2, $3, $4)
       RETURNING id, mood, notes, activities, recorded_at, created_at`,
      [
        input.mood,
        input.notes || null,
        input.activities || [],
        input.recordedAt ? new Date(input.recordedAt) : new Date(),
      ]
    );
    return rowToEntry(result.rows[0]);
  },

  async update(id: string, input: UpdateMoodEntryInput): Promise<MoodEntry | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | string[] | Date | null)[] = [];
    let paramIndex = 1;

    if (input.mood !== undefined) {
      updates.push(`mood = $${paramIndex++}`);
      values.push(input.mood);
    }
    if (input.notes !== undefined) {
      updates.push(`notes = $${paramIndex++}`);
      values.push(input.notes);
    }
    if (input.activities !== undefined) {
      updates.push(`activities = $${paramIndex++}`);
      values.push(input.activities);
    }
    if (input.recordedAt !== undefined) {
      updates.push(`recorded_at = $${paramIndex++}`);
      values.push(new Date(input.recordedAt));
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE mood_entries SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM mood_entries WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(): Promise<MoodGoal> {
    const result = await pool.query<MoodGoalRow>(`
      SELECT id, daily_entries_goal, target_mood, created_at, updated_at
      FROM mood_goals ORDER BY created_at DESC LIMIT 1
    `);
    if (!result.rows[0]) {
      const insertResult = await pool.query<MoodGoalRow>(
        `INSERT INTO mood_goals (daily_entries_goal, target_mood) VALUES (1, 'good')
         RETURNING id, daily_entries_goal, target_mood, created_at, updated_at`
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(input: UpdateMoodGoalInput): Promise<MoodGoal> {
    const goal = await this.getGoal();
    const updates: string[] = ['updated_at = CURRENT_TIMESTAMP'];
    const values: (number | string)[] = [];
    let paramIndex = 1;

    updates.push(`daily_entries_goal = $${paramIndex++}`);
    values.push(input.dailyEntriesGoal);

    if (input.targetMood !== undefined) {
      updates.push(`target_mood = $${paramIndex++}`);
      values.push(input.targetMood);
    }

    values.push(goal.id);
    await pool.query(
      `UPDATE mood_goals SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.getGoal();
  },

  async getStats(): Promise<MoodStats> {
    // Weekly average mood
    const avgResult = await pool.query<{ mood: string; count: string }>(`
      SELECT mood, COUNT(*) as count FROM mood_entries
      WHERE recorded_at >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY mood
    `);

    let totalValue = 0;
    let totalCount = 0;
    const moodDistribution: Record<string, number> = {};
    for (const row of avgResult.rows) {
      const count = parseInt(row.count);
      moodDistribution[row.mood] = count;
      totalValue += (moodValues[row.mood] || 3) * count;
      totalCount += count;
    }
    const weeklyAverageMood = totalCount > 0 ? Math.round((totalValue / totalCount) * 10) / 10 : 0;

    // Total entries
    const totalResult = await pool.query<{ total: string }>(`
      SELECT COUNT(*) as total FROM mood_entries
      WHERE recorded_at >= CURRENT_DATE - INTERVAL '7 days'
    `);

    // Common activities
    const activitiesResult = await pool.query<{ activity: string; count: string }>(`
      SELECT unnest(activities) as activity, COUNT(*) as count
      FROM mood_entries
      WHERE recorded_at >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY activity ORDER BY count DESC LIMIT 10
    `);
    const commonActivities: Record<string, number> = {};
    for (const row of activitiesResult.rows) {
      commonActivities[row.activity] = parseInt(row.count);
    }

    const { currentStreak, bestStreak } = await this.calculateStreaks();

    return {
      weeklyAverageMood,
      currentStreak,
      bestStreak,
      totalEntries: parseInt(totalResult.rows[0].total),
      moodDistribution,
      commonActivities,
    };
  },

  async calculateStreaks(): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ log_date: Date }>(`
      SELECT DISTINCT DATE(recorded_at) as log_date FROM mood_entries ORDER BY log_date DESC
    `);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dates = result.rows.map(r => new Date(r.log_date).toISOString().split('T')[0]);
    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 1;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);
    const todayStr = today.toISOString().split('T')[0];

    if (dates[0] !== todayStr) {
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      if (dates[0] !== yesterday.toISOString().split('T')[0]) {
        // No recent entry, current streak is 0, still calculate best
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
      checkDate = new Date(today);
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

  async getLast7Days(): Promise<MoodDailySummary[]> {
    const summaries: MoodDailySummary[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ count: string; dominant: string }>(
        `SELECT COUNT(*) as count,
                (SELECT mood FROM mood_entries WHERE DATE(recorded_at) = $1 GROUP BY mood ORDER BY COUNT(*) DESC LIMIT 1) as dominant
         FROM mood_entries WHERE DATE(recorded_at) = $1`,
        [dateStr]
      );

      const count = parseInt(result.rows[0].count);
      summaries.push({
        date: dateStr,
        entries: count,
        dominantMood: result.rows[0].dominant || null,
        hasEntry: count > 0,
      });
    }
    return summaries;
  },
};
