/**
 * Pattern detector that identifies recurring day-of-week patterns
 * and threshold effects in user data.
 */

import { dataCollectorService, DailyDataPoint } from './data-collector.service';
import { logger } from '../../config/logger';

export interface Pattern {
  type: 'day_of_week' | 'threshold';
  domain: string;
  description: string;
  confidence: number;
  evidence: string;
}

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const DOMAIN_KEYS: { key: keyof DailyDataPoint; domain: string; label: string }[] = [
  { key: 'steps', domain: 'steps', label: 'step count' },
  { key: 'sleepMinutes', domain: 'sleep', label: 'sleep' },
  { key: 'workoutMinutes', domain: 'workout', label: 'workout' },
  { key: 'waterMl', domain: 'water', label: 'water intake' },
  { key: 'screenTimeMinutes', domain: 'screenTime', label: 'screen time' },
  { key: 'meditationMinutes', domain: 'meditation', label: 'meditation' },
];

/** Threshold pairs: if featureA < threshold, featureB drops/rises */
const THRESHOLD_CHECKS: {
  featureA: keyof DailyDataPoint;
  threshold: number;
  featureB: keyof DailyDataPoint;
  labelA: string;
  labelB: string;
  unitA: string;
}[] = [
  {
    featureA: 'sleepMinutes', threshold: 360, // 6 hours
    featureB: 'moodScore',
    labelA: 'sleep', labelB: 'mood', unitA: '6 hours',
  },
  {
    featureA: 'screenTimeMinutes', threshold: 240, // 4 hours
    featureB: 'sleepMinutes',
    labelA: 'screen time', labelB: 'sleep quality', unitA: '4 hours',
  },
  {
    featureA: 'steps', threshold: 5000,
    featureB: 'moodScore',
    labelA: 'steps', labelB: 'mood', unitA: '5,000',
  },
];

export const patternDetectorService = {
  /**
   * Detect day-of-week patterns: which days have consistently high/low values.
   */
  async detectDayOfWeekPatterns(userId: string): Promise<Pattern[]> {
    const data = await dataCollectorService.collect7Days(userId);
    const patterns: Pattern[] = [];

    for (const config of DOMAIN_KEYS) {
      // Group values by day of week
      const dayValues: Map<number, number[]> = new Map();
      for (const point of data) {
        const val = point[config.key];
        if (typeof val !== 'number' || val === null) continue;
        const dayOfWeek = new Date(point.date).getDay();
        if (!dayValues.has(dayOfWeek)) dayValues.set(dayOfWeek, []);
        dayValues.get(dayOfWeek)!.push(val);
      }

      // Calculate overall average
      const allVals = data
        .map(d => d[config.key])
        .filter((v): v is number => typeof v === 'number' && v !== null);
      if (allVals.length < 4) continue;

      const overallAvg = allVals.reduce((a, b) => a + b, 0) / allVals.length;
      if (overallAvg === 0) continue;

      // Find days that deviate significantly from average
      for (const [dayNum, values] of dayValues) {
        if (values.length < 1) continue;
        const dayAvg = values.reduce((a, b) => a + b, 0) / values.length;
        const deviation = (dayAvg - overallAvg) / overallAvg;

        if (Math.abs(deviation) > 0.25) { // 25% deviation threshold
          const dayName = DAY_NAMES[dayNum];
          const dir = deviation > 0 ? 'higher' : 'lower';
          const pct = Math.abs(Math.round(deviation * 100));

          patterns.push({
            type: 'day_of_week',
            domain: config.domain,
            description: `Your ${config.label} is ${pct}% ${dir} on ${dayName}s`,
            confidence: Math.min(0.9, 0.5 + values.length * 0.1),
            evidence: `${dayName} avg: ${Math.round(dayAvg)}, overall avg: ${Math.round(overallAvg)}`,
          });
        }
      }
    }

    return patterns;
  },

  /**
   * Detect threshold effects: when metric A drops below a threshold,
   * metric B is affected.
   */
  async detectThresholds(userId: string): Promise<Pattern[]> {
    const data = await dataCollectorService.collect7Days(userId);
    const patterns: Pattern[] = [];

    for (const check of THRESHOLD_CHECKS) {
      const belowThreshold: number[] = [];
      const aboveThreshold: number[] = [];

      for (const point of data) {
        const valA = point[check.featureA];
        const valB = point[check.featureB];
        if (typeof valA !== 'number' || typeof valB !== 'number') continue;
        if (valA === null || valB === null) continue;

        if (valA < check.threshold) {
          belowThreshold.push(valB);
        } else {
          aboveThreshold.push(valB);
        }
      }

      if (belowThreshold.length < 1 || aboveThreshold.length < 1) continue;

      const avgBelow = belowThreshold.reduce((a, b) => a + b, 0) / belowThreshold.length;
      const avgAbove = aboveThreshold.reduce((a, b) => a + b, 0) / aboveThreshold.length;

      if (avgAbove === 0) continue;
      const diff = (avgAbove - avgBelow) / avgAbove;

      if (Math.abs(diff) > 0.15) { // 15% difference is meaningful
        const impact = diff > 0 ? 'drops' : 'increases';
        const pct = Math.abs(Math.round(diff * 100));

        patterns.push({
          type: 'threshold',
          domain: `${check.labelA}_${check.labelB}`,
          description: `When your ${check.labelA} is below ${check.unitA}, your ${check.labelB} ${impact} by ~${pct}%`,
          confidence: Math.min(0.85, 0.4 + (belowThreshold.length + aboveThreshold.length) * 0.05),
          evidence: `Below: avg ${check.labelB} = ${avgBelow.toFixed(1)}, Above: avg ${check.labelB} = ${avgAbove.toFixed(1)}`,
        });
      }
    }

    logger.debug({ userId, patternCount: patterns.length }, 'Pattern detection complete');
    return patterns;
  },
};
