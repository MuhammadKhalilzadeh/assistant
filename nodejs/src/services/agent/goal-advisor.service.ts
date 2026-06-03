/**
 * Goal Advisor: analyzes trends and recommends goal adjustments.
 * Rules:
 * - Goal met 6+/7 days AND avg 120%+ of goal → suggest increase
 * - Goal met 1-/7 days AND avg <60% of goal → suggest decrease
 * - Never suggest more than 20% change at once
 * - Don't re-suggest a rejected domain for 30 days
 * - Max 3 suggestions per week
 */

import { dataCollectorService } from '../intelligence/data-collector.service';
import { goalSuggestionModel, GoalSuggestion } from '../../models/goal-suggestion.model';
import { stepsModel } from '../../models/steps.model';
import { waterModel } from '../../models/water.model';
import { workoutModel } from '../../models/workout.model';
import { logger } from '../../config/logger';

interface DomainGoalInfo {
  domain: string;
  label: string;
  unit: string;
  getGoal: (userId: string) => Promise<number>;
}

const GOAL_DOMAINS: DomainGoalInfo[] = [
  {
    domain: 'steps',
    label: 'Daily Steps',
    unit: 'steps',
    getGoal: async (userId: string) => {
      const stats = await stepsModel.getStats(userId);
      return stats.dailyGoal || 10000;
    },
  },
  {
    domain: 'water',
    label: 'Daily Water',
    unit: 'ml',
    getGoal: async (userId: string) => {
      const stats = await waterModel.getStats(userId);
      return stats.dailyGoalMl || 2500;
    },
  },
  {
    domain: 'sleep',
    label: 'Sleep Duration',
    unit: 'min',
    getGoal: async (_userId: string) => {
      // Sleep goal: default 8 hours (480 min)
      return 480;
    },
  },
  {
    domain: 'workout',
    label: 'Workout Duration',
    unit: 'min',
    getGoal: async (userId: string) => {
      const stats = await workoutModel.getStats(userId);
      return stats.weeklySessions ? stats.weeklySessions * 30 : 150; // use actual weekly sessions as baseline
    },
  },
  {
    domain: 'meditation',
    label: 'Meditation',
    unit: 'min',
    getGoal: async (_userId: string) => {
      // Meditation goal: default 15 min/day
      return 15;
    },
  },
];

const DOMAIN_VALUE_KEY: Record<string, string> = {
  steps: 'steps',
  water: 'waterMl',
  sleep: 'sleepMinutes',
  workout: 'workoutMinutes',
  meditation: 'meditationMinutes',
};

export const goalAdvisorService = {
  /**
   * Review all domains and generate goal suggestions.
   */
  async reviewGoals(userId: string): Promise<GoalSuggestion[]> {
    const data = await dataCollectorService.collect7Days(userId);
    const suggestions: GoalSuggestion[] = [];

    // Check how many pending suggestions exist this week
    const pending = await goalSuggestionModel.findPending(userId);
    if (pending.length >= 3) {
      logger.debug({ userId }, 'Max pending suggestions reached, skipping goal review');
      return [];
    }

    for (const domainInfo of GOAL_DOMAINS) {
      try {
        // Skip if recently rejected
        const rejected = await goalSuggestionModel.wasRecentlyRejected(userId, domainInfo.domain);
        if (rejected) continue;

        const currentGoal = await domainInfo.getGoal(userId);
        if (currentGoal <= 0) continue;

        // Get values for this domain
        const valueKey = DOMAIN_VALUE_KEY[domainInfo.domain];
        const values: number[] = [];
        let goalMetDays = 0;

        for (const day of data) {
          const val = (day as unknown as Record<string, unknown>)[valueKey];
          if (typeof val === 'number' && val !== null) {
            values.push(val);
            if (val >= currentGoal) goalMetDays++;
          }
        }

        if (values.length < 5) continue; // Need enough data

        const avg = values.reduce((a, b) => a + b, 0) / values.length;
        const ratioToGoal = avg / currentGoal;

        // Check for increase suggestion
        if (goalMetDays >= 6 && ratioToGoal >= 1.2) {
          const increase = Math.min(0.2, ratioToGoal - 1); // Max 20% increase
          const suggestedGoal = Math.round(currentGoal * (1 + increase));

          const suggestion = await goalSuggestionModel.create(userId, {
            domain: domainInfo.domain,
            currentGoal,
            suggestedGoal,
            direction: 'increase',
            reason: `You've hit your ${domainInfo.label.toLowerCase()} goal ${goalMetDays}/7 days, averaging ${Math.round(avg)} ${domainInfo.unit}. Time to level up!`,
            confidence: Math.min(0.95, 0.6 + (goalMetDays / 7) * 0.3),
            evidence: {
              daysAnalyzed: values.length,
              daysGoalMet: goalMetDays,
              average: Math.round(avg),
              ratioToGoal: Math.round(ratioToGoal * 100) / 100,
            },
          });
          suggestions.push(suggestion);
        }
        // Check for decrease suggestion
        else if (goalMetDays <= 1 && ratioToGoal < 0.6) {
          const decrease = Math.min(0.2, 1 - ratioToGoal); // Max 20% decrease
          const suggestedGoal = Math.round(currentGoal * (1 - decrease));

          const suggestion = await goalSuggestionModel.create(userId, {
            domain: domainInfo.domain,
            currentGoal,
            suggestedGoal,
            direction: 'decrease',
            reason: `Your ${domainInfo.label.toLowerCase()} goal seems too ambitious right now. You're averaging ${Math.round(avg)} ${domainInfo.unit} (goal: ${currentGoal}). A more achievable goal can help build momentum.`,
            confidence: Math.min(0.85, 0.5 + (1 - ratioToGoal) * 0.3),
            evidence: {
              daysAnalyzed: values.length,
              daysGoalMet: goalMetDays,
              average: Math.round(avg),
              ratioToGoal: Math.round(ratioToGoal * 100) / 100,
            },
          });
          suggestions.push(suggestion);
        }

        if (suggestions.length + pending.length >= 3) break; // Max 3 total
      } catch (err) {
        logger.debug({ err, domain: domainInfo.domain }, 'Goal review failed for domain');
      }
    }

    logger.debug({ userId, suggestions: suggestions.length }, 'Goal review complete');
    return suggestions;
  },
};
