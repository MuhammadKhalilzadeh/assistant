/**
 * Generates a personalized morning briefing for each user.
 * Includes: today's weather, yesterday's summary, active streaks,
 * scheduled events, streak alerts, and a motivational nudge.
 */

import { dataContextService } from '../brain/data-context.service';
import { anomalyDetectorService } from '../intelligence/anomaly-detector.service';
import { trendAnalyzerService } from '../intelligence/trend-analyzer.service';
import { notificationService } from '../notification/notification.service';
import { logger } from '../../config/logger';

export const morningBriefingService = {
  /**
   * Generate and deliver a morning briefing for a user.
   */
  async generateForUser(userId: string): Promise<void> {
    try {
      const context = await dataContextService.buildContext(userId, 'detailed');
      const anomalies = await anomalyDetectorService.detectAnomalies(userId);
      const trends = await trendAnalyzerService.analyzeTrends(userId);

      const parts: string[] = [];
      parts.push('Good morning! Here\'s your daily briefing:\n');

      // Add data summary
      if (context) {
        // Extract key lines from the context
        const lines = context.split('\n').filter(l => l.trim().length > 0);
        const keyLines = lines.slice(0, 8); // First 8 meaningful lines
        parts.push(keyLines.join('\n'));
      }

      // Anomaly alerts
      const notableAnomalies = anomalies.filter(a => a.severity !== 'mild');
      if (notableAnomalies.length > 0) {
        parts.push('\n--- Heads up ---');
        for (const a of notableAnomalies.slice(0, 3)) {
          parts.push(`- ${a.message}`);
        }
      }

      // Trending topics
      const activeTrends = trends.filter(t => t.direction !== 'stable');
      if (activeTrends.length > 0) {
        parts.push('\n--- Trends ---');
        for (const t of activeTrends.slice(0, 3)) {
          parts.push(`- ${t.summary}`);
        }
      }

      parts.push('\nHave a great day!');

      await notificationService.send({
        userId,
        title: 'Morning Briefing',
        body: parts.join('\n'),
        category: 'morning_briefing',
      });

      logger.debug({ userId }, 'Morning briefing generated');
    } catch (err) {
      logger.error({ err, userId }, 'Failed to generate morning briefing');
    }
  },
};
