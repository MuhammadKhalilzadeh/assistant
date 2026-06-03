/**
 * Weekly Planner: generates personalized weekly plans based on
 * trends, patterns, and performance data.
 */

import { trendAnalyzerService } from '../intelligence/trend-analyzer.service';
import { correlationService } from '../intelligence/correlation.service';
import { dataCollectorService } from '../intelligence/data-collector.service';
import { weeklyPlanModel, WeeklyPlan, DayPlan } from '../../models/weekly-plan.model';
import { logger } from '../../config/logger';

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/** Domains that can have daily recommendations */
const ACTIVITY_DOMAINS = [
  { domain: 'workout', activity: 'Workout', defaultDuration: 30 },
  { domain: 'meditation', activity: 'Meditation', defaultDuration: 15 },
  { domain: 'steps', activity: 'Walking', defaultDuration: 30 },
  { domain: 'water', activity: 'Hydration focus', defaultDuration: 0 },
  { domain: 'sleep', activity: 'Sleep hygiene', defaultDuration: 0 },
];

export const weeklyPlannerService = {
  /**
   * Generate a weekly plan for the upcoming week.
   */
  async generatePlan(userId: string): Promise<WeeklyPlan> {
    // Gather intelligence
    const [trends, correlations, rawData] = await Promise.all([
      trendAnalyzerService.analyzeTrends(userId),
      correlationService.analyzeAll(userId),
      dataCollectorService.collect7Days(userId),
    ]);

    // Determine the upcoming week
    const now = new Date();
    const dayOfWeek = now.getDay();
    const nextMonday = new Date(now);
    nextMonday.setDate(now.getDate() + (7 - dayOfWeek + 1) % 7 || 7);
    const nextSunday = new Date(nextMonday);
    nextSunday.setDate(nextMonday.getDate() + 6);

    // Identify focus areas from declining trends
    const focusAreas: string[] = [];
    const decliningDomains: string[] = [];
    for (const trend of trends) {
      if (trend.direction === 'declining') {
        focusAreas.push(`Improve ${trend.label.toLowerCase()}`);
        decliningDomains.push(trend.domain);
      } else if (trend.direction === 'improving') {
        focusAreas.push(`Maintain ${trend.label.toLowerCase()} momentum`);
      }
    }

    if (focusAreas.length === 0) {
      focusAreas.push('Maintain current progress across all domains');
    }

    // Calculate per-day average values from last week for baseline
    const avgValues: Record<string, number> = {};
    for (const day of rawData) {
      for (const [key, val] of Object.entries(day)) {
        if (key === 'date' || val === null || typeof val !== 'number') continue;
        if (!avgValues[key]) avgValues[key] = 0;
        avgValues[key] += val / rawData.length;
      }
    }

    // Generate day plans
    const days: DayPlan[] = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(nextMonday);
      date.setDate(nextMonday.getDate() + i);
      const dateStr = date.toISOString().split('T')[0];
      const dayName = DAY_NAMES[date.getDay()];
      const isWeekend = date.getDay() === 0 || date.getDay() === 6;

      const recommendations: DayPlan['recommendations'] = [];
      const targets: DayPlan['targets'] = [];

      for (const activity of ACTIVITY_DOMAINS) {
        const trend = trends.find(t => t.domain === activity.domain);
        const isDeclining = decliningDomains.includes(activity.domain);

        // Workout: alternate intensity, rest days
        if (activity.domain === 'workout') {
          if (i % 3 === 2) {
            // Rest day every 3rd day
            targets.push({
              domain: 'workout',
              target: 0,
              rationale: 'Rest day for recovery',
            });
          } else {
            const duration = isDeclining
              ? Math.max(20, activity.defaultDuration - 5) // Slightly easier if declining
              : activity.defaultDuration;
            recommendations.push({
              activity: i % 2 === 0 ? 'Strength training' : 'Cardio',
              domain: activity.domain,
              suggestedTime: isWeekend ? '09:00' : '07:00',
              duration,
              priority: isDeclining ? 'must_do' : 'should_do',
              reason: isDeclining
                ? `${activity.activity} has been declining — let's rebuild the habit`
                : 'Regular exercise for overall wellness',
            });
          }
        }

        // Meditation: daily
        if (activity.domain === 'meditation') {
          const duration = isDeclining ? 10 : 15;
          recommendations.push({
            activity: i % 2 === 0 ? 'Morning meditation' : 'Evening wind-down',
            domain: activity.domain,
            suggestedTime: i % 2 === 0 ? '07:30' : '21:00',
            duration,
            priority: isDeclining ? 'should_do' : 'nice_to_do',
            reason: 'Consistent mindfulness practice',
          });
        }

        // Steps target
        if (activity.domain === 'steps') {
          const baseTarget = avgValues['steps'] || 8000;
          const target = isDeclining
            ? Math.round(baseTarget * 0.95) // Slightly lower if declining
            : Math.round(baseTarget * 1.05); // Slightly higher if doing well
          targets.push({
            domain: 'steps',
            target: Math.round(target / 100) * 100, // Round to nearest 100
            rationale: isDeclining
              ? 'Slightly reduced target to rebuild momentum'
              : 'Gradually increasing towards your potential',
          });
        }

        // Water target
        if (activity.domain === 'water') {
          targets.push({
            domain: 'water',
            target: 2500,
            rationale: 'Consistent daily hydration',
          });
        }

        // Sleep target
        if (activity.domain === 'sleep') {
          targets.push({
            domain: 'sleep',
            target: 480, // 8 hours in minutes
            rationale: isWeekend
              ? 'Weekend — aim for extra rest'
              : 'Consistent sleep schedule on workdays',
          });
        }
      }

      days.push({
        date: dateStr,
        dayOfWeek: dayName,
        recommendations,
        targets,
      });
    }

    // Generate AI summary
    const summaryParts: string[] = [];
    summaryParts.push(`This week's focus: ${focusAreas.slice(0, 3).join(', ')}.`);

    if (correlations.length > 0) {
      const topCorr = correlations[0];
      summaryParts.push(`Key insight: ${topCorr.humanReadable}.`);
    }

    const workoutDays = days.filter(d =>
      d.recommendations.some(r => r.domain === 'workout')
    ).length;
    summaryParts.push(
      `Plan includes ${workoutDays} workout days with rest days for recovery.`
    );

    const plan = await weeklyPlanModel.create(userId, {
      weekStart: nextMonday.toISOString().split('T')[0],
      weekEnd: nextSunday.toISOString().split('T')[0],
      days,
      focusAreas: focusAreas.slice(0, 5),
      aiSummary: summaryParts.join(' '),
      status: 'active',
    });

    logger.info({ userId, planId: plan.id }, 'Weekly plan generated');
    return plan;
  },
};
