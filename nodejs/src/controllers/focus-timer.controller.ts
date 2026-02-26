import { Request, Response, NextFunction } from 'express';
import { focusTimerModel } from '../models/focus-timer.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const focusTimerController = {
  async getSessionsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date } = req.query;
      const sessions = await focusTimerModel.getSessionsForDate(userId, date as string | undefined);
      logger.debug({ count: sessions.length, date }, 'Fetched focus timer sessions for date');
      res.json(sessions);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch focus timer sessions');
      next(new DatabaseError('Failed to fetch focus timer sessions'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const session = await focusTimerModel.findById(userId, id);
      if (!session) return next(new NotFoundError('Focus timer session'));
      logger.debug({ sessionId: id }, 'Fetched focus timer session by ID');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to fetch focus timer session');
      next(new DatabaseError('Failed to fetch focus timer session'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { type, startTime, endTime, durationMinutes, isCompleted, task } = req.body;
      const session = await focusTimerModel.create(userId, { type, startTime, endTime, durationMinutes, isCompleted, task });
      logger.info({ sessionId: session.id, type: session.type }, 'Created new focus timer session');
      res.status(201).json(session);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create focus timer session');
      next(new DatabaseError('Failed to create focus timer session'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { type, startTime, endTime, durationMinutes, isCompleted, task } = req.body;
      const updateData: Record<string, unknown> = {};
      if (type !== undefined) updateData.type = type;
      if (startTime !== undefined) updateData.startTime = startTime;
      if (endTime !== undefined) updateData.endTime = endTime;
      if (durationMinutes !== undefined) updateData.durationMinutes = durationMinutes;
      if (isCompleted !== undefined) updateData.isCompleted = isCompleted;
      if (task !== undefined) updateData.task = task;
      const session = await focusTimerModel.update(userId, id, updateData);
      if (!session) return next(new NotFoundError('Focus timer session'));
      logger.info({ sessionId: id }, 'Updated focus timer session');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to update focus timer session');
      next(new DatabaseError('Failed to update focus timer session'));
    }
  },

  async markComplete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const session = await focusTimerModel.markComplete(userId, id);
      if (!session) return next(new NotFoundError('Focus timer session'));
      logger.info({ sessionId: id }, 'Marked focus timer session as complete');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to mark focus timer session complete');
      next(new DatabaseError('Failed to mark focus timer session as complete'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await focusTimerModel.delete(userId, id);
      if (!deleted) return next(new NotFoundError('Focus timer session'));
      logger.info({ sessionId: id }, 'Deleted focus timer session');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to delete focus timer session');
      next(new DatabaseError('Failed to delete focus timer session'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await focusTimerModel.getStats(userId);
      logger.debug('Fetched focus timer stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch focus timer stats');
      next(new DatabaseError('Failed to fetch focus timer stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const history = await focusTimerModel.getLast7Days(userId);
      logger.debug('Fetched focus timer history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch focus timer history');
      next(new DatabaseError('Failed to fetch focus timer history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const goal = await focusTimerModel.getGoal(userId);
      logger.debug('Fetched focus timer goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch focus timer goal');
      next(new DatabaseError('Failed to fetch focus timer goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const {
        dailyGoalSessions, focusDuration, shortBreakDuration, longBreakDuration,
        sessionsBeforeLongBreak, autoStartBreaks, autoStartFocus, soundEnabled, vibrationEnabled,
      } = req.body;
      const goal = await focusTimerModel.updateGoal(userId, {
        dailyGoalSessions, focusDuration, shortBreakDuration, longBreakDuration,
        sessionsBeforeLongBreak, autoStartBreaks, autoStartFocus, soundEnabled, vibrationEnabled,
      });
      logger.info({ dailyGoalSessions: goal.dailyGoalSessions }, 'Updated focus timer goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update focus timer goal');
      next(new DatabaseError('Failed to update focus timer goal'));
    }
  },
};
