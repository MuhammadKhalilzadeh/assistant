/**
 * Scheduled analysis runner. Uses setInterval-based scheduling
 * (no external cron dependency). Runs periodic analysis jobs for all users.
 */

import pool from '../../config/database';
import { morningBriefingService } from './morning-briefing.service';
import { weeklyReportService } from './weekly-report.service';
import { insightGeneratorService } from '../intelligence/insight-generator.service';
import { anomalyDetectorService } from '../intelligence/anomaly-detector.service';
import { notificationService } from '../notification/notification.service';
import { goalAdvisorService } from '../agent/goal-advisor.service';
import { weeklyPlannerService } from '../agent/weekly-planner.service';
import { goalSuggestionModel } from '../../models/goal-suggestion.model';
import { weeklyPlanModel } from '../../models/weekly-plan.model';
import { autoActionService } from '../agent/auto-action.service';
import { logger } from '../../config/logger';

/** Get all active user IDs */
async function getAllUserIds(): Promise<string[]> {
  try {
    const result = await pool.query<{ id: string }>(
      'SELECT id FROM users ORDER BY created_at'
    );
    return result.rows.map(r => r.id);
  } catch (err) {
    logger.error({ err }, 'Failed to get user IDs for scheduler');
    return [];
  }
}

const HOUR_MS = 60 * 60 * 1000;

export const analysisScheduler = {
  _intervals: [] as NodeJS.Timeout[],

  /**
   * Initialize all scheduled jobs. Call on server start.
   */
  async initialize(): Promise<void> {
    // Ensure all required tables exist
    await notificationService.ensureTable();
    await goalSuggestionModel.ensureTable();
    await weeklyPlanModel.ensureTable();
    await autoActionService.ensureTable();

    logger.info('Analysis scheduler initialized');

    // Run insight generation every 6 hours
    this._intervals.push(
      setInterval(() => this.runInsightGeneration(), 6 * HOUR_MS)
    );

    // Run anomaly checks every 4 hours
    this._intervals.push(
      setInterval(() => this.runAnomalyChecks(), 4 * HOUR_MS)
    );

    // Run morning briefing check every hour (delivers once per day via rate limiter)
    this._intervals.push(
      setInterval(() => this.runMorningBriefings(), HOUR_MS)
    );

    // Run weekly reports on Sundays (check every 6 hours)
    this._intervals.push(
      setInterval(() => this.runWeeklyReports(), 6 * HOUR_MS)
    );

    // Run goal review every 12 hours
    this._intervals.push(
      setInterval(() => this.runGoalReview(), 12 * HOUR_MS)
    );

    // Generate weekly plans on Sundays (check every 6 hours)
    this._intervals.push(
      setInterval(() => this.runWeeklyPlanning(), 6 * HOUR_MS)
    );

    // Run initial analysis after a short delay
    setTimeout(() => this.runInsightGeneration(), 30000);
  },

  /**
   * Stop all scheduled jobs (for graceful shutdown).
   */
  shutdown(): void {
    for (const interval of this._intervals) {
      clearInterval(interval);
    }
    this._intervals = [];
    logger.info('Analysis scheduler shut down');
  },

  /**
   * Generate insights for all users.
   */
  async runInsightGeneration(): Promise<void> {
    const userIds = await getAllUserIds();
    logger.info({ userCount: userIds.length }, 'Running insight generation');

    for (const userId of userIds) {
      try {
        await insightGeneratorService.generateFullReport(userId);
      } catch (err) {
        logger.error({ err, userId }, 'Insight generation failed for user');
      }
    }
  },

  /**
   * Check for anomalies and notify users.
   */
  async runAnomalyChecks(): Promise<void> {
    const userIds = await getAllUserIds();
    logger.info({ userCount: userIds.length }, 'Running anomaly checks');

    for (const userId of userIds) {
      try {
        const anomalies = await anomalyDetectorService.detectAnomalies(userId);
        const significant = anomalies.filter(a => a.severity !== 'mild');

        for (const anomaly of significant.slice(0, 2)) {
          await notificationService.send({
            userId,
            title: `Unusual ${anomaly.domain}`,
            body: anomaly.message,
            category: 'anomaly',
          });
        }
      } catch (err) {
        logger.error({ err, userId }, 'Anomaly check failed for user');
      }
    }
  },

  /**
   * Deliver morning briefings. Rate limiter ensures once per day.
   */
  async runMorningBriefings(): Promise<void> {
    const hour = new Date().getHours();
    // Only send between 6 AM and 10 AM
    if (hour < 6 || hour >= 10) return;

    const userIds = await getAllUserIds();
    for (const userId of userIds) {
      try {
        await morningBriefingService.generateForUser(userId);
      } catch (err) {
        logger.error({ err, userId }, 'Morning briefing failed for user');
      }
    }
  },

  /**
   * Deliver weekly reports on Sundays.
   */
  async runWeeklyReports(): Promise<void> {
    const now = new Date();
    if (now.getDay() !== 0) return; // Sunday only

    const userIds = await getAllUserIds();
    logger.info({ userCount: userIds.length }, 'Running weekly reports');

    for (const userId of userIds) {
      try {
        await weeklyReportService.generateForUser(userId);
      } catch (err) {
        logger.error({ err, userId }, 'Weekly report failed for user');
      }
    }
  },

  /**
   * Review goals for all users and generate suggestions.
   */
  async runGoalReview(): Promise<void> {
    const userIds = await getAllUserIds();
    logger.info({ userCount: userIds.length }, 'Running goal review');

    for (const userId of userIds) {
      try {
        const suggestions = await goalAdvisorService.reviewGoals(userId);
        for (const suggestion of suggestions) {
          await notificationService.send({
            userId,
            title: `Goal suggestion: ${suggestion.domain}`,
            body: suggestion.reason,
            category: 'insight',
          });
        }
      } catch (err) {
        logger.error({ err, userId }, 'Goal review failed for user');
      }
    }
  },

  /**
   * Generate weekly plans on Sunday evenings.
   */
  async runWeeklyPlanning(): Promise<void> {
    const now = new Date();
    if (now.getDay() !== 0) return; // Sunday only

    const userIds = await getAllUserIds();
    logger.info({ userCount: userIds.length }, 'Running weekly planning');

    for (const userId of userIds) {
      try {
        const plan = await weeklyPlannerService.generatePlan(userId);
        await notificationService.send({
          userId,
          title: 'Your weekly plan is ready',
          body: plan.aiSummary,
          category: 'reminder',
        });
      } catch (err) {
        logger.error({ err, userId }, 'Weekly planning failed for user');
      }
    }
  },
};
