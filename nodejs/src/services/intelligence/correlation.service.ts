/**
 * Statistical correlation engine that discovers relationships between
 * data domains using Pearson correlation coefficients.
 */

import { dataCollectorService, NormalizedDataPoint } from './data-collector.service';
import { logger } from '../../config/logger';

export interface CorrelationResult {
  featureA: string;
  featureB: string;
  coefficient: number; // Pearson r: -1.0 to 1.0
  strength: 'weak' | 'moderate' | 'strong';
  direction: 'positive' | 'negative';
  sampleSize: number;
  confidence: number; // 0-1
  humanReadable: string;
}

/** Pre-defined high-value correlation pairs to test */
const CORRELATION_PAIRS: [string, string][] = [
  ['sleepQuality', 'moodScore'],
  ['sleepHours', 'steps'],
  ['screenTime', 'sleepQuality'],
  ['screenTime', 'moodScore'],
  ['workoutMinutes', 'moodScore'],
  ['workoutMinutes', 'sleepQuality'],
  ['waterMl', 'moodScore'],
  ['meditationMinutes', 'moodScore'],
  ['meditationMinutes', 'sleepQuality'],
  ['focusMinutes', 'screenTime'],
  ['steps', 'moodScore'],
  ['sleepHours', 'heartRate'],
];

/** Human-readable labels for feature keys */
const FEATURE_LABELS: Record<string, string> = {
  steps: 'step count',
  sleepHours: 'sleep duration',
  sleepQuality: 'sleep quality',
  moodScore: 'mood',
  waterMl: 'water intake',
  workoutMinutes: 'workout time',
  meditationMinutes: 'meditation',
  focusMinutes: 'focus time',
  screenTime: 'screen time',
  heartRate: 'resting heart rate',
  calories: 'calorie intake',
};

/**
 * Calculate Pearson correlation coefficient between two arrays.
 * Returns null if not enough data points.
 */
function pearsonCorrelation(x: number[], y: number[]): number | null {
  const n = x.length;
  if (n < 3) return null;

  const sumX = x.reduce((a, b) => a + b, 0);
  const sumY = y.reduce((a, b) => a + b, 0);
  const sumXY = x.reduce((a, xi, i) => a + xi * y[i], 0);
  const sumX2 = x.reduce((a, xi) => a + xi * xi, 0);
  const sumY2 = y.reduce((a, yi) => a + yi * yi, 0);

  const numerator = n * sumXY - sumX * sumY;
  const denominator = Math.sqrt(
    (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY)
  );

  if (denominator === 0) return null;
  return numerator / denominator;
}

function classifyStrength(r: number): 'weak' | 'moderate' | 'strong' {
  const absR = Math.abs(r);
  if (absR >= 0.6) return 'strong';
  if (absR >= 0.3) return 'moderate';
  return 'weak';
}

function buildHumanReadable(
  featureA: string,
  featureB: string,
  coefficient: number,
  strength: string,
  sampleSize: number,
): string {
  const labelA = FEATURE_LABELS[featureA] || featureA;
  const labelB = FEATURE_LABELS[featureB] || featureB;
  const dir = coefficient > 0 ? 'higher' : 'lower';
  const relationship = coefficient > 0 ? 'increases with' : 'decreases with';

  if (strength === 'strong') {
    return `Strong connection: your ${labelB} tends to be ${dir} on days with more ${labelA} (based on ${sampleSize} days)`;
  }
  return `Your ${labelB} ${relationship} your ${labelA} (${strength}, ${sampleSize} days of data)`;
}

export const correlationService = {
  /**
   * Run all predefined correlation pairs for a user.
   * Returns only moderate+ correlations to avoid noise.
   */
  async analyzeAll(userId: string): Promise<CorrelationResult[]> {
    const rawData = await dataCollectorService.collect7Days(userId);
    const normalized = dataCollectorService.normalize(rawData);

    const results: CorrelationResult[] = [];

    for (const [featureA, featureB] of CORRELATION_PAIRS) {
      const result = this.correlatePair(normalized, featureA, featureB);
      if (result && result.strength !== 'weak') {
        results.push(result);
      }
    }

    // Sort by absolute coefficient (strongest first)
    results.sort((a, b) => Math.abs(b.coefficient) - Math.abs(a.coefficient));

    logger.debug(
      { userId, totalPairs: CORRELATION_PAIRS.length, found: results.length },
      'Correlation analysis complete'
    );

    return results;
  },

  /**
   * Correlate a specific pair of features from normalized data.
   */
  correlatePair(
    data: NormalizedDataPoint[],
    featureA: string,
    featureB: string,
  ): CorrelationResult | null {
    // Extract paired values where both features have data
    const xVals: number[] = [];
    const yVals: number[] = [];

    for (const point of data) {
      const x = point[featureA];
      const y = point[featureB];
      if (typeof x === 'number' && typeof y === 'number' && x !== null && y !== null) {
        xVals.push(x);
        yVals.push(y);
      }
    }

    const r = pearsonCorrelation(xVals, yVals);
    if (r === null) return null;

    const strength = classifyStrength(r);
    const direction = r >= 0 ? 'positive' : 'negative';
    // Simple confidence based on sample size and effect size
    const confidence = Math.min(0.95, (xVals.length / 7) * (Math.abs(r) + 0.2));

    return {
      featureA,
      featureB,
      coefficient: Math.round(r * 100) / 100,
      strength,
      direction,
      sampleSize: xVals.length,
      confidence: Math.round(confidence * 100) / 100,
      humanReadable: buildHumanReadable(featureA, featureB, r, strength, xVals.length),
    };
  },
};
