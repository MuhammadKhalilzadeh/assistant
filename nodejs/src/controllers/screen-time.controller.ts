import { Request, Response, NextFunction } from 'express';
import { screenTimeModel } from '../models/screen-time.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const screenTimeController = {
  async getByDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date } = req.query;
      const record = await screenTimeModel.getByDate(userId, date as string | undefined);
      logger.debug({ date }, 'Fetched screen time record for date');
      res.json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch screen time record');
      next(new DatabaseError('Failed to fetch screen time record'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const record = await screenTimeModel.findById(userId, id);

      if (!record) {
        return next(new NotFoundError('Screen time record'));
      }

      logger.debug({ recordId: id }, 'Fetched screen time record by ID');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to fetch screen time record');
      next(new DatabaseError('Failed to fetch screen time record'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date, totalMinutes, pickups, note, appUsage } = req.body;

      const record = await screenTimeModel.create(userId, {
        date,
        totalMinutes,
        pickups: pickups || 0,
        note: note || undefined,
        appUsage,
      });

      logger.info({ recordId: record.id, date: record.date }, 'Created/updated screen time record');
      res.status(201).json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create screen time record');
      next(new DatabaseError('Failed to create screen time record'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { totalMinutes, pickups, note, appUsage } = req.body;

      const updateData: Record<string, unknown> = {};
      if (totalMinutes !== undefined) updateData.totalMinutes = totalMinutes;
      if (pickups !== undefined) updateData.pickups = pickups;
      if (note !== undefined) updateData.note = note;
      if (appUsage !== undefined) updateData.appUsage = appUsage;

      const record = await screenTimeModel.update(userId, id, updateData);

      if (!record) {
        return next(new NotFoundError('Screen time record'));
      }

      logger.info({ recordId: id }, 'Updated screen time record');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to update screen time record');
      next(new DatabaseError('Failed to update screen time record'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await screenTimeModel.delete(userId, id);

      if (!deleted) {
        return next(new NotFoundError('Screen time record'));
      }

      logger.info({ recordId: id }, 'Deleted screen time record');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to delete screen time record');
      next(new DatabaseError('Failed to delete screen time record'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await screenTimeModel.getStats(userId);
      logger.debug('Fetched screen time stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch screen time stats');
      next(new DatabaseError('Failed to fetch screen time stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const history = await screenTimeModel.getHistory(userId);
      logger.debug('Fetched screen time history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch screen time history');
      next(new DatabaseError('Failed to fetch screen time history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const goal = await screenTimeModel.getGoal(userId);
      logger.debug('Fetched screen time goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch screen time goal');
      next(new DatabaseError('Failed to fetch screen time goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { dailyLimitMinutes } = req.body;

      const goal = await screenTimeModel.updateGoal(userId, { dailyLimitMinutes });

      logger.info({ dailyLimitMinutes: goal.dailyLimitMinutes }, 'Updated screen time goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update screen time goal');
      next(new DatabaseError('Failed to update screen time goal'));
    }
  },
};
