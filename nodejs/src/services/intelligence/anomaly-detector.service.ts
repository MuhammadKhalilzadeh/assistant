/**
 * Anomaly detector that flags unusual deviations from user baselines.
 * Uses rolling 7-day averages and standard deviations.
 */

import { dataCollectorService, DailyDataPoint } from './data-collector.service';
import { logger } from '../../config/logger';

export interface Anomaly {
  domain: string;
  metric: string;
  value: number;
  baseline: number;
  deviation: number; // standard deviations from baseline
  direction: 'above' | 'below';
  severity: 'mild' | 'notable' | 'significant';
  message: string;
}

const METRIC_CONFIG: {
  key: keyof DailyDataPoint;
  domain: string;
  label: string;
  unit: string;
  format: (v: number) => string;
}[] = [
  { key: 'steps', domain: 'steps', label: 'Step count', unit: 'steps', format: v => `${Math.round(v).toLocaleString()}` },
  { key: 'sleepMinutes', domain: 'sleep', label: 'Sleep duration', unit: 'hours', format: v => `${(v / 60).toFixed(1)}h` },
  { key: 'moodScore', domain: 'mood', label: 'Mood', unit: '/5', format: v => `${v.toFixed(1)}/5` },
  { key: 'waterMl', domain: 'water', label: 'Water intake', unit: 'ml', format: v => `${Math.round(v)}ml` },
  { key: 'workoutMinutes', domain: 'workout', label: 'Workout time', unit: 'min', format: v => `${Math.round(v)}min` },
  { key: 'heartRateAvg', domain: 'heartRate', label: 'Resting heart rate', unit: 'bpm', format: v => `${Math.round(v)} bpm` },
  { key: 'screenTimeMinutes', domain: 'screenTime', label: 'Screen time', unit: 'min', format: v => `${Math.round(v)}min` },
];

function stddev(values: number[]): { mean: number; sd: number } {
  const n = values.length;
  if (n === 0) return { mean: 0, sd: 0 };
  const mean = values.reduce((a, b) => a + b, 0) / n;
  const variance = values.reduce((a, v) => a + (v - mean) * (v - mean), 0) / n;
  return { mean, sd: Math.sqrt(variance) };
}

function classifySeverity(deviations: number): 'mild' | 'notable' | 'significant' {
  if (deviations >= 2.5) return 'significant';
  if (deviations >= 1.5) return 'notable';
  return 'mild';
}

export const anomalyDetectorService = {
  /**
   * Detect anomalies by comparing today's data against the 6-day baseline.
   */
  async detectAnomalies(userId: string): Promise<Anomaly[]> {
    const data = await dataCollectorService.collect7Days(userId);
    if (data.length < 2) return [];

    const anomalies: Anomaly[] = [];
    const today = data[data.length - 1];
    const baseline = data.slice(0, -1); // all days except today

    for (const config of METRIC_CONFIG) {
      const todayVal = today[config.key];
      if (typeof todayVal !== 'number' || todayVal === null) continue;

      // Get baseline values
      const baselineValues: number[] = [];
      for (const day of baseline) {
        const val = day[config.key];
        if (typeof val === 'number' && val !== null) {
          baselineValues.push(val);
        }
      }

      if (baselineValues.length < 3) continue; // need enough baseline

      const { mean, sd } = stddev(baselineValues);
      if (sd === 0) continue; // no variation means no anomalies

      const deviation = Math.abs(todayVal - mean) / sd;
      if (deviation < 1.5) continue; // only flag 1.5+ stddev

      const direction: 'above' | 'below' = todayVal > mean ? 'above' : 'below';
      const severity = classifySeverity(deviation);

      const message = `Your ${config.label.toLowerCase()} today (${config.format(todayVal)}) is ${severity === 'significant' ? 'significantly' : 'noticeably'} ${direction} your usual ${config.format(mean)}`;

      anomalies.push({
        domain: config.domain,
        metric: config.key,
        value: todayVal,
        baseline: Math.round(mean * 10) / 10,
        deviation: Math.round(deviation * 10) / 10,
        direction,
        severity,
        message,
      });
    }

    // Sort by severity (most significant first)
    const severityOrder = { significant: 0, notable: 1, mild: 2 };
    anomalies.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);

    logger.debug({ userId, anomalyCount: anomalies.length }, 'Anomaly detection complete');
    return anomalies;
  },
};
