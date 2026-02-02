import { Request, Response } from 'express';
import { categoryModel } from '../models/category.model';

export const categoryController = {
  async getAll(req: Request, res: Response): Promise<void> {
    try {
      const categories = await categoryModel.findAll();
      res.json(categories);
    } catch (error) {
      console.error('Error fetching categories:', error);
      res.status(500).json({ error: 'Failed to fetch categories' });
    }
  },
};
