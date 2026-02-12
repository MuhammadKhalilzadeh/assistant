import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/data/services/focus_timer_api_service.dart';
import 'package:assistant/data/cache/focus_timer_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final focusTimerCacheProvider = Provider<FocusTimerCache>((ref) {
  return FocusTimerCache();
});

// API Service provider
final focusTimerApiServiceProvider = Provider<FocusTimerApiService>((ref) {
  return FocusTimerApiService();
});

// Selected date for focus timer sessions (defaults to today)
final selectedFocusTimerDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Focus timer sessions provider for selected date
final focusTimerSessionsProvider =
    AsyncNotifierProvider<FocusTimerSessionsNotifier, List<FocusSessionModel>>(
        FocusTimerSessionsNotifier.new);

class FocusTimerSessionsNotifier extends AsyncNotifier<List<FocusSessionModel>> {
  @override
  Future<List<FocusSessionModel>> build() async {
    final date = ref.watch(selectedFocusTimerDateProvider);
    return _fetchSessions(date);
  }

  Future<List<FocusSessionModel>> _fetchSessions(DateTime date) async {
    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
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
    final date = ref.read(selectedFocusTimerDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSessions(date));
  }

  Future<void> addSession(FocusSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add sessions while offline');
    }

    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
    final date = ref.read(selectedFocusTimerDateProvider);
    final newSession = await api.createSession(session);

    final sessionDate = DateTime(newSession.startTime.year, newSession.startTime.month, newSession.startTime.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == selectedDate) {
      state = state.whenData((sessions) => [newSession, ...sessions]);

      if (state.hasValue) {
        await cache.cacheSessions(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }

  Future<void> markComplete(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot mark session complete while offline');
    }

    final api = ref.read(focusTimerApiServiceProvider);
    await api.markComplete(id);

    await refresh();
    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }

  Future<void> updateSession(FocusSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update sessions while offline');
    }

    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
    final date = ref.read(selectedFocusTimerDateProvider);
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

    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }

  Future<void> deleteSession(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete sessions while offline');
    }

    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
    final date = ref.read(selectedFocusTimerDateProvider);
    await api.deleteSession(id);

    state = state.whenData((sessions) => sessions.where((s) => s.id != id).toList());

    if (state.hasValue) {
      await cache.cacheSessions(state.value!, date: date);
    }

    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }
}

// Focus timer goal provider
final focusTimerGoalProvider =
    AsyncNotifierProvider<FocusTimerGoalNotifier, FocusTimerGoal>(
        FocusTimerGoalNotifier.new);

class FocusTimerGoalNotifier extends AsyncNotifier<FocusTimerGoal> {
  @override
  Future<FocusTimerGoal> build() async {
    return _fetchGoal();
  }

  Future<FocusTimerGoal> _fetchGoal() async {
    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return FocusTimerGoal.fromJson(cachedGoal);
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
        return FocusTimerGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(FocusTimerGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(focusTimerApiServiceProvider);
    final cache = ref.read(focusTimerCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    ref.invalidate(focusTimerStatsProvider);
    ref.invalidate(focusTimerHistoryProvider);
  }
}

// Focus timer stats provider
final focusTimerStatsProvider = FutureProvider<FocusTimerStats>((ref) async {
  final api = ref.read(focusTimerApiServiceProvider);
  final cache = ref.read(focusTimerCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return FocusTimerStats.fromJson(cachedStats);
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
      return FocusTimerStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Focus timer history provider (last 7 days)
final focusTimerHistoryProvider = FutureProvider<List<FocusTimerDailySummary>>((ref) async {
  final api = ref.read(focusTimerApiServiceProvider);
  final cache = ref.read(focusTimerCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => FocusTimerDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => FocusTimerDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
