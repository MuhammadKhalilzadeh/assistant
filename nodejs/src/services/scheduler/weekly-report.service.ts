/**
 * Generates a comprehensive weekly progress report for a user.
 * Covers all domains with week-over-week comparisons.
 */

import { dataContextService } from '../brain/data-context.service';
import { correlationService } from '../intelligence/correlation.service';
import { trendAnalyzerService } from '../intelligence/trend-analyzer.service';
import { notificationService } from '../notification/notification.service';
import { logger } from '../../config/logger';

export interface WeeklyReportData {
  userId: string;
  generatedAt: string;
  summary: string;
  highlights: string[];
  concerns: string[];
  correlations: string[];
  trends: string[];
  recommendations: string[];
}

export const weeklyReportService = {
  /**
   * Generate a weekly report for a user.
   */
  async generateForUser(userId: string): Promise<WeeklyReportData> {
    const context = await dataContextService.buildContext(userId, 'full');
    const correlations = await correlationService.analyzeAll(userId);
    const trends = await trendAnalyzerService.analyzeTrends(userId);

    const highlights: string[] = [];
    const concerns: string[] = [];
    const recommendations: string[] = [];

    // Extract trends
    const trendSummaries: string[] = [];
    for (const t of trends) {
      trendSummaries.push(t.summary);
      if (t.direction === 'improving') {
        highlights.push(`${t.label} is trending up`);
      } else if (t.direction === 'declining') {
        concerns.push(`${t.label} is trending down`);
        recommendations.push(
          `Consider focusing on your ${t.label.toLowerCase()} this week`
        );
      }
    }

    // Correlation highlights
    const corrSummaries: string[] = [];
    for (const c of correlations.slice(0, 3)) {
      corrSummaries.push(c.humanReadable);
    }

    // Build report text
    const parts: string[] = [];
    parts.push('Weekly Progress Report\n');
    parts.push(context || 'No data available for this week.');

    if (highlights.length > 0) {
      parts.push('\n--- Highlights ---');
      for (const h of highlights) parts.push(`+ ${h}`);
    }

    if (concerns.length > 0) {
      parts.push('\n--- Needs Attention ---');
      for (const c of concerns) parts.push(`- ${c}`);
    }

    if (corrSummaries.length > 0) {
      parts.push('\n--- Discovered Patterns ---');
      for (const c of corrSummaries) parts.push(`- ${c}`);
    }

    if (recommendations.length > 0) {
      parts.push('\n--- Recommendations ---');
      for (const r of recommendations) parts.push(`> ${r}`);
    }

    const report: WeeklyReportData = {
      userId,
      generatedAt: new Date().toISOString(),
      summary: parts.join('\n'),
      highlights,
      concerns,
      correlations: corrSummaries,
      trends: trendSummaries,
      recommendations,
    };

    // Send as notification
    await notificationService.send({
      userId,
      title: 'Your Weekly Progress Report',
      body: parts.join('\n'),
      category: 'weekly_report',
    });

    logger.debug({ userId }, 'Weekly report generated');
    return report;
  },
};
