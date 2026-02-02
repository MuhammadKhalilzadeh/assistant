import { Request, Response, NextFunction } from 'express';
import { habitModel } from '../models/habit.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const habitController = {
  async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const habits = await habitModel.findAll();
      logger.debug({ count: habits.length }, 'Fetched all habits');
      res.json(habits);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch habits');
      next(new DatabaseError('Failed to fetch habits'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const habit = await habitModel.findById(id);

      if (!habit) {
        return next(new NotFoundError('Habit'));
      }

      logger.debug({ habitId: id }, 'Fetched habit by ID');
      res.json(habit);
    } catch (error) {
      logger.error({ err: error, habitId: req.params.id }, 'Failed to fetch habit');
      next(new DatabaseError('Failed to fetch habit'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { name, description, icon, category, frequency, targetDays } = req.body;

      const habit = await habitModel.create({
        name,
        description: description || undefined,
        icon: icon || 'check_circle',
        category: category || 'other',
        frequency: frequency || 'daily',
        targetDays: targetDays || [0, 1, 2, 3, 4, 5, 6],
      });

      logger.info({ habitId: habit.id, name: habit.name }, 'Created new habit');
      res.status(201).json(habit);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create habit');
      next(new DatabaseError('Failed to create habit'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { name, description, icon, category, frequency, targetDays } = req.body;

      const updateData: Record<string, unknown> = {};

      if (name !== undefined) updateData.name = name;
      if (description !== undefined) updateData.description = description || null;
      if (icon !== undefined) updateData.icon = icon;
      if (category !== undefined) updateData.category = category;
      if (frequency !== undefined) updateData.frequency = frequency;
      if (targetDays !== undefined) updateData.targetDays = targetDays;

      const habit = await habitModel.update(id, updateData);

      if (!habit) {
        return next(new NotFoundError('Habit'));
      }

      logger.info({ habitId: id }, 'Updated habit');
      res.json(habit);
    } catch (error) {
      logger.error({ err: error, habitId: req.params.id }, 'Failed to update habit');
      next(new DatabaseError('Failed to update habit'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await habitModel.delete(id);

      if (!deleted) {
        return next(new NotFoundError('Habit'));
      }

      logger.info({ habitId: id }, 'Deleted habit');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, habitId: req.params.id }, 'Failed to delete habit');
      next(new DatabaseError('Failed to delete habit'));
    }
  },

  async toggleComplete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const habit = await habitModel.toggleComplete(id);

      if (!habit) {
        return next(new NotFoundError('Habit'));
      }

      logger.info({ habitId: id, isCompletedToday: habit.isCompletedToday }, 'Toggled habit completion');
      res.json(habit);
    } catch (error) {
      logger.error({ err: error, habitId: req.params.id }, 'Failed to toggle habit');
      next(new DatabaseError('Failed to toggle habit'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await habitModel.getStats();
      logger.debug('Fetched habit stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch habit stats');
      next(new DatabaseError('Failed to fetch habit stats'));
    }
  },
};
