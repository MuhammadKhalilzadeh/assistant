import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/providers/water_provider.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/habit_provider.dart';
import 'package:assistant/providers/mood_provider.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/sleep_provider.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/providers/workout_provider.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/providers/focus_timer_provider.dart';
import 'package:assistant/providers/screen_time_provider.dart';
import 'package:assistant/providers/calendar_provider.dart';

/// A nudge is a context-aware in-app reminder shown on app open.
class Nudge {
  final String id;
  final String icon;
  final String message;
  final String? actionLabel;
  final int priority; // lower = more urgent

  const Nudge({
    required this.id,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.priority = 5,
  });
}

/// A cross-domain insight derived from data patterns.
class SmartInsight {
  final String id;
  final String title;
  final String description;
  final String icon;
  final double delta; // percentage or value difference
  final String trend; // 'up', 'down', 'same'

  const SmartInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.delta,
    required this.trend,
  });
}

/// Weekly metric for the report card.
class WeeklyMetric {
  final String label;
  final String icon;
  final double value;
  final double goal;
  final String unit;
  final int streak;

  const WeeklyMetric({
    required this.label,
    required this.icon,
    required this.value,
    required this.goal,
    required this.unit,
    required this.streak,
  });

  double get progress => goal > 0 ? (value / goal).clamp(0.0, 2.0) : 0;
  bool get goalMet => value >= goal;
}

/// Weekly report card containing all metrics.
class WeeklyReport {
  final List<WeeklyMetric> metrics;
  final List<String> highlights;
  final List<String> needsAttention;
  final DateTime generatedAt;

  const WeeklyReport({
    required this.metrics,
    required this.highlights,
    required this.needsAttention,
    required this.generatedAt,
  });
}

/// Core intelligence engine for weekly reports, nudges, and insights.
/// All computation is pure Dart — no LLM calls, no heavy packages.
class JarvisInsightsService {
  final Ref _ref;

  JarvisInsightsService(this._ref);

  // ─── Weekly Report ──────────────────────────────────────────────────

  Future<WeeklyReport> generateWeeklyReport() async {
    final metrics = <WeeklyMetric>[];
    final highlights = <String>[];
    final needsAttention = <String>[];

    // Water
    try {
      final s = await _ref.read(waterStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Water',
        icon: 'water_drop',
        value: s.weeklyAverageMl.toDouble(),
        goal: s.dailyGoalMl.toDouble(),
        unit: 'ml/day',
        streak: s.currentStreak,
      ));
      if (s.goalCompletionRate >= 0.8) {
        highlights.add('Water: ${(s.goalCompletionRate * 100).round()}% goal rate');
      } else if (s.goalCompletionRate < 0.5 && s.goalCompletionRate > 0) {
        needsAttention.add('Water: ${(s.goalCompletionRate * 100).round()}% goal rate');
      }
    } catch (e) {
      debugPrint('[Insights] Water unavailable: $e');
    }

    // Steps
    try {
      final s = await _ref.read(stepsStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Steps',
        icon: 'directions_walk',
        value: s.weeklyAverageSteps.toDouble(),
        goal: s.dailyGoal.toDouble(),
        unit: 'steps/day',
        streak: s.currentStreak,
      ));
      if (s.goalCompletionRate >= 0.8) {
        highlights.add('Steps: ${(s.goalCompletionRate * 100).round()}% goal rate');
      } else if (s.goalCompletionRate < 0.5 && s.goalCompletionRate > 0) {
        needsAttention.add('Steps: only ${(s.goalCompletionRate * 100).round()}% goal rate');
      }
    } catch (e) {
      debugPrint('[Insights] Steps unavailable: $e');
    }

    // Sleep
    try {
      final s = await _ref.read(sleepStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Sleep',
        icon: 'bedtime',
        value: s.weeklyAverageHours,
        goal: 8.0,
        unit: 'hrs/night',
        streak: s.currentStreak,
      ));
      if (s.weeklyAverageHours >= 7.5) {
        highlights.add('Sleep: ${s.weeklyAverageHours.toStringAsFixed(1)}h avg');
      } else if (s.weeklyAverageHours > 0 && s.weeklyAverageHours < 6.5) {
        needsAttention.add('Sleep: only ${s.weeklyAverageHours.toStringAsFixed(1)}h avg');
      }
    } catch (e) {
      debugPrint('[Insights] Sleep unavailable: $e');
    }

    // Mood
    try {
      final s = await _ref.read(moodStatsProvider.future);
      if (s.totalEntries > 0) {
        metrics.add(WeeklyMetric(
          label: 'Mood',
          icon: 'emoji_emotions',
          value: s.weeklyAverageMood,
          goal: 5.0,
          unit: '/5',
          streak: s.currentStreak,
        ));
        if (s.weeklyAverageMood >= 4.0) {
          highlights.add('Mood: ${s.weeklyAverageMood.toStringAsFixed(1)}/5 avg');
        } else if (s.weeklyAverageMood < 2.5 && s.weeklyAverageMood > 0) {
          needsAttention.add('Mood: ${s.weeklyAverageMood.toStringAsFixed(1)}/5 avg');
        }
      }
    } catch (e) {
      debugPrint('[Insights] Mood unavailable: $e');
    }

    // Calories
    try {
      final s = await _ref.read(nutritionStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Calories',
        icon: 'restaurant',
        value: s.weeklyAverageCalories.toDouble(),
        goal: s.dailyCalorieGoal.toDouble(),
        unit: 'kcal/day',
        streak: s.currentStreak,
      ));
    } catch (e) {
      debugPrint('[Insights] Calories unavailable: $e');
    }

    // Workout
    try {
      final s = await _ref.read(workoutStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Workout',
        icon: 'fitness_center',
        value: s.weeklyMinutes.toDouble(),
        goal: 150.0,
        unit: 'min/week',
        streak: s.currentStreak,
      ));
      if (s.weeklyMinutes >= 150) {
        highlights.add('Workout: ${s.weeklyMinutes}min this week');
      }
    } catch (e) {
      debugPrint('[Insights] Workout unavailable: $e');
    }

    // Focus
    try {
      final s = await _ref.read(focusTimerStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Focus',
        icon: 'timer',
        value: s.weeklyMinutes.toDouble(),
        goal: 300.0, // 5 hours/week goal
        unit: 'min/week',
        streak: s.currentStreak,
      ));
    } catch (e) {
      debugPrint('[Insights] Focus unavailable: $e');
    }

    // Meditation
    try {
      final s = await _ref.read(meditationStatsProvider.future);
      metrics.add(WeeklyMetric(
        label: 'Meditation',
        icon: 'self_improvement',
        value: s.weeklyMinutes.toDouble(),
        goal: 70.0, // 10 min/day goal
        unit: 'min/week',
        streak: s.currentStreak,
      ));
      if (s.currentStreak >= 7) {
        highlights.add('Meditation: ${s.currentStreak}-day streak!');
      }
    } catch (e) {
      debugPrint('[Insights] Meditation unavailable: $e');
    }

    // Streak highlights
    for (final m in metrics) {
      if (m.streak >= 10) {
        highlights.add('${m.label}: ${m.streak}-day streak!');
      }
    }

    return WeeklyReport(
      metrics: metrics,
      highlights: highlights.toSet().toList(), // deduplicate
      needsAttention: needsAttention,
      generatedAt: DateTime.now(),
    );
  }

  // ─── Proactive Nudges ───────────────────────────────────────────────

  Future<List<Nudge>> computeNudges() async {
    final nudges = <Nudge>[];

    // 1. Streak at risk — water
    try {
      final s = await _ref.read(waterStatsProvider.future);
      if (s.currentStreak > 2 && !s.goalMet) {
        nudges.add(Nudge(
          id: 'streak_water',
          icon: 'water_drop',
          message: 'Your ${s.currentStreak}-day water streak is about to break! Log some water.',
          actionLabel: 'Log Water',
          priority: 1,
        ));
      }
    } catch (_) {}

    // 2. Unlogged mood — check if streak is 0 but had previous entries
    try {
      final s = await _ref.read(moodStatsProvider.future);
      if (s.totalEntries > 0 && s.currentStreak == 0) {
        nudges.add(Nudge(
          id: 'unlogged_mood',
          icon: 'emoji_emotions',
          message: "You haven't logged your mood recently. How are you feeling?",
          actionLabel: 'Log Mood',
          priority: 3,
        ));
      }
    } catch (_) {}

    // 3. Step goal progress
    try {
      final s = await _ref.read(stepsStatsProvider.future);
      if (s.dailyGoal > 0 && s.todaySteps > 0) {
        final pct = s.todaySteps / s.dailyGoal;
        if (pct >= 0.7 && pct < 1.0) {
          final remaining = s.dailyGoal - s.todaySteps;
          nudges.add(Nudge(
            id: 'step_goal',
            icon: 'directions_walk',
            message: "You're at ${(pct * 100).round()}% of your step goal — just $remaining more!",
            priority: 4,
          ));
        }
      }
    } catch (_) {}

    // 4. Low sleep
    try {
      final s = await _ref.read(sleepStatsProvider.future);
      if (s.weeklyAverageHours > 0 && s.weeklyAverageHours < 6.5) {
        nudges.add(Nudge(
          id: 'sleep_low',
          icon: 'bedtime',
          message: 'Your sleep average is ${s.weeklyAverageHours.toStringAsFixed(1)}h — try going to bed earlier.',
          priority: 2,
        ));
      }
    } catch (_) {}

    // 5. Celebration — meditation streak
    try {
      final s = await _ref.read(meditationStatsProvider.future);
      if (s.currentStreak > 0 && s.currentStreak % 5 == 0) {
        nudges.add(Nudge(
          id: 'celebrate_meditation',
          icon: 'celebration',
          message: 'Amazing! ${s.currentStreak}-day meditation streak!',
          priority: 6,
        ));
      }
    } catch (_) {}

    // 6. Overdue todos
    try {
      final s = await _ref.read(todoStatsProvider.future);
      if (s.overdueCount > 0) {
        nudges.add(Nudge(
          id: 'overdue_todos',
          icon: 'checklist',
          message: 'You have ${s.overdueCount} overdue todo${s.overdueCount > 1 ? 's' : ''}. Want to review them?',
          actionLabel: 'Review',
          priority: 2,
        ));
      }
    } catch (_) {}

    // 7. Calendar reminder
    try {
      final s = await _ref.read(calendarStatsProvider.future);
      if (s.nextEventTitle != null && s.nextEventTime != null) {
        final diff = s.nextEventTime!.difference(DateTime.now());
        if (diff.inMinutes > 0 && diff.inMinutes <= 30) {
          nudges.add(Nudge(
            id: 'calendar_soon',
            icon: 'event',
            message: 'You have "${s.nextEventTitle}" in ${diff.inMinutes} minutes.',
            priority: 1,
          ));
        }
      }
    } catch (_) {}

    // Sort by priority and return max 2
    nudges.sort((a, b) => a.priority.compareTo(b.priority));
    return nudges.take(2).toList();
  }

  // ─── Smart Insights ─────────────────────────────────────────────────

  /// Compute insights from available stats data.
  /// Uses goal completion rates, streaks, and cross-domain comparisons.
  Future<List<SmartInsight>> computeInsights() async {
    final insights = <SmartInsight>[];

    // 1. Sleep quality insight — compare avg hours to goal
    try {
      final s = await _ref.read(sleepStatsProvider.future);
      if (s.weeklyAverageHours > 0) {
        final goalHours = 8.0;
        final pct = ((s.weeklyAverageHours - goalHours) / goalHours * 100);
        if (pct.abs() > 10) {
          insights.add(SmartInsight(
            id: 'sleep_quality',
            title: 'Sleep Quality',
            description: pct > 0
                ? 'You\'re sleeping ${pct.round()}% above your 8h target — well rested!'
                : 'You\'re ${pct.abs().round()}% below the 8h target — prioritize rest',
            icon: 'bedtime',
            delta: pct.abs(),
            trend: pct > 0 ? 'up' : 'down',
          ));
        }
      }
    } catch (_) {}

    // 2. Hydration consistency
    try {
      final s = await _ref.read(waterStatsProvider.future);
      if (s.weeklyAverageMl > 0 && s.dailyGoalMl > 0) {
        final pct = (s.weeklyAverageMl / s.dailyGoalMl * 100);
        if (pct >= 90) {
          insights.add(SmartInsight(
            id: 'hydration_strong',
            title: 'Hydration',
            description: 'Averaging ${pct.round()}% of your water goal — great consistency!',
            icon: 'water_drop',
            delta: pct - 100,
            trend: 'up',
          ));
        } else if (pct < 60 && pct > 0) {
          insights.add(SmartInsight(
            id: 'hydration_low',
            title: 'Hydration',
            description: 'Only hitting ${pct.round()}% of your water goal on average',
            icon: 'water_drop',
            delta: 100 - pct,
            trend: 'down',
          ));
        }
      }
    } catch (_) {}

    // 3. Step consistency
    try {
      final s = await _ref.read(stepsStatsProvider.future);
      if (s.weeklyAverageSteps > 0 && s.dailyGoal > 0) {
        final pct = (s.weeklyAverageSteps / s.dailyGoal * 100);
        if (pct >= 90) {
          insights.add(SmartInsight(
            id: 'steps_strong',
            title: 'Steps',
            description: 'Averaging ${s.weeklyAverageSteps} steps/day — ${pct.round()}% of goal',
            icon: 'directions_walk',
            delta: pct - 100,
            trend: 'up',
          ));
        }
      }
    } catch (_) {}

    // 4. Workout volume
    try {
      final s = await _ref.read(workoutStatsProvider.future);
      if (s.weeklyMinutes > 0) {
        final target = 150; // WHO recommendation
        final pct = (s.weeklyMinutes / target * 100);
        insights.add(SmartInsight(
          id: 'workout_volume',
          title: 'Exercise',
          description: pct >= 100
              ? '${s.weeklyMinutes}min this week — exceeding the 150min target!'
              : '${s.weeklyMinutes}/${target}min weekly target (${pct.round()}%)',
          icon: 'fitness_center',
          delta: (pct - 100).abs(),
          trend: pct >= 100 ? 'up' : 'down',
        ));
      }
    } catch (_) {}

    // 5. Focus productivity
    try {
      final focus = await _ref.read(focusTimerStatsProvider.future);
      if (focus.weeklySessions > 0 && focus.weeklyMinutes > 0) {
        final avgPerSession = focus.weeklyMinutes / focus.weeklySessions;
        if (avgPerSession >= 25) {
          insights.add(SmartInsight(
            id: 'focus_productive',
            title: 'Focus',
            description: '${avgPerSession.round()}min avg session across ${focus.weeklySessions} sessions this week',
            icon: 'timer',
            delta: avgPerSession,
            trend: 'up',
          ));
        }
      }
    } catch (_) {}

    // 6. Habit completion rate
    try {
      final s = await _ref.read(habitStatsProvider.future);
      if (s.totalHabits > 0) {
        final pct = s.weeklyCompletionRate * 100;
        if (pct >= 80) {
          insights.add(SmartInsight(
            id: 'habits_strong',
            title: 'Habits',
            description: '${pct.round()}% weekly completion rate — building strong routines!',
            icon: 'repeat',
            delta: pct,
            trend: 'up',
          ));
        } else if (pct < 40 && pct > 0) {
          insights.add(SmartInsight(
            id: 'habits_low',
            title: 'Habits',
            description: 'Only ${pct.round()}% habit completion this week — try starting small',
            icon: 'repeat',
            delta: 100 - pct,
            trend: 'down',
          ));
        }
      }
    } catch (_) {}

    // 7. Screen time awareness
    try {
      final s = await _ref.read(screenTimeStatsProvider.future);
      if (s.todayMinutes > 0 && s.dailyLimitMinutes > 0) {
        final pct = (s.todayMinutes / s.dailyLimitMinutes * 100);
        if (pct > 120) {
          insights.add(SmartInsight(
            id: 'screen_high',
            title: 'Screen Time',
            description: '${pct.round()}% over your daily limit — consider taking a break',
            icon: 'phone_android',
            delta: pct - 100,
            trend: 'down',
          ));
        }
      }
    } catch (_) {}

    return insights;
  }
}

/// Provider for the insights service
final jarvisInsightsServiceProvider = Provider<JarvisInsightsService>((ref) {
  return JarvisInsightsService(ref);
});
