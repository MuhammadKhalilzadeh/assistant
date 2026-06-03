/**
 * Collects and normalizes 7-day historical data from all domain models
 * into a unified format for correlation, trend, and anomaly analysis.
 */

import { stepsModel } from '../../models/steps.model';
import { sleepModel } from '../../models/sleep.model';
import { heartRateModel } from '../../models/heart_rate.model';
import { workoutModel } from '../../models/workout.model';
import { caloriesModel } from '../../models/calories.model';
import { waterModel } from '../../models/water.model';
import { moodModel } from '../../models/mood.model';
import { meditationModel } from '../../models/meditation.model';
import { focusTimerModel } from '../../models/focus-timer.model';
import { screenTimeModel } from '../../models/screen-time.model';
import { logger } from '../../config/logger';

/** Mood string to numeric value mapping */
const MOOD_VALUES: Record<string, number> = {
  great: 5,
  good: 4,
  okay: 3,
  bad: 2,
  awful: 1,
};

/** Sleep quality string to numeric value */
const SLEEP_QUALITY_VALUES: Record<string, number> = {
  excellent: 4,
  good: 3,
  fair: 2,
  poor: 1,
};

/** A single day's normalized data across all domains */
export interface DailyDataPoint {
  date: string; // YYYY-MM-DD
  steps: number | null;
  sleepMinutes: number | null;
  sleepQuality: number | null; // 1-4
  moodScore: number | null; // 1-5
  waterMl: number | null;
  workoutMinutes: number | null;
  meditationMinutes: number | null;
  focusMinutes: number | null;
  screenTimeMinutes: number | null;
  heartRateAvg: number | null;
  caloriesConsumed: number | null;
}

/** Normalized 0-1 version of DailyDataPoint for correlation math */
export interface NormalizedDataPoint {
  date: string;
  [key: string]: number | null | string;
}

async function fetchSafe<T>(fn: () => Promise<T>): Promise<T | null> {
  try {
    return await fn();
  } catch (err) {
    logger.debug({ err }, 'Intelligence data fetch failed');
    return null;
  }
}

export const dataCollectorService = {
  /**
   * Collect 7-day historical data for a user from all domains.
   */
  async collect7Days(userId: string): Promise<DailyDataPoint[]> {
    // Fetch all domains in parallel
    const [
      steps, sleep, mood, water, workout,
      meditation, focus, screenTime, heartRate, calories,
    ] = await Promise.all([
      fetchSafe(() => stepsModel.getLast7Days(userId)),
      fetchSafe(() => sleepModel.getLast7Days(userId)),
      fetchSafe(() => moodModel.getLast7Days(userId)),
      fetchSafe(() => waterModel.getLast7Days(userId)),
      fetchSafe(() => workoutModel.getLast7Days(userId)),
      fetchSafe(() => meditationModel.getLast7Days(userId)),
      fetchSafe(() => focusTimerModel.getLast7Days(userId)),
      fetchSafe(() => screenTimeModel.getHistory(userId)),
      fetchSafe(() => heartRateModel.getLast7Days(userId)),
      fetchSafe(() => caloriesModel.getLast7Days(userId)),
    ]);

    // Build date-indexed maps for each domain
    const stepsMap = new Map((steps ?? []).map(d => [d.date, d]));
    const sleepMap = new Map((sleep ?? []).map(d => [d.date, d]));
    const moodMap = new Map((mood ?? []).map(d => [d.date, d]));
    const waterMap = new Map((water ?? []).map(d => [d.date, d]));
    const workoutMap = new Map((workout ?? []).map(d => [d.date, d]));
    const meditationMap = new Map((meditation ?? []).map(d => [d.date, d]));
    const focusMap = new Map((focus ?? []).map(d => [d.date, d]));
    const screenMap = new Map((screenTime ?? []).map(d => [d.date, d]));
    const hrMap = new Map((heartRate ?? []).map(d => [d.date, d]));
    const calMap = new Map((calories ?? []).map(d => [d.date, d]));

    // Build unified daily data points for the last 7 days
    const result: DailyDataPoint[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const s = stepsMap.get(dateStr);
      const sl = sleepMap.get(dateStr);
      const m = moodMap.get(dateStr);
      const w = waterMap.get(dateStr);
      const wo = workoutMap.get(dateStr);
      const med = meditationMap.get(dateStr);
      const f = focusMap.get(dateStr);
      const sc = screenMap.get(dateStr);
      const hr = hrMap.get(dateStr);
      const cal = calMap.get(dateStr);

      result.push({
        date: dateStr,
        steps: s?.steps ?? null,
        sleepMinutes: sl?.durationMinutes ?? null,
        sleepQuality: sl?.quality ? (SLEEP_QUALITY_VALUES[sl.quality] ?? null) : null,
        moodScore: m?.dominantMood ? (MOOD_VALUES[m.dominantMood] ?? null) : null,
        waterMl: w?.totalMl ?? null,
        workoutMinutes: wo?.totalMinutes ?? null,
        meditationMinutes: med?.totalMinutes ?? null,
        focusMinutes: f?.totalMinutes ?? null,
        screenTimeMinutes: sc?.totalMinutes ?? null,
        heartRateAvg: hr?.avgBpm ?? null,
        caloriesConsumed: cal?.totalCalories ?? null,
      });
    }

    return result;
  },

  /**
   * Normalize data to 0-1 scales for correlation analysis.
   */
  normalize(data: DailyDataPoint[]): NormalizedDataPoint[] {
    return data.map(d => ({
      date: d.date,
      steps: d.steps != null ? Math.min(d.steps / 15000, 1) : null,
      sleepHours: d.sleepMinutes != null ? Math.min(d.sleepMinutes / 720, 1) : null, // max 12h
      sleepQuality: d.sleepQuality != null ? (d.sleepQuality - 1) / 3 : null, // 1-4 -> 0-1
      moodScore: d.moodScore != null ? (d.moodScore - 1) / 4 : null, // 1-5 -> 0-1
      waterMl: d.waterMl != null ? Math.min(d.waterMl / 3000, 1) : null,
      workoutMinutes: d.workoutMinutes != null ? Math.min(d.workoutMinutes / 60, 1) : null,
      meditationMinutes: d.meditationMinutes != null ? Math.min(d.meditationMinutes / 30, 1) : null,
      focusMinutes: d.focusMinutes != null ? Math.min(d.focusMinutes / 240, 1) : null,
      screenTime: d.screenTimeMinutes != null ? 1 - Math.min(d.screenTimeMinutes / 720, 1) : null, // inverted
      heartRate: d.heartRateAvg != null ? 1 - Math.min(Math.max(d.heartRateAvg - 40, 0) / 60, 1) : null, // lower better
      calories: d.caloriesConsumed != null ? Math.min(d.caloriesConsumed / 3000, 1) : null,
    }));
  },
};
