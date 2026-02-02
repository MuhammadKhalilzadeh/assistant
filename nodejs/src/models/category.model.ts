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
  async findAll(): Promise<Category[]> {
    const result = await pool.query<CategoryRow>(
      'SELECT id, name, color, icon FROM categories ORDER BY name'
    );
    return result.rows;
  },

  async findById(id: string): Promise<Category | null> {
    const result = await pool.query<CategoryRow>(
      'SELECT id, name, color, icon FROM categories WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  },
};
