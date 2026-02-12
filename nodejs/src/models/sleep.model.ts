import pool from '../config/database';

export interface SleepRecord {
  id: string;
  bedTime: Date;
  wakeTime: Date;
  quality: string;
  notes: string | null;
  durationMinutes: number;
  createdAt: Date;
}

export interface SleepRecordRow {
  id: string;
  bed_time: Date;
  wake_time: Date;
  quality: string;
  notes: string | null;
  created_at: Date;
}

export interface SleepGoal {
  id: string;
  goalMinutes: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface SleepGoalRow {
  id: string;
  goal_minutes: number;
  created_at: Date;
  updated_at: Date;
}

export interface SleepStats {
  weeklyAverageHours: number;
  currentStreak: number;
  bestStreak: number;
  goalCompletionRate: number;
  qualityDistribution: Record<string, number>;
  averageBedTime: string | null;
  averageWakeTime: string | null;
}

export interface SleepDailySummary {
  date: string;
  durationMinutes: number;
  quality: string | null;
  goalMinutes: number;
  goalMet: boolean;
}

export interface CreateSleepRecordInput {
  bedTime: string;
  wakeTime: string;
  quality?: string;
  notes?: string | null;
}

export interface UpdateSleepRecordInput {
  bedTime?: string;
  wakeTime?: string;
  quality?: string;
  notes?: string | null;
}

export interface UpdateSleepGoalInput {
  goalMinutes: number;
}

function rowToRecord(row: SleepRecordRow): SleepRecord {
  const bedTime = new Date(row.bed_time);
  const wakeTime = new Date(row.wake_time);
  const durationMinutes = Math.round((wakeTime.getTime() - bedTime.getTime()) / (1000 * 60));

  return {
    id: row.id,
    bedTime: row.bed_time,
    wakeTime: row.wake_time,
    quality: row.quality,
    notes: row.notes,
    durationMinutes,
    createdAt: row.created_at,
  };
}

function rowToGoal(row: SleepGoalRow): SleepGoal {
  return {
    id: row.id,
    goalMinutes: row.goal_minutes,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const sleepModel = {
  async getRecordsForDate(date?: string): Promise<SleepRecord[]> {
    const targetDate = date || new Date().toISOString().split('T')[0];
    // Sleep records: match by wake_time date (the day you woke up)
    const result = await pool.query<SleepRecordRow>(`
      SELECT id, bed_time, wake_time, quality, notes, created_at
      FROM sleep_records WHERE DATE(wake_time) = $1
      ORDER BY bed_time DESC
    `, [targetDate]);
    return result.rows.map(rowToRecord);
  },

  async findById(id: string): Promise<SleepRecord | null> {
    const result = await pool.query<SleepRecordRow>(
      `SELECT id, bed_time, wake_time, quality, notes, created_at FROM sleep_records WHERE id = $1`,
      [id]
    );
    if (!result.rows[0]) return null;
    return rowToRecord(result.rows[0]);
  },

  async create(input: CreateSleepRecordInput): Promise<SleepRecord> {
    const result = await pool.query<SleepRecordRow>(
      `INSERT INTO sleep_records (bed_time, wake_time, quality, notes)
       VALUES ($1, $2, $3, $4)
       RETURNING id, bed_time, wake_time, quality, notes, created_at`,
      [
        new Date(input.bedTime),
        new Date(input.wakeTime),
        input.quality || 'good',
        input.notes || null,
      ]
    );
    return rowToRecord(result.rows[0]);
  },

  async update(id: string, input: UpdateSleepRecordInput): Promise<SleepRecord | null> {
    const existing = await this.findById(id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | Date | null)[] = [];
    let paramIndex = 1;

    if (input.bedTime !== undefined) {
      updates.push(`bed_time = $${paramIndex++}`);
      values.push(new Date(input.bedTime));
    }
    if (input.wakeTime !== undefined) {
      updates.push(`wake_time = $${paramIndex++}`);
      values.push(new Date(input.wakeTime));
    }
    if (input.quality !== undefined) {
      updates.push(`quality = $${paramIndex++}`);
      values.push(input.quality);
    }
    if (input.notes !== undefined) {
      updates.push(`notes = $${paramIndex++}`);
      values.push(input.notes);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    await pool.query(
      `UPDATE sleep_records SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      values
    );
    return this.findById(id);
  },

  async delete(id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM sleep_records WHERE id = $1', [id]);
    return (result.rowCount ?? 0) > 0;
  },

  async getGoal(): Promise<SleepGoal> {
    const result = await pool.query<SleepGoalRow>(`
      SELECT id, goal_minutes, created_at, updated_at
      FROM sleep_goals ORDER BY created_at DESC LIMIT 1
    `);
    if (!result.rows[0]) {
      const insertResult = await pool.query<SleepGoalRow>(
        `INSERT INTO sleep_goals (goal_minutes) VALUES (480)
         RETURNING id, goal_minutes, created_at, updated_at`
      );
      return rowToGoal(insertResult.rows[0]);
    }
    return rowToGoal(result.rows[0]);
  },

  async updateGoal(input: UpdateSleepGoalInput): Promise<SleepGoal> {
    const goal = await this.getGoal();
    await pool.query(
      `UPDATE sleep_goals SET goal_minutes = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`,
      [input.goalMinutes, goal.id]
    );
    return this.getGoal();
  },

  async getStats(): Promise<SleepStats> {
    const goal = await this.getGoal();

    // Weekly average hours
    const avgResult = await pool.query<{ avg_minutes: string }>(`
      SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (wake_time - bed_time)) / 60), 0) as avg_minutes
      FROM sleep_records WHERE wake_time >= CURRENT_DATE - INTERVAL '7 days'
    `);
    const weeklyAverageHours = Math.round(parseFloat(avgResult.rows[0].avg_minutes) / 60 * 10) / 10;

    // Quality distribution
    const qualityResult = await pool.query<{ quality: string; count: string }>(`
      SELECT quality, COUNT(*) as count FROM sleep_records
      WHERE wake_time >= CURRENT_DATE - INTERVAL '7 days' GROUP BY quality
    `);
    const qualityDistribution: Record<string, number> = {};
    for (const row of qualityResult.rows) {
      qualityDistribution[row.quality] = parseInt(row.count);
    }

    // Average bed/wake times
    const timeResult = await pool.query<{ avg_bed_hour: string; avg_wake_hour: string }>(`
      SELECT
        COALESCE(AVG(EXTRACT(HOUR FROM bed_time) + EXTRACT(MINUTE FROM bed_time) / 60.0), 0) as avg_bed_hour,
        COALESCE(AVG(EXTRACT(HOUR FROM wake_time) + EXTRACT(MINUTE FROM wake_time) / 60.0), 0) as avg_wake_hour
      FROM sleep_records WHERE wake_time >= CURRENT_DATE - INTERVAL '7 days'
    `);

    const avgBedHour = parseFloat(timeResult.rows[0].avg_bed_hour);
    const avgWakeHour = parseFloat(timeResult.rows[0].avg_wake_hour);
    const averageBedTime = avgBedHour > 0 ? `${Math.floor(avgBedHour)}:${String(Math.round((avgBedHour % 1) * 60)).padStart(2, '0')}` : null;
    const averageWakeTime = avgWakeHour > 0 ? `${Math.floor(avgWakeHour)}:${String(Math.round((avgWakeHour % 1) * 60)).padStart(2, '0')}` : null;

    const { currentStreak, bestStreak } = await this.calculateStreaks(goal.goalMinutes);

    // Goal completion rate
    const completionResult = await pool.query<{ days_met: string; total_days: string }>(`
      SELECT
        COUNT(*) FILTER (WHERE EXTRACT(EPOCH FROM (wake_time - bed_time)) / 60 >= $1) as days_met,
        COUNT(*) as total_days
      FROM sleep_records WHERE wake_time >= CURRENT_DATE - INTERVAL '30 days'
    `, [goal.goalMinutes]);
    const daysMet = parseInt(completionResult.rows[0].days_met);
    const totalDays = parseInt(completionResult.rows[0].total_days);
    const goalCompletionRate = totalDays > 0 ? Math.round((daysMet / totalDays) * 100) / 100 : 0;

    return {
      weeklyAverageHours,
      currentStreak,
      bestStreak,
      goalCompletionRate,
      qualityDistribution,
      averageBedTime,
      averageWakeTime,
    };
  },

  async calculateStreaks(goalMinutes: number): Promise<{ currentStreak: number; bestStreak: number }> {
    const result = await pool.query<{ wake_date: Date; duration_min: string }>(`
      SELECT DATE(wake_time) as wake_date,
             EXTRACT(EPOCH FROM (wake_time - bed_time)) / 60 as duration_min
      FROM sleep_records ORDER BY wake_date DESC
    `);
    if (result.rows.length === 0) return { currentStreak: 0, bestStreak: 0 };

    const dateMap = new Map<string, number>();
    for (const row of result.rows) {
      const dateStr = new Date(row.wake_date).toISOString().split('T')[0];
      dateMap.set(dateStr, parseFloat(row.duration_min));
    }

    let currentStreak = 0;
    let bestStreak = 0;
    let tempStreak = 0;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let checkDate = new Date(today);
    const todayStr = today.toISOString().split('T')[0];

    if ((dateMap.get(todayStr) || 0) < goalMinutes) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (true) {
      const dStr = checkDate.toISOString().split('T')[0];
      if ((dateMap.get(dStr) || 0) >= goalMinutes) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else break;
    }

    const sortedDates = Array.from(dateMap.keys()).sort();
    for (const d of sortedDates) {
      if ((dateMap.get(d) || 0) >= goalMinutes) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    bestStreak = Math.max(bestStreak, currentStreak);

    return { currentStreak, bestStreak };
  },

  async getLast7Days(): Promise<SleepDailySummary[]> {
    const goal = await this.getGoal();
    const summaries: SleepDailySummary[] = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const result = await pool.query<{ duration_min: string; quality: string }>(
        `SELECT EXTRACT(EPOCH FROM (wake_time - bed_time)) / 60 as duration_min, quality
         FROM sleep_records WHERE DATE(wake_time) = $1 LIMIT 1`,
        [dateStr]
      );

      const row = result.rows[0];
      const durationMinutes = row ? Math.round(parseFloat(row.duration_min)) : 0;

      summaries.push({
        date: dateStr,
        durationMinutes,
        quality: row?.quality || null,
        goalMinutes: goal.goalMinutes,
        goalMet: durationMinutes >= goal.goalMinutes,
      });
    }
    return summaries;
  },
};
