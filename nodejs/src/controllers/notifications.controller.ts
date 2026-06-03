import { Request, Response, NextFunction } from 'express';
import { weeklyReportService } from '../services/scheduler/weekly-report.service';
import { morningBriefingService } from '../services/scheduler/morning-briefing.service';
import { DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const notificationsController = {
  /**
   * POST /api/notifications/morning-briefing - Generate on-demand morning briefing
   */
  async generateMorningBriefing(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      await morningBriefingService.generateForUser(userId);
      res.json({ message: 'Morning briefing generated and delivered to inbox' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to generate morning briefing');
      next(new DatabaseError('Failed to generate morning briefing'));
    }
  },

  /**
   * POST /api/notifications/weekly-report - Generate on-demand weekly report
   */
  async generateWeeklyReport(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const report = await weeklyReportService.generateForUser(userId);
      res.json(report);
    } catch (error) {
      logger.error({ err: error }, 'Failed to generate weekly report');
      next(new DatabaseError('Failed to generate weekly report'));
    }
  },
};
