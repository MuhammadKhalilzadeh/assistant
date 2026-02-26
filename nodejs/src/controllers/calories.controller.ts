import { Request, Response, NextFunction } from 'express';
import { caloriesModel } from '../models/calories.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const caloriesController = {
  async getEntriesForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { date } = req.query;
      const entries = await caloriesModel.getEntriesForDate(userId, date as string | undefined);
      logger.debug({ count: entries.length, date }, 'Fetched calorie entries for date');
      res.json(entries);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch calorie entries');
      next(new DatabaseError('Failed to fetch calorie entries'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const entry = await caloriesModel.findById(userId, id);
      if (!entry) return next(new NotFoundError('Calorie entry'));
      logger.debug({ entryId: id }, 'Fetched calorie entry by ID');
      res.json(entry);
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to fetch calorie entry');
      next(new DatabaseError('Failed to fetch calorie entry'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { foodName, calories, mealType, protein, carbs, fat, foodCategory, servingSize, note, loggedAt } = req.body;
      const entry = await caloriesModel.create(userId, {
        foodName, calories, mealType, protein, carbs, fat, foodCategory, servingSize, note, loggedAt,
      });
      logger.info({ entryId: entry.id, foodName: entry.foodName, calories: entry.calories }, 'Created new calorie entry');
      res.status(201).json(entry);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create calorie entry');
      next(new DatabaseError('Failed to create calorie entry'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { foodName, calories, mealType, protein, carbs, fat, foodCategory, servingSize, note, loggedAt } = req.body;
      const updateData: Record<string, unknown> = {};
      if (foodName !== undefined) updateData.foodName = foodName;
      if (calories !== undefined) updateData.calories = calories;
      if (mealType !== undefined) updateData.mealType = mealType;
      if (protein !== undefined) updateData.protein = protein;
      if (carbs !== undefined) updateData.carbs = carbs;
      if (fat !== undefined) updateData.fat = fat;
      if (foodCategory !== undefined) updateData.foodCategory = foodCategory;
      if (servingSize !== undefined) updateData.servingSize = servingSize;
      if (note !== undefined) updateData.note = note;
      if (loggedAt !== undefined) updateData.loggedAt = loggedAt;
      const entry = await caloriesModel.update(userId, id, updateData);
      if (!entry) return next(new NotFoundError('Calorie entry'));
      logger.info({ entryId: id }, 'Updated calorie entry');
      res.json(entry);
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to update calorie entry');
      next(new DatabaseError('Failed to update calorie entry'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await caloriesModel.delete(userId, id);
      if (!deleted) return next(new NotFoundError('Calorie entry'));
      logger.info({ entryId: id }, 'Deleted calorie entry');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, entryId: req.params.id }, 'Failed to delete calorie entry');
      next(new DatabaseError('Failed to delete calorie entry'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await caloriesModel.getStats(userId);
      logger.debug('Fetched nutrition stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch nutrition stats');
      next(new DatabaseError('Failed to fetch nutrition stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const history = await caloriesModel.getLast7Days(userId);
      logger.debug('Fetched nutrition history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch nutrition history');
      next(new DatabaseError('Failed to fetch nutrition history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const goal = await caloriesModel.getGoal(userId);
      logger.debug('Fetched nutrition goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch nutrition goal');
      next(new DatabaseError('Failed to fetch nutrition goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { dailyCalorieGoal, proteinGoalGrams, carbsGoalGrams, fatGoalGrams, remindersEnabled } = req.body;
      const goal = await caloriesModel.updateGoal(userId, {
        dailyCalorieGoal, proteinGoalGrams, carbsGoalGrams, fatGoalGrams, remindersEnabled,
      });
      logger.info({ dailyCalorieGoal: goal.dailyCalorieGoal }, 'Updated nutrition goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update nutrition goal');
      next(new DatabaseError('Failed to update nutrition goal'));
    }
  },
};
