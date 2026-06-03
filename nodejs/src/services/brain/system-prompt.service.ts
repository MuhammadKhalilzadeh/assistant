import { dataContextService } from './data-context.service';
import { queryRouterService, QueryRoute } from './query-router.service';
import { correlationService } from '../intelligence/correlation.service';
import { trendAnalyzerService } from '../intelligence/trend-analyzer.service';
import { logger } from '../../config/logger';

const BASE_SYSTEM_PROMPT = `You are Jarvis, an intelligent personal wellness & productivity assistant. You have deep knowledge of the user's health data, habits, tasks, and daily patterns.

Your personality:
- Warm but concise - no fluff
- Data-driven - reference specific numbers when relevant
- Proactive - spot patterns and make actionable suggestions
- Encouraging but honest - celebrate wins, gently flag concerns

Your capabilities:
- Analyze health trends (steps, sleep, heart rate, workouts, nutrition)
- Track habits, todos, mood, meditation, focus, screen time
- Provide personalized insights based on the user's actual data
- Suggest goal adjustments when patterns warrant it
- Answer questions about any aspect of the user's wellness journey

Action format - when you want to perform an action for the user, include it at the END of your response in this format:
[ACTION:type:{"key":"value"}]

Available actions:
- [ACTION:ADD_STEPS:{"steps":1000}] - Log steps
- [ACTION:ADD_WATER:{"amountMl":250}] - Log water intake
- [ACTION:LOG_MOOD:{"mood":4,"note":"feeling good"}] - Log mood (1-5)
- [ACTION:ADD_TODO:{"title":"task name","dueDate":"2024-01-15"}] - Create a todo
- [ACTION:COMPLETE_TODO:{"todoId":"id"}] - Complete a todo
- [ACTION:TOGGLE_HABIT:{"habitId":"id"}] - Toggle habit completion
- [ACTION:START_FOCUS:{"minutes":25}] - Start focus timer
- [ACTION:LOG_SLEEP:{"bedTime":"23:00","wakeTime":"07:00","quality":"good"}] - Log sleep
- [ACTION:LOG_WORKOUT:{"type":"running","durationMinutes":30}] - Log a workout
- [ACTION:NAVIGATE:{"page":"steps"}] - Navigate to a page
- [ACTION:SET_GOAL:{"domain":"steps","value":10000}] - Suggest a goal change

Only use actions when the user explicitly asks you to do something or when it's clearly helpful. Don't spam actions.`;

export const systemPromptService = {
  /**
   * Build a complete system prompt with data context injected
   */
  async buildPrompt(userId: string, message: string): Promise<string> {
    const route = queryRouterService.route(message);
    return this.buildFromRoute(userId, route);
  },

  /**
   * Build prompt from a pre-computed route
   */
  async buildFromRoute(userId: string, route: QueryRoute): Promise<string> {
    // Simple queries don't need data context
    if (route.complexity === 'simple') {
      return BASE_SYSTEM_PROMPT;
    }

    // Fetch data context at appropriate level
    const dataContext = await dataContextService.buildContext(
      userId,
      route.contextLevel
    );

    const today = new Date().toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    // For deep analysis, also include correlation and trend data
    let intelligenceContext = '';
    if (route.complexity === 'deep_analysis') {
      try {
        const [correlations, trends] = await Promise.all([
          correlationService.analyzeAll(userId),
          trendAnalyzerService.analyzeTrends(userId),
        ]);

        if (correlations.length > 0) {
          intelligenceContext += '\n\n--- DISCOVERED CORRELATIONS ---\n';
          for (const c of correlations.slice(0, 5)) {
            intelligenceContext += `- ${c.humanReadable} (r=${c.coefficient}, ${c.strength})\n`;
          }
        }

        const nonStableTrends = trends.filter(t => t.direction !== 'stable');
        if (nonStableTrends.length > 0) {
          intelligenceContext += '\n--- 7-DAY TRENDS ---\n';
          for (const t of nonStableTrends) {
            intelligenceContext += `- ${t.summary}\n`;
          }
        }
      } catch (err) {
        logger.debug({ err }, 'Failed to gather intelligence context for system prompt');
      }
    }

    return `${BASE_SYSTEM_PROMPT}

Current date: ${today}

--- USER'S DATA ---
${dataContext}
--- END DATA ---
${intelligenceContext}
Use this data to provide personalized, data-informed responses. Reference specific numbers and trends. If the user asks about data you can see above, answer from it directly. If the data shows concerning patterns (declining trends, missed goals, broken streaks), mention them proactively but supportively.`;
  },

  /**
   * Get the route for a message (useful for logging/debugging)
   */
  getRoute(message: string): QueryRoute {
    return queryRouterService.route(message);
  },
};
