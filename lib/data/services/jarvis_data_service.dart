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
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/providers/focus_timer_provider.dart';
import 'package:assistant/providers/screen_time_provider.dart';
import 'package:assistant/providers/calendar_provider.dart';
import 'package:assistant/providers/inbox_provider.dart';
import 'package:assistant/providers/weather_provider.dart';

/// Gathers data from all 15 app providers and builds context strings
/// for the Jarvis AI assistant. No new packages, no backend calls —
/// purely reads existing Riverpod providers.
class JarvisDataService {
  final Ref _ref;

  JarvisDataService(this._ref);

  /// Gather a full daily briefing snapshot from all available providers.
  /// Returns a structured text block with today's data.
  /// Each section is wrapped in try-catch so a single failing provider
  /// doesn't break the entire briefing.
  Future<String> gatherDailyBriefing() async {
    final sections = <String>[];

    // Weather (instant snapshot, most relevant for a morning briefing)
    try {
      final weather = _ref.read(weatherProvider);
      weather.whenData((w) {
        sections.add(
          'Weather: ${w.currentTemperature}°, ${w.currentCondition.name}, '
          'feels like ${w.feelsLike}°, high ${w.high}° / low ${w.low}°, '
          '${w.precipChance}% chance of rain.',
        );
      });
    } catch (e) {
      debugPrint('[JarvisData] Weather unavailable: $e');
    }

    // Sleep (last night)
    try {
      final sleepStats = await _ref.read(sleepStatsProvider.future);
      sections.add(
        'Sleep: avg ${sleepStats.weeklyAverageHours.toStringAsFixed(1)}h/night this week, '
        '${sleepStats.currentStreak}-day streak, '
        '${(sleepStats.goalCompletionRate * 100).round()}% goal completion.'
        '${sleepStats.averageBedTime != null ? ' Avg bedtime: ${sleepStats.averageBedTime}.' : ''}',
      );
    } catch (e) {
      debugPrint('[JarvisData] Sleep unavailable: $e');
    }

    // Calendar (today)
    try {
      final calStats = await _ref.read(calendarStatsProvider.future);
      final eventLine = calStats.todayEventsCount == 0
          ? 'Calendar: No events today.'
          : 'Calendar: ${calStats.todayEventsCount} event(s) today.'
              '${calStats.nextEventTitle != null ? ' Next: "${calStats.nextEventTitle}" at ${_formatTime(calStats.nextEventTime)}.' : ''}';
      sections.add(eventLine);
    } catch (e) {
      debugPrint('[JarvisData] Calendar unavailable: $e');
    }

    // Todos
    try {
      final todoStats = await _ref.read(todoStatsProvider.future);
      sections.add(
        'Todos: ${todoStats.todayCount} due today, ${todoStats.overdueCount} overdue, '
        '${todoStats.completed}/${todoStats.total} completed overall '
        '(${(todoStats.completionRate * 100).round()}%).',
      );
    } catch (e) {
      debugPrint('[JarvisData] Todos unavailable: $e');
    }

    // Habits
    try {
      final habitStats = await _ref.read(habitStatsProvider.future);
      sections.add(
        'Habits: ${habitStats.completedToday}/${habitStats.totalForToday} completed today, '
        'best streak: ${habitStats.maxBestStreak} days, '
        '${(habitStats.weeklyCompletionRate * 100).round()}% weekly rate.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Habits unavailable: $e');
    }

    // Water
    try {
      final waterStats = await _ref.read(waterStatsProvider.future);
      final pct = waterStats.dailyGoalMl > 0
          ? ((waterStats.todayIntakeMl / waterStats.dailyGoalMl) * 100).round()
          : 0;
      sections.add(
        'Water: ${waterStats.todayIntakeMl}ml / ${waterStats.dailyGoalMl}ml today ($pct%), '
        '${waterStats.currentStreak}-day streak.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Water unavailable: $e');
    }

    // Mood
    try {
      final moodStats = await _ref.read(moodStatsProvider.future);
      final avgLabel = _moodLabel(moodStats.weeklyAverageMood);
      sections.add(
        'Mood: Weekly average $avgLabel (${moodStats.weeklyAverageMood.toStringAsFixed(1)}/5), '
        '${moodStats.totalEntries} entries logged, ${moodStats.currentStreak}-day streak.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Mood unavailable: $e');
    }

    // Calories
    try {
      final nutritionStats = await _ref.read(nutritionStatsProvider.future);
      final pct = nutritionStats.dailyCalorieGoal > 0
          ? ((nutritionStats.todayCalories / nutritionStats.dailyCalorieGoal) * 100).round()
          : 0;
      sections.add(
        'Calories: ${nutritionStats.todayCalories} / ${nutritionStats.dailyCalorieGoal} kcal today ($pct%), '
        'P: ${nutritionStats.todayProtein}g, C: ${nutritionStats.todayCarbs}g, F: ${nutritionStats.todayFat}g.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Calories unavailable: $e');
    }

    // Steps
    try {
      final stepsStats = await _ref.read(stepsStatsProvider.future);
      final pct = stepsStats.dailyGoal > 0
          ? ((stepsStats.todaySteps / stepsStats.dailyGoal) * 100).round()
          : 0;
      sections.add(
        'Steps: ${stepsStats.todaySteps} / ${stepsStats.dailyGoal} today ($pct%), '
        '${stepsStats.currentStreak}-day streak.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Steps unavailable: $e');
    }

    // Workout
    try {
      final workoutStats = await _ref.read(workoutStatsProvider.future);
      sections.add(
        'Workout: ${workoutStats.weeklySessions} sessions this week, '
        '${workoutStats.weeklyMinutes} min, ${workoutStats.weeklyCalories} kcal burned.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Workout unavailable: $e');
    }

    // Focus Timer
    try {
      final focusStats = await _ref.read(focusTimerStatsProvider.future);
      sections.add(
        'Focus: ${focusStats.todaySessions} sessions today (${focusStats.todayMinutes} min), '
        '${focusStats.weeklySessions} this week, ${focusStats.currentStreak}-day streak.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Focus unavailable: $e');
    }

    // Meditation
    try {
      final medStats = await _ref.read(meditationStatsProvider.future);
      sections.add(
        'Meditation: ${medStats.todayMinutes} min today, '
        '${medStats.weeklySessions} sessions this week, ${medStats.currentStreak}-day streak.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Meditation unavailable: $e');
    }

    // Heart Rate
    try {
      final hrStats = await _ref.read(heartRateStatsProvider.future);
      sections.add(
        'Heart Rate: avg resting ${hrStats.averageRestingBpm.round()} bpm, '
        'range ${hrStats.minBpm}-${hrStats.maxBpm} bpm, '
        '${hrStats.totalReadings} readings.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Heart rate unavailable: $e');
    }

    // Screen Time
    try {
      final screenStats = await _ref.read(screenTimeStatsProvider.future);
      final hrs = screenStats.todayMinutes ~/ 60;
      final mins = screenStats.todayMinutes % 60;
      sections.add(
        'Screen Time: ${hrs}h ${mins}m today, '
        '${screenStats.todayPickups} pickups, '
        'limit: ${screenStats.dailyLimitMinutes ~/ 60}h ${screenStats.dailyLimitMinutes % 60}m.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Screen time unavailable: $e');
    }

    // Inbox
    try {
      final inboxStats = await _ref.read(inboxStatsProvider.future);
      sections.add(
        'Inbox: ${inboxStats.unreadCount} unread, ${inboxStats.totalMessages} total.',
      );
    } catch (e) {
      debugPrint('[JarvisData] Inbox unavailable: $e');
    }

    if (sections.isEmpty) {
      return 'No data available yet. Start tracking to get your daily briefing!';
    }

    return sections.join('\n');
  }

  /// Build a context string scoped to the user's query intent.
  /// Detects keywords to determine which domains are relevant,
  /// then only gathers data for those domains.
  Future<String> gatherQueryContext(String userMessage) async {
    final msg = userMessage.toLowerCase();
    final sections = <String>[];

    // Keyword-to-domain mapping: check keywords, gather if matched
    final domains = <(List<String>, Future<String?> Function())>[
      (['water', 'hydrat', 'drink', 'thirst'], _gatherWater),
      (['todo', 'task', 'to-do', 'to do', 'checklist'], _gatherTodos),
      (['habit', 'streak', 'routine'], _gatherHabits),
      (['mood', 'feeling', 'emotion', 'happy', 'sad'], _gatherMood),
      (['calorie', 'food', 'eat', 'nutrition', 'protein', 'diet', 'meal'], _gatherCalories),
      (['sleep', 'bed', 'rest', 'wake', 'nap'], _gatherSleep),
      (['step', 'walk', 'distance'], _gatherSteps),
      (['workout', 'exercise', 'gym', 'run', 'train'], _gatherWorkout),
      (['focus', 'pomodoro', 'concentration', 'deep work'], _gatherFocus),
      (['meditat', 'mindful', 'calm', 'breathe'], _gatherMeditation),
      (['heart', 'bpm', 'pulse', 'cardiac'], _gatherHeartRate),
      (['screen', 'phone', 'pickup', 'usage'], _gatherScreenTime),
      (['calendar', 'event', 'meeting', 'schedule', 'appointment'], _gatherCalendar),
      (['inbox', 'email', 'mail', 'message', 'unread'], _gatherInbox),
      (['weather', 'temperature', 'rain', 'sunny', 'forecast'], _gatherWeather),
    ];

    bool anyMatched = false;
    for (final (keywords, gather) in domains) {
      if (_matches(msg, keywords)) {
        anyMatched = true;
        final data = await gather();
        if (data != null) sections.add(data);
      }
    }

    // If no specific domain matched, provide a general overview
    if (!anyMatched) {
      // Check for general queries about "today", "how am I doing", "summary", etc.
      if (_matches(msg, ['today', 'summary', 'overview', 'how am i', 'how\'m i', 'day', 'briefing', 'status'])) {
        return gatherDailyBriefing();
      }
      // For completely unrelated queries, return empty (let LLM handle freely)
      return '';
    }

    return sections.join('\n');
  }

  // ─── Individual Domain Gatherers ────────────────────────────────────

  Future<String?> _gatherWater() async {
    try {
      final s = await _ref.read(waterStatsProvider.future);
      final pct = s.dailyGoalMl > 0 ? ((s.todayIntakeMl / s.dailyGoalMl) * 100).round() : 0;
      return 'Water: ${s.todayIntakeMl}ml / ${s.dailyGoalMl}ml today ($pct%), '
          'weekly avg: ${s.weeklyAverageMl}ml, streak: ${s.currentStreak} days, '
          'best streak: ${s.bestStreak} days, goal rate: ${(s.goalCompletionRate * 100).round()}%.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherTodos() async {
    try {
      final s = await _ref.read(todoStatsProvider.future);
      return 'Todos: ${s.total} total, ${s.completed} completed, ${s.todayCount} due today, '
          '${s.overdueCount} overdue, completion rate: ${(s.completionRate * 100).round()}%, '
          'streak: ${s.currentStreak} days, ${s.thisWeekCompleted} completed this week.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherHabits() async {
    try {
      final s = await _ref.read(habitStatsProvider.future);
      return 'Habits: ${s.completedToday}/${s.totalForToday} done today, '
          '${s.totalHabits} total habits, best streak: ${s.maxBestStreak} days, '
          'weekly completion: ${(s.weeklyCompletionRate * 100).round()}%.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherMood() async {
    try {
      final s = await _ref.read(moodStatsProvider.future);
      return 'Mood: weekly avg ${s.weeklyAverageMood.toStringAsFixed(1)}/5 (${_moodLabel(s.weeklyAverageMood)}), '
          '${s.totalEntries} entries, streak: ${s.currentStreak} days, '
          'distribution: ${s.moodDistribution}.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherCalories() async {
    try {
      final s = await _ref.read(nutritionStatsProvider.future);
      return 'Nutrition: ${s.todayCalories}/${s.dailyCalorieGoal} kcal today, '
          'P: ${s.todayProtein}g, C: ${s.todayCarbs}g, F: ${s.todayFat}g, '
          'weekly avg: ${s.weeklyAverageCalories} kcal, streak: ${s.currentStreak} days.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherSleep() async {
    try {
      final s = await _ref.read(sleepStatsProvider.future);
      return 'Sleep: avg ${s.weeklyAverageHours.toStringAsFixed(1)}h/night this week, '
          'streak: ${s.currentStreak} days, goal rate: ${(s.goalCompletionRate * 100).round()}%, '
          '${s.averageBedTime != null ? 'avg bedtime: ${s.averageBedTime}, ' : ''}'
          '${s.averageWakeTime != null ? 'avg wake: ${s.averageWakeTime}, ' : ''}'
          'quality: ${s.qualityDistribution}.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherSteps() async {
    try {
      final s = await _ref.read(stepsStatsProvider.future);
      return 'Steps: ${s.todaySteps}/${s.dailyGoal} today, '
          'weekly avg: ${s.weeklyAverageSteps}, streak: ${s.currentStreak} days, '
          'total distance: ${s.totalDistanceKm.toStringAsFixed(1)}km.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherWorkout() async {
    try {
      final s = await _ref.read(workoutStatsProvider.future);
      return 'Workout: ${s.weeklySessions} sessions this week (${s.weeklyMinutes} min), '
          '${s.weeklyCalories} kcal burned, streak: ${s.currentStreak} days, '
          'types: ${s.workoutsByType}.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherFocus() async {
    try {
      final s = await _ref.read(focusTimerStatsProvider.future);
      return 'Focus: ${s.todaySessions} sessions today (${s.todayMinutes} min), '
          '${s.weeklySessions} this week (${s.weeklyMinutes} min), '
          'streak: ${s.currentStreak} days.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherMeditation() async {
    try {
      final s = await _ref.read(meditationStatsProvider.future);
      return 'Meditation: ${s.todayMinutes} min today, '
          '${s.weeklySessions} sessions this week (${s.weeklyMinutes} min), '
          'streak: ${s.currentStreak} days.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherHeartRate() async {
    try {
      final s = await _ref.read(heartRateStatsProvider.future);
      return 'Heart Rate: resting avg ${s.averageRestingBpm.round()} bpm, '
          'active avg ${s.averageActiveBpm.round()} bpm, '
          'range: ${s.minBpm}-${s.maxBpm} bpm, ${s.totalReadings} readings.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherScreenTime() async {
    try {
      final s = await _ref.read(screenTimeStatsProvider.future);
      return 'Screen Time: ${s.todayMinutes} min today, '
          '${s.todayPickups} pickups, limit: ${s.dailyLimitMinutes} min, '
          'daily avg: ${s.dailyAverageMinutes.round()} min.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherCalendar() async {
    try {
      final s = await _ref.read(calendarStatsProvider.future);
      return 'Calendar: ${s.todayEventsCount} events today, ${s.upcomingCount} upcoming'
          '${s.nextEventTitle != null ? ', next: "${s.nextEventTitle}" at ${_formatTime(s.nextEventTime)}' : ''}.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherInbox() async {
    try {
      final s = await _ref.read(inboxStatsProvider.future);
      return 'Inbox: ${s.unreadCount} unread, ${s.totalMessages} total, '
          '${s.starredCount} starred.';
    } catch (_) { return null; }
  }

  Future<String?> _gatherWeather() async {
    try {
      final weather = _ref.read(weatherProvider);
      String? result;
      weather.whenData((w) {
        result = 'Weather: ${w.currentTemperature}° ${w.currentCondition.name}, '
            'feels like ${w.feelsLike}°, high ${w.high}° / low ${w.low}°, '
            'humidity ${w.humidity}%, wind ${w.windSpeed} km/h ${w.windDirection}, '
            'UV ${w.uvIndex}, rain chance ${w.precipChance}%.';
      });
      return result;
    } catch (_) { return null; }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  bool _matches(String msg, List<String> keywords) {
    return keywords.any((k) => msg.contains(k));
  }

  String _moodLabel(double avg) {
    if (avg >= 4.5) return 'great';
    if (avg >= 3.5) return 'good';
    if (avg >= 2.5) return 'okay';
    if (avg >= 1.5) return 'bad';
    return 'awful';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Provider for the data service
final jarvisDataServiceProvider = Provider<JarvisDataService>((ref) {
  return JarvisDataService(ref);
});
