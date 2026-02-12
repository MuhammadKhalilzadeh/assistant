import { Request, Response, NextFunction } from 'express';
import { moodModel } from '../models/mood.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const moodController = {
  async getEntriesForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { date } = req.query;
      const entries = await moodModel.getEntriesForDate(date as string | undefined);
      logger.debug({ count: entries.length, date }, 'Fetched mood entries for date');
      res.json(entries);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch mood entries');
      next(new DatabaseError('Failed to fetch mood entries'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const entry = await moodModel.findById(id);
      if (!entry) return next(new NotFoundError('Mood entry'));
      logger.debug({ entryId: id }, 'Fetched mood entry by ID');
      res.json(entry);
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to fetch mood entry');
      next(new DatabaseError('Failed to fetch mood entry'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { mood, notes, activities, recordedAt } = req.body;
      const entry = await moodModel.create({ mood, notes, activities, recordedAt });
      logger.info({ entryId: entry.id, mood: entry.mood }, 'Created new mood entry');
      res.status(201).json(entry);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create mood entry');
      next(new DatabaseError('Failed to create mood entry'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { mood, notes, activities, recordedAt } = req.body;
      const updateData: Record<string, unknown> = {};
      if (mood !== undefined) updateData.mood = mood;
      if (notes !== undefined) updateData.notes = notes;
      if (activities !== undefined) updateData.activities = activities;
      if (recordedAt !== undefined) updateData.recordedAt = recordedAt;
      const entry = await moodModel.update(id, updateData);
      if (!entry) return next(new NotFoundError('Mood entry'));
      logger.info({ entryId: id }, 'Updated mood entry');
      res.json(entry);
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to update mood entry');
      next(new DatabaseError('Failed to update mood entry'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await moodModel.delete(id);
      if (!deleted) return next(new NotFoundError('Mood entry'));
      logger.info({ entryId: id }, 'Deleted mood entry');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to delete mood entry');
      next(new DatabaseError('Failed to delete mood entry'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await moodModel.getStats();
      logger.debug('Fetched mood stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch mood stats');
      next(new DatabaseError('Failed to fetch mood stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const history = await moodModel.getLast7Days();
      logger.debug('Fetched mood history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch mood history');
      next(new DatabaseError('Failed to fetch mood history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await moodModel.getGoal();
      logger.debug('Fetched mood goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch mood goal');
      next(new DatabaseError('Failed to fetch mood goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { dailyEntriesGoal, targetMood } = req.body;
      const goal = await moodModel.updateGoal({ dailyEntriesGoal, targetMood });
      logger.info({ dailyEntriesGoal: goal.dailyEntriesGoal }, 'Updated mood goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update mood goal');
      next(new DatabaseError('Failed to update mood goal'));
    }
  },
};
