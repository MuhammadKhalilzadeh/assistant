import { Request, Response, NextFunction } from 'express';
import { insightModel } from '../models/insight.model';
import { dataContextService } from '../services/brain/data-context.service';
import { insightGeneratorService } from '../services/intelligence/insight-generator.service';
import { correlationService } from '../services/intelligence/correlation.service';
import { trendAnalyzerService } from '../services/intelligence/trend-analyzer.service';
import { anomalyDetectorService } from '../services/intelligence/anomaly-detector.service';
import { DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const insightsController = {
  /**
   * GET /api/insights - Get user's active insights
   */
  async getInsights(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const limit = parseInt(req.query.limit as string) || 20;
      const offset = parseInt(req.query.offset as string) || 0;
      const type = req.query.type as string | undefined;

      let insights;
      if (type) {
        insights = await insightModel.findByType(userId, type);
      } else {
        insights = await insightModel.findByUserId(userId, limit, offset);
      }

      res.json(insights);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get insights');
      next(new DatabaseError('Failed to get insights'));
    }
  },

  /**
   * POST /api/insights/generate - Run the full intelligence pipeline
   * Generates correlations, trends, anomalies, patterns, and basic insights.
   */
  async generateInsights(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;

      // Clean up expired insights first
      await insightModel.deleteExpired();

      // Run the full intelligence pipeline
      const report = await insightGeneratorService.generateFullReport(userId);

      // Also run legacy basic insights (streak-at-risk, goal suggestions)
      const basicInsights = await generateBasicInsights(userId);

      res.json({
        generated: report.generatedInsights + basicInsights,
        correlations: report.correlations.length,
        trends: report.trends.length,
        anomalies: report.anomalies.length,
        patterns: report.patterns.length,
        insights: await insightModel.findByUserId(userId, 20, 0),
      });
    } catch (error) {
      logger.error({ err: error }, 'Failed to generate insights');
      next(new DatabaseError('Failed to generate insights'));
    }
  },

  /**
   * GET /api/insights/correlations - Get correlation analysis
   */
  async getCorrelations(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const correlations = await correlationService.analyzeAll(userId);
      res.json(correlations);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get correlations');
      next(new DatabaseError('Failed to get correlations'));
    }
  },

  /**
   * GET /api/insights/trends - Get trend analysis
   */
  async getTrends(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const trends = await trendAnalyzerService.analyzeTrends(userId);
      res.json(trends);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get trends');
      next(new DatabaseError('Failed to get trends'));
    }
  },

  /**
   * GET /api/insights/anomalies - Get anomaly detection results
   */
  async getAnomalies(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const anomalies = await anomalyDetectorService.detectAnomalies(userId);
      res.json(anomalies);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get anomalies');
      next(new DatabaseError('Failed to get anomalies'));
    }
  },

  /**
   * POST /api/insights/:id/dismiss - Dismiss an insight
   */
  async dismissInsight(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;

      const dismissed = await insightModel.dismiss(userId, id);
      if (!dismissed) {
        res.status(404).json({ error: 'Insight not found' });
        return;
      }

      res.json({ message: 'Insight dismissed' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to dismiss insight');
      next(new DatabaseError('Failed to dismiss insight'));
    }
  },

  /**
   * GET /api/insights/context - Get raw data context (for debugging/display)
   */
  async getDataContext(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const level = (req.query.level as string) || 'summary';

      const context = await dataContextService.buildContext(
        userId,
        level as 'summary' | 'detailed' | 'full'
      );

      res.json({ level, context });
    } catch (error) {
      logger.error({ err: error }, 'Failed to get data context');
      next(new DatabaseError('Failed to get data context'));
    }
  },
};

/**
 * Generate basic insights (streak-at-risk, goal suggestions, overdue todos, etc.)
 * This supplements the intelligence engine with simple heuristic checks.
 */
async function generateBasicInsights(userId: string): Promise<number> {
  const data = await dataContextService.fetchAll(userId);
  let count = 0;

  // Streak-at-risk insights
  const streakDomains = [
    { key: 'steps', label: 'Steps', stats: data.steps?.stats },
    { key: 'sleep', label: 'Sleep', stats: data.sleep?.stats },
    { key: 'workout', label: 'Workout', stats: data.workout?.stats },
    { key: 'water', label: 'Water', stats: data.water?.stats },
    { key: 'meditation', label: 'Meditation', stats: data.meditation?.stats },
  ];

  for (const domain of streakDomains) {
    if (domain.stats?.currentStreak >= 5) {
      let todayDone = true;
      if (domain.key === 'steps' && data.steps?.stats) {
        todayDone = data.steps.stats.todaySteps >= data.steps.stats.dailyGoal;
      } else if (domain.key === 'water' && data.water?.stats) {
        todayDone = data.water.stats.todayIntakeMl >= data.water.stats.dailyGoalMl;
      }

      if (!todayDone) {
        try {
          await insightModel.create(userId, {
            type: 'suggestion',
            domains: [domain.key],
            title: `${domain.label} streak at risk!`,
            description: `Your ${domain.stats.currentStreak}-day ${domain.label.toLowerCase()} streak is at risk. Keep it going!`,
            confidence: 0.9,
            data: { currentStreak: domain.stats.currentStreak },
            expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
          });
          count++;
        } catch (_) { /* duplicate or error, skip */ }
      }
    }
  }

  // Overdue todos
  if (data.todos?.stats && data.todos.stats.overdueCount > 0) {
    try {
      await insightModel.create(userId, {
        type: 'anomaly',
        domains: ['todos'],
        title: `${data.todos.stats.overdueCount} overdue tasks`,
        description: `You have ${data.todos.stats.overdueCount} overdue task${data.todos.stats.overdueCount > 1 ? 's' : ''}. Consider rescheduling or tackling them today.`,
        confidence: 1.0,
        data: { overdueCount: data.todos.stats.overdueCount },
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      });
      count++;
    } catch (_) { /* skip */ }
  }

  return count;
}
