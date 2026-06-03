/**
 * Trend analyzer that computes 7-day direction, momentum, and sparkline
 * data for each domain.
 */

import { dataCollectorService, DailyDataPoint } from './data-collector.service';
import { logger } from '../../config/logger';

export interface Trend {
  domain: string;
  label: string;
  direction: 'improving' | 'declining' | 'stable';
  momentum: number; // rate of change, -1 to 1
  values: number[]; // daily values for sparkline
  currentValue: number;
  averageValue: number;
  summary: string;
}

/** Domain config: which field to read, label, unit, whether higher is better */
const DOMAIN_CONFIG: {
  key: keyof DailyDataPoint;
  domain: string;
  label: string;
  unit: string;
  higherIsBetter: boolean;
}[] = [
  { key: 'steps', domain: 'steps', label: 'Steps', unit: 'steps', higherIsBetter: true },
  { key: 'sleepMinutes', domain: 'sleep', label: 'Sleep', unit: 'min', higherIsBetter: true },
  { key: 'moodScore', domain: 'mood', label: 'Mood', unit: '/5', higherIsBetter: true },
  { key: 'waterMl', domain: 'water', label: 'Water', unit: 'ml', higherIsBetter: true },
  { key: 'workoutMinutes', domain: 'workout', label: 'Workout', unit: 'min', higherIsBetter: true },
  { key: 'meditationMinutes', domain: 'meditation', label: 'Meditation', unit: 'min', higherIsBetter: true },
  { key: 'focusMinutes', domain: 'focus', label: 'Focus', unit: 'min', higherIsBetter: true },
  { key: 'screenTimeMinutes', domain: 'screenTime', label: 'Screen Time', unit: 'min', higherIsBetter: false },
  { key: 'heartRateAvg', domain: 'heartRate', label: 'Heart Rate', unit: 'bpm', higherIsBetter: false },
  { key: 'caloriesConsumed', domain: 'calories', label: 'Calories', unit: 'kcal', higherIsBetter: true },
];

/**
 * Simple linear regression: returns slope normalized to [-1, 1].
 */
function linearTrend(values: number[]): number {
  const n = values.length;
  if (n < 2) return 0;

  const xMean = (n - 1) / 2;
  const yMean = values.reduce((a, b) => a + b, 0) / n;

  let numerator = 0;
  let denominator = 0;
  for (let i = 0; i < n; i++) {
    numerator += (i - xMean) * (values[i] - yMean);
    denominator += (i - xMean) * (i - xMean);
  }

  if (denominator === 0) return 0;
  const slope = numerator / denominator;

  // Normalize slope relative to mean
  if (yMean === 0) return 0;
  return Math.max(-1, Math.min(1, (slope * n) / yMean));
}

export const trendAnalyzerService = {
  /**
   * Analyze trends across all domains for the last 7 days.
   */
  async analyzeTrends(userId: string): Promise<Trend[]> {
    const rawData = await dataCollectorService.collect7Days(userId);
    const trends: Trend[] = [];

    for (const config of DOMAIN_CONFIG) {
      const values: number[] = [];
      for (const day of rawData) {
        const val = day[config.key];
        if (typeof val === 'number' && val !== null) {
          values.push(val);
        }
      }

      // Need at least 3 data points for a meaningful trend
      if (values.length < 3) continue;

      const momentum = linearTrend(values);
      const avg = values.reduce((a, b) => a + b, 0) / values.length;
      const current = values[values.length - 1];

      // Determine direction considering whether higher is better
      let direction: 'improving' | 'declining' | 'stable';
      const threshold = 0.1; // 10% change is meaningful
      if (Math.abs(momentum) < threshold) {
        direction = 'stable';
      } else if (config.higherIsBetter) {
        direction = momentum > 0 ? 'improving' : 'declining';
      } else {
        direction = momentum < 0 ? 'improving' : 'declining';
      }

      // Build summary
      const pctChange = Math.abs(momentum * 100).toFixed(0);
      let summary: string;
      if (direction === 'stable') {
        summary = `${config.label} is stable at ${formatValue(avg, config)}`;
      } else if (direction === 'improving') {
        summary = `${config.label} ${config.higherIsBetter ? 'up' : 'down'} ${pctChange}% — trending in the right direction`;
      } else {
        summary = `${config.label} ${config.higherIsBetter ? 'down' : 'up'} ${pctChange}% over the past week`;
      }

      trends.push({
        domain: config.domain,
        label: config.label,
        direction,
        momentum: Math.round(momentum * 100) / 100,
        values,
        currentValue: current,
        averageValue: Math.round(avg * 10) / 10,
        summary,
      });
    }

    logger.debug({ userId, trendCount: trends.length }, 'Trend analysis complete');
    return trends;
  },
};

function formatValue(val: number, config: { key: string; unit: string }): string {
  if (config.key === 'sleepMinutes') {
    return `${(val / 60).toFixed(1)}h`;
  }
  if (config.key === 'moodScore') {
    return `${val.toFixed(1)}/5`;
  }
  return `${Math.round(val)} ${config.unit}`;
}
