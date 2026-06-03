/**
 * Combines correlations, patterns, anomalies, and trends into
 * ranked, human-readable insights stored in the DB.
 */

import { correlationService, CorrelationResult } from './correlation.service';
import { trendAnalyzerService, Trend } from './trend-analyzer.service';
import { anomalyDetectorService, Anomaly } from './anomaly-detector.service';
import { patternDetectorService, Pattern } from './pattern-detector.service';
import { insightModel } from '../../models/insight.model';
import { logger } from '../../config/logger';

export interface IntelligenceReport {
  correlations: CorrelationResult[];
  trends: Trend[];
  anomalies: Anomaly[];
  patterns: Pattern[];
  generatedInsights: number;
}

export const insightGeneratorService = {
  /**
   * Run the full intelligence pipeline for a user:
   * collect data -> correlations + trends + anomalies + patterns -> store insights.
   */
  async generateFullReport(userId: string): Promise<IntelligenceReport> {
    // Run all analysis engines in parallel
    const [correlations, trends, anomalies, dayPatterns, thresholdPatterns] =
      await Promise.all([
        correlationService.analyzeAll(userId),
        trendAnalyzerService.analyzeTrends(userId),
        anomalyDetectorService.detectAnomalies(userId),
        patternDetectorService.detectDayOfWeekPatterns(userId),
        patternDetectorService.detectThresholds(userId),
      ]);

    const patterns = [...dayPatterns, ...thresholdPatterns];
    let generatedInsights = 0;

    // Store correlation insights (moderate+ only)
    for (const corr of correlations) {
      if (corr.strength === 'weak') continue;
      try {
        await insightModel.create(userId, {
          type: 'correlation',
          domains: [corr.featureA, corr.featureB],
          title: `${corr.featureA} & ${corr.featureB} connection`,
          description: corr.humanReadable,
          confidence: corr.confidence,
          data: {
            coefficient: corr.coefficient,
            strength: corr.strength,
            direction: corr.direction,
            sampleSize: corr.sampleSize,
          },
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        });
        generatedInsights++;
      } catch (err) {
        logger.debug({ err }, 'Failed to store correlation insight');
      }
    }

    // Store trend insights (non-stable only)
    for (const trend of trends) {
      if (trend.direction === 'stable') continue;
      try {
        await insightModel.create(userId, {
          type: 'trend',
          domains: [trend.domain],
          title: `${trend.label} trend`,
          description: trend.summary,
          confidence: Math.min(0.9, 0.5 + trend.values.length * 0.05),
          data: {
            direction: trend.direction,
            momentum: trend.momentum,
            currentValue: trend.currentValue,
            averageValue: trend.averageValue,
            sparkline: trend.values,
          },
          expiresAt: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 3 days
        });
        generatedInsights++;
      } catch (err) {
        logger.debug({ err }, 'Failed to store trend insight');
      }
    }

    // Store anomaly insights
    for (const anomaly of anomalies) {
      try {
        await insightModel.create(userId, {
          type: 'anomaly',
          domains: [anomaly.domain],
          title: `Unusual ${anomaly.domain}`,
          description: anomaly.message,
          confidence: Math.min(0.95, 0.5 + anomaly.deviation * 0.15),
          data: {
            value: anomaly.value,
            baseline: anomaly.baseline,
            deviation: anomaly.deviation,
            severity: anomaly.severity,
            direction: anomaly.direction,
          },
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 1 day
        });
        generatedInsights++;
      } catch (err) {
        logger.debug({ err }, 'Failed to store anomaly insight');
      }
    }

    // Store pattern insights
    for (const pattern of patterns) {
      try {
        await insightModel.create(userId, {
          type: 'pattern',
          domains: [pattern.domain],
          title: pattern.type === 'day_of_week' ? 'Weekly pattern' : 'Threshold effect',
          description: pattern.description,
          confidence: pattern.confidence,
          data: {
            type: pattern.type,
            evidence: pattern.evidence,
          },
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        });
        generatedInsights++;
      } catch (err) {
        logger.debug({ err }, 'Failed to store pattern insight');
      }
    }

    logger.info(
      {
        userId,
        correlations: correlations.length,
        trends: trends.length,
        anomalies: anomalies.length,
        patterns: patterns.length,
        stored: generatedInsights,
      },
      'Full intelligence report generated'
    );

    return { correlations, trends, anomalies, patterns, generatedInsights };
  },
};
