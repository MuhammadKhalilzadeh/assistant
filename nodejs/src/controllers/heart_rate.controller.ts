import { Request, Response, NextFunction } from 'express';
import { heartRateModel } from '../models/heart_rate.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const heartRateController = {
  async getRecordsForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { date } = req.query;
      const records = await heartRateModel.getRecordsForDate(date as string | undefined);
      logger.debug({ count: records.length, date }, 'Fetched heart rate records for date');
      res.json(records);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch heart rate records');
      next(new DatabaseError('Failed to fetch heart rate records'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const record = await heartRateModel.findById(id);
      if (!record) return next(new NotFoundError('Heart rate record'));
      logger.debug({ recordId: id }, 'Fetched heart rate record by ID');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to fetch heart rate record');
      next(new DatabaseError('Failed to fetch heart rate record'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { bpm, zone, recordedAt } = req.body;
      const record = await heartRateModel.create({ bpm, zone, recordedAt });
      logger.info({ recordId: record.id, bpm: record.bpm }, 'Created new heart rate record');
      res.status(201).json(record);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create heart rate record');
      next(new DatabaseError('Failed to create heart rate record'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { bpm, zone, recordedAt } = req.body;
      const updateData: Record<string, unknown> = {};
      if (bpm !== undefined) updateData.bpm = bpm;
      if (zone !== undefined) updateData.zone = zone;
      if (recordedAt !== undefined) updateData.recordedAt = recordedAt;
      const record = await heartRateModel.update(id, updateData);
      if (!record) return next(new NotFoundError('Heart rate record'));
      logger.info({ recordId: id }, 'Updated heart rate record');
      res.json(record);
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to update heart rate record');
      next(new DatabaseError('Failed to update heart rate record'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deleted = await heartRateModel.delete(id);
      if (!deleted) return next(new NotFoundError('Heart rate record'));
      logger.info({ recordId: id }, 'Deleted heart rate record');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, recordId: req.params.id }, 'Failed to delete heart rate record');
      next(new DatabaseError('Failed to delete heart rate record'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await heartRateModel.getStats();
      logger.debug('Fetched heart rate stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch heart rate stats');
      next(new DatabaseError('Failed to fetch heart rate stats'));
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const history = await heartRateModel.getLast7Days();
      logger.debug('Fetched heart rate history');
      res.json(history);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch heart rate history');
      next(new DatabaseError('Failed to fetch heart rate history'));
    }
  },

  async getGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await heartRateModel.getGoal();
      logger.debug('Fetched heart rate goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch heart rate goal');
      next(new DatabaseError('Failed to fetch heart rate goal'));
    }
  },

  async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { targetRestingBpm, maxBpm } = req.body;
      const goal = await heartRateModel.updateGoal({ targetRestingBpm, maxBpm });
      logger.info({ targetRestingBpm: goal.targetRestingBpm }, 'Updated heart rate goal');
      res.json(goal);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update heart rate goal');
      next(new DatabaseError('Failed to update heart rate goal'));
    }
  },
};
