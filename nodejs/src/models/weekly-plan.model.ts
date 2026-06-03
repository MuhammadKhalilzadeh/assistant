import pool from '../config/database';

export interface DayPlan {
  date: string;
  dayOfWeek: string;
  recommendations: {
    activity: string;
    domain: string;
    suggestedTime: string;
    duration: number;
    priority: 'must_do' | 'should_do' | 'nice_to_do';
    reason: string;
  }[];
  targets: {
    domain: string;
    target: number;
    rationale: string;
  }[];
}

export interface WeeklyPlan {
  id: string;
  userId: string;
  weekStart: string;
  weekEnd: string;
  days: DayPlan[];
  focusAreas: string[];
  aiSummary: string;
  status: 'draft' | 'active' | 'completed';
  createdAt: Date;
}

interface WeeklyPlanRow {
  id: string;
  user_id: string;
  week_start: string;
  week_end: string;
  days: DayPlan[];
  focus_areas: string[];
  ai_summary: string;
  status: string;
  created_at: Date;
}

function rowToPlan(row: WeeklyPlanRow): WeeklyPlan {
  return {
    id: row.id,
    userId: row.user_id,
    weekStart: row.week_start,
    weekEnd: row.week_end,
    days: row.days,
    focusAreas: row.focus_areas,
    aiSummary: row.ai_summary,
    status: row.status as WeeklyPlan['status'],
    createdAt: row.created_at,
  };
}

export const weeklyPlanModel = {
  async ensureTable(): Promise<void> {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS weekly_plans (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        week_start DATE NOT NULL,
        week_end DATE NOT NULL,
        days JSONB NOT NULL DEFAULT '[]',
        focus_areas TEXT[] DEFAULT '{}',
        ai_summary TEXT DEFAULT '',
        status VARCHAR(20) DEFAULT 'draft',
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_weekly_plans_user
      ON weekly_plans(user_id, week_start)
    `);
  },

  async findCurrent(userId: string): Promise<WeeklyPlan | null> {
    const result = await pool.query<WeeklyPlanRow>(
      `SELECT * FROM weekly_plans
       WHERE user_id = $1 AND status = 'active'
       ORDER BY week_start DESC LIMIT 1`,
      [userId]
    );
    return result.rows.length > 0 ? rowToPlan(result.rows[0]) : null;
  },

  async findAll(userId: string, limit = 10): Promise<WeeklyPlan[]> {
    const result = await pool.query<WeeklyPlanRow>(
      `SELECT * FROM weekly_plans
       WHERE user_id = $1
       ORDER BY week_start DESC LIMIT $2`,
      [userId, limit]
    );
    return result.rows.map(rowToPlan);
  },

  async create(
    userId: string,
    input: Omit<WeeklyPlan, 'id' | 'userId' | 'createdAt'>,
  ): Promise<WeeklyPlan> {
    // Mark any existing active plan as completed
    await pool.query(
      `UPDATE weekly_plans SET status = 'completed' WHERE user_id = $1 AND status = 'active'`,
      [userId]
    );

    const result = await pool.query<WeeklyPlanRow>(
      `INSERT INTO weekly_plans (user_id, week_start, week_end, days, focus_areas, ai_summary, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [userId, input.weekStart, input.weekEnd, JSON.stringify(input.days), input.focusAreas, input.aiSummary, input.status]
    );
    return rowToPlan(result.rows[0]);
  },
};
