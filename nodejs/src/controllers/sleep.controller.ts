import { Request, Response, NextFunction } from 'express';
import { sleepModel } from '../models/sleep.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const sleepController = {
  async getRecordsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { date } = req.query;
      const records = await sleepModel.getRecordsForDate(date as string | undefined);
      logger.debug({ count: records.length, date }, 'Fetched sleep records for date');
      res.json(records);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch sleep records');
      next(new DatabaseError('Failed to fetch sleep records'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const record = await sleepModel.findById(id);
      if (!record) return next(new NotFoundError('Sleep record'));
      logger.debug({ recordId: id }, 'Fetched sleep record by ID');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to fetch sleep record');
      next(new DatabaseError('Failed to fetch sleep record'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { bedTime, wakeTime, quality, notes } = req.body;
      const record = await sleepModel.create({ bedTime, wakeTime, quality, notes });
      logger.info({ recordId: record.id, durationMinutes: record.durationMinutes }, 'Created new sleep record');
      res.status(201).json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create sleep record');
      next(new DatabaseError('Failed to create sleep record'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { bedTime, wakeTime, quality, notes } = req.body;
      const updateData: Record<string, unknown> = {};
      if (bedTime !== undefined) updateData.bedTime = bedTime;
      if (wakeTime !== undefined) updateData.wakeTime = wakeTime;
      if (quality !== undefined) updateData.quality = quality;
      if (notes !== undefined) updateData.notes = notes;
      const record = await sleepModel.update(id, updateData);
      if (!record) return next(new NotFoundError('Sleep record'));
      logger.info({ recordId: id }, 'Updated sleep record');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to update sleep record');
      next(new DatabaseError('Failed to update sleep record'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await sleepModel.delete(id);
      if (!deleted) return next(new NotFoundError('Sleep record'));
      logger.info({ recordId: id }, 'Deleted sleep record');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to delete sleep record');
      next(new DatabaseError('Failed to delete sleep record'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await sleepModel.getStats();
      logger.debug('Fetched sleep stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch sleep stats');
      next(new DatabaseError('Failed to fetch sleep stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const history = await sleepModel.getLast7Days();
      logger.debug('Fetched sleep history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch sleep history');
      next(new DatabaseError('Failed to fetch sleep history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await sleepModel.getGoal();
      logger.debug('Fetched sleep goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch sleep goal');
      next(new DatabaseError('Failed to fetch sleep goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { goalMinutes } = req.body;
      const goal = await sleepModel.updateGoal({ goalMinutes });
      logger.info({ goalMinutes: goal.goalMinutes }, 'Updated sleep goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update sleep goal');
      next(new DatabaseError('Failed to update sleep goal'));
    }
  },
};
