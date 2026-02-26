import { Request, Response, NextFunction } from 'express';
import { meditationModel } from '../models/meditation.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const meditationController = {
  async getSessionsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date } = req.query;
      const sessions = await meditationModel.getSessionsForDate(userId, date as string | undefined);
      logger.debug({ count: sessions.length, date }, 'Fetched meditation sessions for date');
      res.json(sessions);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch meditation sessions');
      next(new DatabaseError('Failed to fetch meditation sessions'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const session = await meditationModel.findById(userId, id);
      if (!session) return next(new NotFoundError('Meditation session'));
      logger.debug({ sessionId: id }, 'Fetched meditation session by ID');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to fetch meditation session');
      next(new DatabaseError('Failed to fetch meditation session'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { type, startTime, durationMinutes, isCompleted, notes } = req.body;
      const session = await meditationModel.create(userId, { type, startTime, durationMinutes, isCompleted, notes });
      logger.info({ sessionId: session.id, type: session.type }, 'Created new meditation session');
      res.status(201).json(session);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create meditation session');
      next(new DatabaseError('Failed to create meditation session'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { type, startTime, durationMinutes, isCompleted, notes } = req.body;
      const updateData: Record<string, unknown> = {};
      if (type !== undefined) updateData.type = type;
      if (startTime !== undefined) updateData.startTime = startTime;
      if (durationMinutes !== undefined) updateData.durationMinutes = durationMinutes;
      if (isCompleted !== undefined) updateData.isCompleted = isCompleted;
      if (notes !== undefined) updateData.notes = notes;
      const session = await meditationModel.update(userId, id, updateData);
      if (!session) return next(new NotFoundError('Meditation session'));
      logger.info({ sessionId: id }, 'Updated meditation session');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to update meditation session');
      next(new DatabaseError('Failed to update meditation session'));
    }
  },

  async markComplete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const session = await meditationModel.markComplete(userId, id);
      if (!session) return next(new NotFoundError('Meditation session'));
      logger.info({ sessionId: id }, 'Marked meditation session as complete');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to mark session complete');
      next(new DatabaseError('Failed to mark meditation session as complete'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await meditationModel.delete(userId, id);
      if (!deleted) return next(new NotFoundError('Meditation session'));
      logger.info({ sessionId: id }, 'Deleted meditation session');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to delete meditation session');
      next(new DatabaseError('Failed to delete meditation session'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await meditationModel.getStats(userId);
      logger.debug('Fetched meditation stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch meditation stats');
      next(new DatabaseError('Failed to fetch meditation stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const history = await meditationModel.getLast7Days(userId);
      logger.debug('Fetched meditation history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch meditation history');
      next(new DatabaseError('Failed to fetch meditation history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const goal = await meditationModel.getGoal(userId);
      logger.debug('Fetched meditation goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch meditation goal');
      next(new DatabaseError('Failed to fetch meditation goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { dailyMinutesGoal, weeklySessionsGoal } = req.body;
      const goal = await meditationModel.updateGoal(userId, { dailyMinutesGoal, weeklySessionsGoal });
      logger.info({ dailyMinutesGoal: goal.dailyMinutesGoal }, 'Updated meditation goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update meditation goal');
      next(new DatabaseError('Failed to update meditation goal'));
    }
  },
};
