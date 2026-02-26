import pool from '../config/database';
import { Category } from './category.model';

export interface Todo {
  id: string;
  title: string;
  description: string | null;
  isCompleted: boolean;
  createdAt: Date;
  completedAt: Date | null;
  dueDate: Date | null;
  priority: number;
  categoryId: string | null;
  category: Category | null;
}

export interface TodoRow {
  id: string;
  title: string;
  description: string | null;
  is_completed: boolean;
  created_at: Date;
  completed_at: Date | null;
  due_date: Date | null;
  priority: number;
  category_id: string | null;
  category_name: string | null;
  category_color: string | null;
  category_icon: string | null;
}

export interface CreateTodoInput {
  title: string;
  description?: string;
  dueDate?: Date | null;
  priority?: number;
  categoryId?: string | null;
}

export interface UpdateTodoInput {
  title?: string;
  description?: string | null;
  isCompleted?: boolean;
  dueDate?: Date | null;
  priority?: number;
  categoryId?: string | null;
}

function rowToTodo(row: TodoRow): Todo {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    isCompleted: row.is_completed,
    createdAt: row.created_at,
    completedAt: row.completed_at,
    dueDate: row.due_date,
    priority: row.priority,
    categoryId: row.category_id,
    category: row.category_id
      ? {
          id: row.category_id,
          name: row.category_name!,
          color: row.category_color!,
          icon: row.category_icon,
        }
      : null,
  };
}

const SELECT_TODOS = `
  SELECT
    t.id, t.title, t.description, t.is_completed, t.created_at,
    t.completed_at, t.due_date, t.priority, t.category_id,
    c.name as category_name, c.color as category_color, c.icon as category_icon
  FROM todos t
  LEFT JOIN categories c ON t.category_id = c.id
`;

export const todoModel = {
  async findAll(userId: string): Promise<Todo[]> {
    const result = await pool.query<TodoRow>(
      `${SELECT_TODOS} WHERE t.user_id = $1 ORDER BY t.created_at DESC`,
      [userId]
    );
    return result.rows.map(rowToTodo);
  },

  async findById(userId: string, id: string): Promise<Todo | null> {
    const result = await pool.query<TodoRow>(
      `${SELECT_TODOS} WHERE t.id = $1 AND t.user_id = $2`,
      [id, userId]
    );
    return result.rows[0] ? rowToTodo(result.rows[0]) : null;
  },

  async create(userId: string, input: CreateTodoInput): Promise<Todo> {
    const result = await pool.query<{ id: string }>(
      `INSERT INTO todos (title, description, due_date, priority, category_id, user_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id`,
      [
        input.title,
        input.description || null,
        input.dueDate || null,
        input.priority || 2,
        input.categoryId || null,
        userId,
      ]
    );
    const todo = await this.findById(userId, result.rows[0].id);
    return todo!;
  },

  async update(userId: string, id: string, input: UpdateTodoInput): Promise<Todo | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const updates: string[] = [];
    const values: (string | boolean | number | Date | null)[] = [];
    let paramIndex = 1;

    if (input.title !== undefined) {
      updates.push(`title = $${paramIndex++}`);
      values.push(input.title);
    }
    if (input.description !== undefined) {
      updates.push(`description = $${paramIndex++}`);
      values.push(input.description);
    }
    if (input.isCompleted !== undefined) {
      updates.push(`is_completed = $${paramIndex++}`);
      values.push(input.isCompleted);
      if (input.isCompleted && !existing.isCompleted) {
        updates.push(`completed_at = $${paramIndex++}`);
        values.push(new Date());
      } else if (!input.isCompleted) {
        updates.push(`completed_at = $${paramIndex++}`);
        values.push(null);
      }
    }
    if (input.dueDate !== undefined) {
      updates.push(`due_date = $${paramIndex++}`);
      values.push(input.dueDate);
    }
    if (input.priority !== undefined) {
      updates.push(`priority = $${paramIndex++}`);
      values.push(input.priority);
    }
    if (input.categoryId !== undefined) {
      updates.push(`category_id = $${paramIndex++}`);
      values.push(input.categoryId);
    }

    if (updates.length === 0) return existing;

    values.push(id);
    const idIndex = paramIndex++;
    values.push(userId);
    const userIdIndex = paramIndex;
    await pool.query(
      `UPDATE todos SET ${updates.join(', ')} WHERE id = $${idIndex} AND user_id = $${userIdIndex}`,
      values
    );

    return this.findById(userId, id);
  },

  async delete(userId: string, id: string): Promise<boolean> {
    const result = await pool.query('DELETE FROM todos WHERE id = $1 AND user_id = $2', [id, userId]);
    return (result.rowCount ?? 0) > 0;
  },

  async toggleComplete(userId: string, id: string): Promise<Todo | null> {
    const existing = await this.findById(userId, id);
    if (!existing) return null;

    const newCompleted = !existing.isCompleted;
    const completedAt = newCompleted ? new Date() : null;

    await pool.query(
      'UPDATE todos SET is_completed = $1, completed_at = $2 WHERE id = $3 AND user_id = $4',
      [newCompleted, completedAt, id, userId]
    );

    return this.findById(userId, id);
  },

  async getStats(userId: string): Promise<{
    total: number;
    completed: number;
    todayCount: number;
    overdueCount: number;
    completionRate: number;
    currentStreak: number;
    thisWeekCompleted: number;
  }> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 7);

    const result = await pool.query<{
      total: string;
      completed: string;
      today_count: string;
      overdue_count: string;
      this_week_completed: string;
    }>(`
      SELECT
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_completed = true) as completed,
        COUNT(*) FILTER (WHERE due_date = CURRENT_DATE) as today_count,
        COUNT(*) FILTER (WHERE due_date < CURRENT_DATE AND is_completed = false) as overdue_count,
        COUNT(*) FILTER (WHERE completed_at >= $1 AND is_completed = true) as this_week_completed
      FROM todos
      WHERE user_id = $2
    `, [weekAgo, userId]);

    const stats = result.rows[0];
    const total = parseInt(stats.total);
    const completed = parseInt(stats.completed);

    // Calculate streak (consecutive days with at least one completed task)
    const streakResult = await pool.query<{ completion_date: Date }>(`
      SELECT DISTINCT DATE(completed_at) as completion_date
      FROM todos
      WHERE completed_at IS NOT NULL AND user_id = $1
      ORDER BY completion_date DESC
      LIMIT 30
    `, [userId]);

    let currentStreak = 0;
    const completionDates = streakResult.rows.map(r => r.completion_date);

    if (completionDates.length > 0) {
      const checkDate = new Date();
      checkDate.setHours(0, 0, 0, 0);

      for (const date of completionDates) {
        const completionDate = new Date(date);
        completionDate.setHours(0, 0, 0, 0);

        const diffDays = Math.floor((checkDate.getTime() - completionDate.getTime()) / (1000 * 60 * 60 * 24));

        if (diffDays === currentStreak || diffDays === currentStreak + 1) {
          currentStreak++;
          checkDate.setDate(checkDate.getDate() - 1);
        } else {
          break;
        }
      }
    }

    return {
      total,
      completed,
      todayCount: parseInt(stats.today_count),
      overdueCount: parseInt(stats.overdue_count),
      completionRate: total > 0 ? completed / total : 0,
      currentStreak,
      thisWeekCompleted: parseInt(stats.this_week_completed),
    };
  },
};
