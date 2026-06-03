import { stepsModel } from '../../models/steps.model';
import { sleepModel } from '../../models/sleep.model';
import { heartRateModel } from '../../models/heart_rate.model';
import { workoutModel } from '../../models/workout.model';
import { caloriesModel } from '../../models/calories.model';
import { waterModel } from '../../models/water.model';
import { moodModel } from '../../models/mood.model';
import { habitModel } from '../../models/habit.model';
import { todoModel } from '../../models/todo.model';
import { meditationModel } from '../../models/meditation.model';
import { focusTimerModel } from '../../models/focus-timer.model';
import { screenTimeModel } from '../../models/screen-time.model';
import { weatherModel } from '../../models/weather.model';
import { logger } from '../../config/logger';

export interface UserDataContext {
  summary: string;    // ~500 tokens - compact overview for simple queries
  detailed: string;   // ~1500 tokens - domain-specific detail for data-aware queries
  full: string;       // ~3000 tokens - everything for deep analysis queries
}

interface DomainData {
  steps: { stats: any; today: any } | null;
  sleep: { stats: any; lastNight: any } | null;
  heartRate: { stats: any } | null;
  workout: { stats: any; todaySessions: any[] } | null;
  calories: { stats: any; todayEntries: any[] } | null;
  water: { stats: any } | null;
  mood: { stats: any; todayEntries: any[] } | null;
  habits: { stats: any; habits: any[] } | null;
  todos: { stats: any; all: any[] } | null;
  meditation: { stats: any } | null;
  focusTimer: { stats: any } | null;
  screenTime: { stats: any } | null;
  weather: { current: any } | null;
}

async function fetchSafe<T>(fn: () => Promise<T>): Promise<T | null> {
  try {
    return await fn();
  } catch (err) {
    logger.debug({ err }, 'Data context fetch failed for domain');
    return null;
  }
}

export const dataContextService = {
  /**
   * Fetch all domain data for a user in parallel
   */
  async fetchAll(userId: string): Promise<DomainData> {
    const today = new Date().toISOString().split('T')[0];

    const [
      stepsStats, stepsToday,
      sleepStats, sleepToday,
      hrStats,
      workoutStats, workoutToday,
      calStats, calToday,
      waterStats,
      moodStats, moodToday,
      habitStats, habits,
      todoStats, todos,
      medStats,
      focusStats,
      screenStats,
      weather,
    ] = await Promise.all([
      fetchSafe(() => stepsModel.getStats(userId)),
      fetchSafe(() => stepsModel.getRecordForDate(userId, today)),
      fetchSafe(() => sleepModel.getStats(userId)),
      fetchSafe(() => sleepModel.getRecordsForDate(userId, today)),
      fetchSafe(() => heartRateModel.getStats(userId)),
      fetchSafe(() => workoutModel.getStats(userId)),
      fetchSafe(() => workoutModel.getSessionsForDate(userId, today)),
      fetchSafe(() => caloriesModel.getStats(userId)),
      fetchSafe(() => caloriesModel.getEntriesForDate(userId, today)),
      fetchSafe(() => waterModel.getStats(userId)),
      fetchSafe(() => moodModel.getStats(userId)),
      fetchSafe(() => moodModel.getEntriesForDate(userId, today)),
      fetchSafe(() => habitModel.getStats(userId)),
      fetchSafe(() => habitModel.findAll(userId)),
      fetchSafe(() => todoModel.getStats(userId)),
      fetchSafe(() => todoModel.findAll(userId)),
      fetchSafe(() => meditationModel.getStats(userId)),
      fetchSafe(() => focusTimerModel.getStats(userId)),
      fetchSafe(() => screenTimeModel.getStats(userId)),
      fetchSafe(async () => {
        const settings = await weatherModel.getSettings(userId);
        return weatherModel.fetchWeather(userId, settings.latitude, settings.longitude, settings.temperatureUnit);
      }),
    ]);

    return {
      steps: stepsStats ? { stats: stepsStats, today: stepsToday } : null,
      sleep: sleepStats ? { stats: sleepStats, lastNight: sleepToday } : null,
      heartRate: hrStats ? { stats: hrStats } : null,
      workout: workoutStats ? { stats: workoutStats, todaySessions: workoutToday || [] } : null,
      calories: calStats ? { stats: calStats, todayEntries: calToday || [] } : null,
      water: waterStats ? { stats: waterStats } : null,
      mood: moodStats ? { stats: moodStats, todayEntries: moodToday || [] } : null,
      habits: habitStats ? { stats: habitStats, habits: habits || [] } : null,
      todos: todoStats ? { stats: todoStats, all: todos || [] } : null,
      meditation: medStats ? { stats: medStats } : null,
      focusTimer: focusStats ? { stats: focusStats } : null,
      screenTime: screenStats ? { stats: screenStats } : null,
      weather: weather ? { current: weather } : null,
    };
  },

  /**
   * Build a compact summary (~500 tokens) for quick context
   */
  buildSummary(data: DomainData): string {
    const lines: string[] = ['## Today\'s Quick Summary'];
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });
    lines.push(`Date: ${today}`);

    if (data.steps?.stats) {
      const s = data.steps.stats;
      lines.push(`Steps: ${s.todaySteps}/${s.dailyGoal} (${Math.round((s.todaySteps / s.dailyGoal) * 100)}%) | Streak: ${s.currentStreak}d`);
    }
    if (data.sleep?.stats) {
      const s = data.sleep.stats;
      lines.push(`Sleep: ${s.weeklyAverageHours?.toFixed(1)}h avg | Streak: ${s.currentStreak}d`);
    }
    if (data.heartRate?.stats) {
      const s = data.heartRate.stats;
      lines.push(`Heart Rate: ${s.averageRestingBpm} bpm resting`);
    }
    if (data.water?.stats) {
      const s = data.water.stats;
      lines.push(`Water: ${s.todayIntakeMl}/${s.dailyGoalMl}ml (${Math.round((s.todayIntakeMl / s.dailyGoalMl) * 100)}%)`);
    }
    if (data.mood?.stats) {
      const s = data.mood.stats;
      lines.push(`Mood: ${s.weeklyAverageMood?.toFixed(1)}/5 avg | ${s.totalEntries} entries`);
    }
    if (data.workout?.stats) {
      const s = data.workout.stats;
      lines.push(`Workouts: ${s.weeklySessions} this week (${s.weeklyMinutes}min) | Streak: ${s.currentStreak}d`);
    }
    if (data.habits?.stats) {
      const s = data.habits.stats;
      lines.push(`Habits: ${s.completedToday}/${s.totalForToday} today | ${Math.round(s.weeklyCompletionRate * 100)}% weekly`);
    }
    if (data.todos?.stats) {
      const s = data.todos.stats;
      lines.push(`Todos: ${s.completed}/${s.total} done | ${s.overdueCount} overdue`);
    }
    if (data.weather?.current) {
      const w = data.weather.current;
      lines.push(`Weather: ${w.currentCondition || 'N/A'}, ${w.currentTemperature ?? 'N/A'}° | High: ${w.high ?? 'N/A'}° Low: ${w.low ?? 'N/A'}°`);
    }

    return lines.join('\n');
  },

  /**
   * Build detailed context (~1500 tokens) with trends and patterns
   */
  buildDetailed(data: DomainData): string {
    const sections: string[] = [this.buildSummary(data)];

    sections.push('\n## Detailed Stats & Trends');

    if (data.steps?.stats) {
      const s = data.steps.stats;
      sections.push(`\n### Steps`);
      sections.push(`- Today: ${s.todaySteps} steps (${s.todaySteps >= s.dailyGoal ? 'GOAL MET' : `${s.dailyGoal - s.todaySteps} remaining`})`);
      sections.push(`- 7-day avg: ${s.weeklyAverageSteps} steps`);
      sections.push(`- Streaks: ${s.currentStreak}d current, ${s.bestStreak}d best`);
      sections.push(`- 30-day goal hit rate: ${Math.round(s.goalCompletionRate * 100)}%`);
      sections.push(`- Distance: ${s.totalDistanceKm}km | Calories: ${s.totalCaloriesBurned} kcal`);
    }

    if (data.sleep?.stats) {
      const s = data.sleep.stats;
      sections.push(`\n### Sleep`);
      sections.push(`- Weekly avg: ${s.weeklyAverageHours?.toFixed(1)}h`);
      sections.push(`- Quality: ${Object.entries(s.qualityDistribution || {}).map(([k, v]) => `${k}: ${v}`).join(', ')}`);
      sections.push(`- Avg bedtime: ${s.averageBedTime || 'N/A'} | Avg wake: ${s.averageWakeTime || 'N/A'}`);
      sections.push(`- Streaks: ${s.currentStreak}d current, ${s.bestStreak}d best`);
    }

    if (data.heartRate?.stats) {
      const s = data.heartRate.stats;
      sections.push(`\n### Heart Rate`);
      sections.push(`- Resting avg: ${s.averageRestingBpm} bpm | Active avg: ${s.averageActiveBpm} bpm`);
      sections.push(`- Range: ${s.minBpm}-${s.maxBpm} bpm`);
      sections.push(`- Zone distribution: ${Object.entries(s.zoneDistribution || {}).map(([k, v]) => `${k}: ${v}`).join(', ')}`);
    }

    if (data.workout?.stats) {
      const s = data.workout.stats;
      sections.push(`\n### Workouts`);
      sections.push(`- This week: ${s.weeklySessions} sessions, ${s.weeklyMinutes}min, ${s.weeklyCalories} kcal`);
      sections.push(`- Streaks: ${s.currentStreak}d current, ${s.bestStreak}d best`);
      sections.push(`- Types: ${Object.entries(s.workoutsByType || {}).map(([k, v]) => `${k}: ${v}`).join(', ')}`);
      if (data.workout.todaySessions.length > 0) {
        sections.push(`- Today: ${data.workout.todaySessions.map((w: any) => `${w.type} (${w.durationMinutes}min)`).join(', ')}`);
      }
    }

    if (data.calories?.stats) {
      const s = data.calories.stats;
      sections.push(`\n### Nutrition`);
      sections.push(`- Today: ${s.todayCalories || 0}/${s.dailyGoal || 'N/A'} kcal`);
      sections.push(`- Weekly avg: ${s.weeklyAverageCalories || 0} kcal`);
      if (data.calories.todayEntries.length > 0) {
        sections.push(`- Meals logged today: ${data.calories.todayEntries.length}`);
      }
    }

    if (data.mood?.stats) {
      const s = data.mood.stats;
      sections.push(`\n### Mood`);
      sections.push(`- Weekly avg: ${s.weeklyAverageMood?.toFixed(1)}/5`);
      sections.push(`- Distribution: ${Object.entries(s.moodDistribution || {}).map(([k, v]) => `${k}: ${v}`).join(', ')}`);
      if (data.mood.todayEntries.length > 0) {
        sections.push(`- Today's mood: ${data.mood.todayEntries.map((e: any) => `${e.mood}/5`).join(', ')}`);
      }
    }

    if (data.meditation?.stats) {
      const s = data.meditation.stats;
      sections.push(`\n### Meditation`);
      sections.push(`- Weekly sessions: ${s.weeklySessions || 0} | Weekly minutes: ${s.weeklyMinutes || 0}`);
      sections.push(`- Streaks: ${s.currentStreak || 0}d current, ${s.bestStreak || 0}d best`);
    }

    if (data.focusTimer?.stats) {
      const s = data.focusTimer.stats;
      sections.push(`\n### Focus`);
      sections.push(`- Weekly sessions: ${s.weeklySessions || 0} | Weekly minutes: ${s.weeklyMinutes || 0}`);
    }

    if (data.screenTime?.stats) {
      const s = data.screenTime.stats;
      sections.push(`\n### Screen Time`);
      sections.push(`- Today: ${s.todayMinutes || 0}min | Daily avg: ${s.weeklyAverageMinutes || 0}min`);
    }

    if (data.todos?.all) {
      const overdue = data.todos.all.filter((t: any) => !t.completed && t.dueDate && new Date(t.dueDate) < new Date());
      const todayDue = data.todos.all.filter((t: any) => {
        if (t.completed || !t.dueDate) return false;
        const due = new Date(t.dueDate).toISOString().split('T')[0];
        const todayStr = new Date().toISOString().split('T')[0];
        return due === todayStr;
      });
      if (overdue.length > 0 || todayDue.length > 0) {
        sections.push(`\n### Tasks`);
        if (overdue.length > 0) {
          sections.push(`- OVERDUE: ${overdue.slice(0, 5).map((t: any) => t.title).join(', ')}${overdue.length > 5 ? ` +${overdue.length - 5} more` : ''}`);
        }
        if (todayDue.length > 0) {
          sections.push(`- Due today: ${todayDue.slice(0, 5).map((t: any) => t.title).join(', ')}`);
        }
      }
    }

    return sections.join('\n');
  },

  /**
   * Build full context (~3000 tokens) with habits detail, all todos, goals
   */
  buildFull(data: DomainData): string {
    const sections: string[] = [this.buildDetailed(data)];

    sections.push('\n## Complete Data');

    if (data.habits?.habits && data.habits.habits.length > 0) {
      sections.push(`\n### All Habits`);
      for (const h of data.habits.habits) {
        sections.push(`- ${h.name}: ${h.completedToday ? 'DONE' : 'pending'} | Streak: ${h.currentStreak || 0}d | Best: ${h.bestStreak || 0}d`);
      }
    }

    if (data.todos?.all && data.todos.all.length > 0) {
      sections.push(`\n### All Todos`);
      const pending = data.todos.all.filter((t: any) => !t.completed);
      const completed = data.todos.all.filter((t: any) => t.completed);
      if (pending.length > 0) {
        sections.push('Pending:');
        for (const t of pending.slice(0, 15)) {
          const due = t.dueDate ? ` (due: ${new Date(t.dueDate).toISOString().split('T')[0]})` : '';
          const priority = t.priority ? ` [${t.priority}]` : '';
          sections.push(`- [ ] ${t.title}${priority}${due}`);
        }
        if (pending.length > 15) sections.push(`  ... +${pending.length - 15} more`);
      }
      if (completed.length > 0) {
        sections.push(`Completed recently: ${completed.slice(0, 5).map((t: any) => t.title).join(', ')}`);
      }
    }

    if (data.water?.stats) {
      const s = data.water.stats;
      sections.push(`\n### Water Details`);
      sections.push(`- Goal: ${s.dailyGoalMl}ml | Today: ${s.todayIntakeMl}ml`);
      sections.push(`- 7-day avg: ${s.weeklyAverageMl}ml`);
      sections.push(`- Goal hit rate: ${Math.round(s.goalCompletionRate * 100)}%`);
      sections.push(`- Streaks: ${s.currentStreak}d current, ${s.bestStreak}d best`);
    }

    return sections.join('\n');
  },

  /**
   * Build context at the appropriate detail level
   */
  async buildContext(userId: string, level: 'summary' | 'detailed' | 'full' = 'detailed'): Promise<string> {
    const data = await this.fetchAll(userId);

    switch (level) {
      case 'summary':
        return this.buildSummary(data);
      case 'detailed':
        return this.buildDetailed(data);
      case 'full':
        return this.buildFull(data);
    }
  },

  /**
   * Build context for specific domains only
   */
  async buildDomainContext(userId: string, domains: string[]): Promise<string> {
    const data = await this.fetchAll(userId);
    const sections: string[] = [];

    for (const domain of domains) {
      const domainData = data[domain as keyof DomainData];
      if (!domainData) continue;

      switch (domain) {
        case 'steps':
          if (data.steps?.stats) {
            const s = data.steps.stats;
            sections.push(`Steps: ${s.todaySteps}/${s.dailyGoal} | Avg: ${s.weeklyAverageSteps} | Streak: ${s.currentStreak}d | Rate: ${Math.round(s.goalCompletionRate * 100)}%`);
          }
          break;
        case 'sleep':
          if (data.sleep?.stats) {
            const s = data.sleep.stats;
            sections.push(`Sleep: ${s.weeklyAverageHours?.toFixed(1)}h avg | Bed: ${s.averageBedTime} | Wake: ${s.averageWakeTime} | Streak: ${s.currentStreak}d`);
          }
          break;
        case 'heartRate':
          if (data.heartRate?.stats) {
            const s = data.heartRate.stats;
            sections.push(`HR: ${s.averageRestingBpm}bpm resting | Range: ${s.minBpm}-${s.maxBpm}`);
          }
          break;
        case 'workout':
          if (data.workout?.stats) {
            const s = data.workout.stats;
            sections.push(`Workouts: ${s.weeklySessions}/wk, ${s.weeklyMinutes}min, ${s.weeklyCalories}kcal | Streak: ${s.currentStreak}d`);
          }
          break;
        case 'water':
          if (data.water?.stats) {
            const s = data.water.stats;
            sections.push(`Water: ${s.todayIntakeMl}/${s.dailyGoalMl}ml | Avg: ${s.weeklyAverageMl}ml | Streak: ${s.currentStreak}d`);
          }
          break;
        case 'mood':
          if (data.mood?.stats) {
            const s = data.mood.stats;
            sections.push(`Mood: ${s.weeklyAverageMood?.toFixed(1)}/5 avg | Entries: ${s.totalEntries}`);
          }
          break;
        default:
          sections.push(`${domain}: data available`);
      }
    }

    return sections.join('\n');
  },
};
