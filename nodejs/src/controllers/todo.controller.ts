import { Request, Response, NextFunction } from 'express';
import { todoModel } from '../models/todo.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const todoController = {
  async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const todos = await todoModel.findAll(userId);
      logger.debug({ count: todos.length }, 'Fetched all todos');
      res.json(todos);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch todos');
      next(new DatabaseError('Failed to fetch todos'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const todo = await todoModel.findById(userId, id);

      if (!todo) {
        return next(new NotFoundError('Todo'));
      }

      logger.debug({ todoId: id }, 'Fetched todo by ID');
      res.json(todo);
    } catch (error) {
      logger.error({ err: error, todoId: req.params.id }, 'Failed to fetch todo');
      next(new DatabaseError('Failed to fetch todo'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { title, description, dueDate, priority, categoryId } = req.body;

      const todo = await todoModel.create(userId, {
        title,
        description: description || undefined,
        dueDate: dueDate ? new Date(dueDate) : null,
        priority: priority || 2,
        categoryId: categoryId || null,
      });

      logger.info({ todoId: todo.id, title: todo.title }, 'Created new todo');
      res.status(201).json(todo);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create todo');
      next(new DatabaseError('Failed to create todo'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { title, description, isCompleted, dueDate, priority, categoryId } = req.body;

      const updateData: Record<string, unknown> = {};

      if (title !== undefined) updateData.title = title;
      if (description !== undefined) updateData.description = description || null;
      if (isCompleted !== undefined) updateData.isCompleted = isCompleted;
      if (dueDate !== undefined) updateData.dueDate = dueDate ? new Date(dueDate) : null;
      if (priority !== undefined) updateData.priority = priority;
      if (categoryId !== undefined) updateData.categoryId = categoryId;

      const todo = await todoModel.update(userId, id, updateData);

      if (!todo) {
        return next(new NotFoundError('Todo'));
      }

      logger.info({ todoId: id }, 'Updated todo');
      res.json(todo);
    } catch (error) {
      logger.error({ err: error, todoId: req.params.id }, 'Failed to update todo');
      next(new DatabaseError('Failed to update todo'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await todoModel.delete(userId, id);

      if (!deleted) {
        return next(new NotFoundError('Todo'));
      }

      logger.info({ todoId: id }, 'Deleted todo');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, todoId: req.params.id }, 'Failed to delete todo');
      next(new DatabaseError('Failed to delete todo'));
    }
  },

  async toggleComplete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const todo = await todoModel.toggleComplete(userId, id);

      if (!todo) {
        return next(new NotFoundError('Todo'));
      }

      logger.info({ todoId: id, isCompleted: todo.isCompleted }, 'Toggled todo completion');
      res.json(todo);
    } catch (error) {
      logger.error({ err: error, todoId: req.params.id }, 'Failed to toggle todo');
      next(new DatabaseError('Failed to toggle todo'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await todoModel.getStats(userId);
      logger.debug('Fetched todo stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch stats');
      next(new DatabaseError('Failed to fetch stats'));
    }
  },
};
