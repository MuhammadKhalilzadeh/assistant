import pool from '../config/database';

export interface Category {
  id: string;
  name: string;
  color: string;
  icon: string | null;
}

export interface CategoryRow {
  id: string;
  name: string;
  color: string;
  icon: string | null;
}

export const categoryModel = {
  async findAll(userId: string): Promise<Category[]> {
    const result = await pool.query<CategoryRow>(
      'SELECT id, name, color, icon FROM categories WHERE user_id = $1 ORDER BY name',
      [userId]
    );
    return result.rows;
  },

  async findById(userId: string, id: string): Promise<Category | null> {
    const result = await pool.query<CategoryRow>(
      'SELECT id, name, color, icon FROM categories WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    return result.rows[0] || null;
  },
};
