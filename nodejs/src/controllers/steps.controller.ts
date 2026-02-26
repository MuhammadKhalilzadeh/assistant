import { Request, Response, NextFunction } from 'express';
import { stepsModel } from '../models/steps.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const stepsController = {
  async getRecordForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date } = req.query;
      const record = await stepsModel.getRecordForDate(userId, date as string | undefined);
      logger.debug({ date }, 'Fetched step record for date');
      res.json(record || { steps: 0, goal: 10000, distanceKm: 0, caloriesBurned: 0 });
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch step record');
      next(new DatabaseError('Failed to fetch step record'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const record = await stepsModel.findById(userId, id);
      if (!record) return next(new NotFoundError('Step record'));
      logger.debug({ recordId: id }, 'Fetched step record by ID');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to fetch step record');
      next(new DatabaseError('Failed to fetch step record'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date, steps, goal, distanceKm, caloriesBurned } = req.body;
      const record = await stepsModel.create(userId, { date, steps, goal, distanceKm, caloriesBurned });
      logger.info({ recordId: record.id, steps: record.steps }, 'Created/updated step record');
      res.status(201).json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create step record');
      next(new DatabaseError('Failed to create step record'));
    }
  },

  async addSteps(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { steps } = req.body;
      const record = await stepsModel.addSteps(userId, steps);
      logger.info({ steps, total: record.steps }, 'Added steps to today');
      res.status(201).json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to add steps');
      next(new DatabaseError('Failed to add steps'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { steps, goal, distanceKm, caloriesBurned } = req.body;
      const updateData: Record<string, unknown> = {};
      if (steps !== undefined) updateData.steps = steps;
      if (goal !== undefined) updateData.goal = goal;
      if (distanceKm !== undefined) updateData.distanceKm = distanceKm;
      if (caloriesBurned !== undefined) updateData.caloriesBurned = caloriesBurned;
      const record = await stepsModel.update(userId, id, updateData);
      if (!record) return next(new NotFoundError('Step record'));
      logger.info({ recordId: id }, 'Updated step record');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to update step record');
      next(new DatabaseError('Failed to update step record'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await stepsModel.delete(userId, id);
      if (!deleted) return next(new NotFoundError('Step record'));
      logger.info({ recordId: id }, 'Deleted step record');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to delete step record');
      next(new DatabaseError('Failed to delete step record'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await stepsModel.getStats(userId);
      logger.debug('Fetched steps stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch steps stats');
      next(new DatabaseError('Failed to fetch steps stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const history = await stepsModel.getLast7Days(userId);
      logger.debug('Fetched steps history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch steps history');
      next(new DatabaseError('Failed to fetch steps history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const goal = await stepsModel.getGoal(userId);
      logger.debug('Fetched steps goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch steps goal');
      next(new DatabaseError('Failed to fetch steps goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { dailyGoal } = req.body;
      const goal = await stepsModel.updateGoal(userId, { dailyGoal });
      logger.info({ dailyGoal: goal.dailyGoal }, 'Updated steps goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update steps goal');
      next(new DatabaseError('Failed to update steps goal'));
    }
  },
};
