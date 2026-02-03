import { Request, Response, NextFunction } from 'express';
import { waterModel } from '../models/water.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const waterController = {
  async getLogsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { date } = req.query;
      const logs = await waterModel.getLogsForDate(date as string | undefined);
      logger.debug({ count: logs.length, date }, 'Fetched water logs for date');
      res.json(logs);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch water logs');
      next(new DatabaseError('Failed to fetch water logs'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const log = await waterModel.findById(id);

      if (!log) {
        return next(new NotFoundError('Water log'));
      }

      logger.debug({ logId: id }, 'Fetched water log by ID');
      res.json(log);
    } catch (error) {
      logger.error({ err: error, logId: req.params.id }, 'Failed to fetch water log');
      next(new DatabaseError('Failed to fetch water log'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { amountMl, beverageType, note, loggedAt } = req.body;

      const log = await waterModel.create({
        amountMl,
        beverageType: beverageType || 'water',
        note: note || undefined,
        loggedAt,
      });

      logger.info({ logId: log.id, amountMl: log.amountMl }, 'Created new water log');
      res.status(201).json(log);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create water log');
      next(new DatabaseError('Failed to create water log'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { amountMl, beverageType, note, loggedAt } = req.body;

      const updateData: Record<string, unknown> = {};

      if (amountMl !== undefined) updateData.amountMl = amountMl;
      if (beverageType !== undefined) updateData.beverageType = beverageType;
      if (note !== undefined) updateData.note = note || null;
      if (loggedAt !== undefined) updateData.loggedAt = loggedAt;

      const log = await waterModel.update(id, updateData);

      if (!log) {
        return next(new NotFoundError('Water log'));
      }

      logger.info({ logId: id }, 'Updated water log');
      res.json(log);
    } catch (error) {
      logger.error({ err: error, logId: req.params.id }, 'Failed to update water log');
      next(new DatabaseError('Failed to update water log'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await waterModel.delete(id);

      if (!deleted) {
        return next(new NotFoundError('Water log'));
      }

      logger.info({ logId: id }, 'Deleted water log');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, logId: req.params.id }, 'Failed to delete water log');
      next(new DatabaseError('Failed to delete water log'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await waterModel.getStats();
      logger.debug('Fetched water stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch water stats');
      next(new DatabaseError('Failed to fetch water stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const history = await waterModel.getLast7Days();
      logger.debug('Fetched water history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch water history');
      next(new DatabaseError('Failed to fetch water history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await waterModel.getGoal();
      logger.debug('Fetched hydration goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch hydration goal');
      next(new DatabaseError('Failed to fetch hydration goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { dailyGoalMl, reminderIntervalMinutes, remindersEnabled } = req.body;

      const goal = await waterModel.updateGoal({
        dailyGoalMl,
        reminderIntervalMinutes,
        remindersEnabled,
      });

      logger.info({ dailyGoalMl: goal.dailyGoalMl }, 'Updated hydration goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update hydration goal');
      next(new DatabaseError('Failed to update hydration goal'));
    }
  },
};
