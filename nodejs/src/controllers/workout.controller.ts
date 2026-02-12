import { Request, Response, NextFunction } from 'express';
import { workoutModel } from '../models/workout.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const workoutController = {
  async getSessionsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { date } = req.query;
      const sessions = await workoutModel.getSessionsForDate(date as string | undefined);
      logger.debug({ count: sessions.length, date }, 'Fetched workout sessions for date');
      res.json(sessions);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch workout sessions');
      next(new DatabaseError('Failed to fetch workout sessions'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const session = await workoutModel.findById(id);
      if (!session) return next(new NotFoundError('Workout session'));
      logger.debug({ sessionId: id }, 'Fetched workout session by ID');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to fetch workout session');
      next(new DatabaseError('Failed to fetch workout session'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { type, startTime, endTime, durationMinutes, caloriesBurned, exercises, notes } = req.body;
      const session = await workoutModel.create({ type, startTime, endTime, durationMinutes, caloriesBurned, exercises, notes });
      logger.info({ sessionId: session.id, type: session.type }, 'Created new workout session');
      res.status(201).json(session);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create workout session');
      next(new DatabaseError('Failed to create workout session'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { type, startTime, endTime, durationMinutes, caloriesBurned, exercises, notes } = req.body;
      const updateData: Record<string, unknown> = {};
      if (type !== undefined) updateData.type = type;
      if (startTime !== undefined) updateData.startTime = startTime;
      if (endTime !== undefined) updateData.endTime = endTime;
      if (durationMinutes !== undefined) updateData.durationMinutes = durationMinutes;
      if (caloriesBurned !== undefined) updateData.caloriesBurned = caloriesBurned;
      if (exercises !== undefined) updateData.exercises = exercises;
      if (notes !== undefined) updateData.notes = notes;
      const session = await workoutModel.update(id, updateData);
      if (!session) return next(new NotFoundError('Workout session'));
      logger.info({ sessionId: id }, 'Updated workout session');
      res.json(session);
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to update workout session');
      next(new DatabaseError('Failed to update workout session'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await workoutModel.delete(id);
      if (!deleted) return next(new NotFoundError('Workout session'));
      logger.info({ sessionId: id }, 'Deleted workout session');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, sessionId: req.params.id }, 'Failed to delete workout session');
      next(new DatabaseError('Failed to delete workout session'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await workoutModel.getStats();
      logger.debug('Fetched workout stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch workout stats');
      next(new DatabaseError('Failed to fetch workout stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const history = await workoutModel.getLast7Days();
      logger.debug('Fetched workout history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch workout history');
      next(new DatabaseError('Failed to fetch workout history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await workoutModel.getGoal();
      logger.debug('Fetched workout goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch workout goal');
      next(new DatabaseError('Failed to fetch workout goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { weeklyMinutesGoal, weeklySessionsGoal } = req.body;
      const goal = await workoutModel.updateGoal({ weeklyMinutesGoal, weeklySessionsGoal });
      logger.info({ weeklyMinutesGoal: goal.weeklyMinutesGoal }, 'Updated workout goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update workout goal');
      next(new DatabaseError('Failed to update workout goal'));
    }
  },
};
