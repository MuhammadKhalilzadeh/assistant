import { Request, Response, NextFunction } from 'express';
import { categoryModel } from '../models/category.model';

export const categoryController = {
  async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const categories = await categoryModel.findAll(userId);
      res.json(categories);
    } catch (error) {
      console.error('Error fetching categories:', error);
      res.status(500).json({ error: 'Failed to fetch categories' });
    }
  },
};
