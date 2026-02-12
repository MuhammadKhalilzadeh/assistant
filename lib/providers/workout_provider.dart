import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/data/services/workout_api_service.dart';
import 'package:assistant/data/cache/workout_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final workoutCacheProvider = Provider<WorkoutCache>((ref) {
  return WorkoutCache();
});

// API Service provider
final workoutApiServiceProvider = Provider<WorkoutApiService>((ref) {
  return WorkoutApiService();
});

// Selected date for workout sessions (defaults to today)
final selectedWorkoutDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Workout sessions provider for selected date
final workoutSessionsProvider =
    AsyncNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSessionModel>>(
        WorkoutSessionsNotifier.new);

class WorkoutSessionsNotifier extends AsyncNotifier<List<WorkoutSessionModel>> {
  @override
  Future<List<WorkoutSessionModel>> build() async {
    final date = ref.watch(selectedWorkoutDateProvider);
    return _fetchSessions(date);
  }

  Future<List<WorkoutSessionModel>> _fetchSessions(DateTime date) async {
    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedSessions = await cache.getCachedSessions(date: date);
      if (cachedSessions != null) {
        return cachedSessions;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final sessions = await api.getSessionsForDate(date: date);
      await cache.cacheSessions(sessions, date: date);
      return sessions;
    } on NetworkError {
      final cachedSessions = await cache.getCachedSessions(date: date);
      if (cachedSessions != null) {
        return cachedSessions;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    final date = ref.read(selectedWorkoutDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSessions(date));
  }

  Future<void> addSession(WorkoutSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add sessions while offline');
    }

    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final date = ref.read(selectedWorkoutDateProvider);
    final newSession = await api.createSession(session);

    // Check if the new session belongs to the selected date
    final sessionDate = DateTime(newSession.startTime.year, newSession.startTime.month, newSession.startTime.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == selectedDate) {
      state = state.whenData((sessions) => [newSession, ...sessions]);

      if (state.hasValue) {
        await cache.cacheSessions(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutHistoryProvider);
  }

  Future<void> updateSession(WorkoutSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update sessions while offline');
    }

    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final date = ref.read(selectedWorkoutDateProvider);
    final updatedSession = await api.updateSession(session);

    state = state.whenData((sessions) {
      final index = sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        final newSessions = [...sessions];
        newSessions[index] = updatedSession;
        return newSessions;
      }
      return sessions;
    });

    if (state.hasValue) {
      await cache.cacheSessions(state.value!, date: date);
    }

    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutHistoryProvider);
  }

  Future<void> deleteSession(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete sessions while offline');
    }

    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final date = ref.read(selectedWorkoutDateProvider);
    await api.deleteSession(id);

    state = state.whenData((sessions) => sessions.where((s) => s.id != id).toList());

    if (state.hasValue) {
      await cache.cacheSessions(state.value!, date: date);
    }

    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutHistoryProvider);
  }
}

// Workout goal provider
final workoutGoalProvider =
    AsyncNotifierProvider<WorkoutGoalNotifier, WorkoutGoal>(
        WorkoutGoalNotifier.new);

class WorkoutGoalNotifier extends AsyncNotifier<WorkoutGoal> {
  @override
  Future<WorkoutGoal> build() async {
    return _fetchGoal();
  }

  Future<WorkoutGoal> _fetchGoal() async {
    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return WorkoutGoal.fromJson(cachedGoal);
      }
      throw NetworkError('No internet connection and no cached goal available');
    }

    try {
      final goal = await api.getGoal();
      await cache.cacheGoal(goal.toJson());
      return goal;
    } on NetworkError {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return WorkoutGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(WorkoutGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(workoutApiServiceProvider);
    final cache = ref.read(workoutCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(workoutStatsProvider);
    ref.invalidate(workoutHistoryProvider);
  }
}

// Workout stats provider
final workoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final api = ref.read(workoutApiServiceProvider);
  final cache = ref.read(workoutCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return WorkoutStats.fromJson(cachedStats);
    }
    throw NetworkError('No internet connection and no cached stats available');
  }

  try {
    final stats = await api.getStats();
    await cache.cacheStats(stats.toJson());
    return stats;
  } on NetworkError {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return WorkoutStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Workout history provider (last 7 days)
final workoutHistoryProvider = FutureProvider<List<WorkoutDailySummary>>((ref) async {
  final api = ref.read(workoutApiServiceProvider);
  final cache = ref.read(workoutCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => WorkoutDailySummary.fromJson(h)).toList();
    }
    throw NetworkError('No internet connection and no cached history available');
  }

  try {
    final history = await api.getHistory();
    await cache.cacheHistory(history.map((h) => h.toJson()).toList());
    return history;
  } on NetworkError {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => WorkoutDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
