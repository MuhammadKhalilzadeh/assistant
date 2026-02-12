import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/data/services/meditation_api_service.dart';
import 'package:assistant/data/cache/meditation_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final meditationCacheProvider = Provider<MeditationCache>((ref) {
  return MeditationCache();
});

// API Service provider
final meditationApiServiceProvider = Provider<MeditationApiService>((ref) {
  return MeditationApiService();
});

// Selected date for meditation sessions (defaults to today)
final selectedMeditationDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Meditation sessions provider for selected date
final meditationSessionsProvider =
    AsyncNotifierProvider<MeditationSessionsNotifier, List<MeditationSessionModel>>(
        MeditationSessionsNotifier.new);

class MeditationSessionsNotifier extends AsyncNotifier<List<MeditationSessionModel>> {
  @override
  Future<List<MeditationSessionModel>> build() async {
    final date = ref.watch(selectedMeditationDateProvider);
    return _fetchSessions(date);
  }

  Future<List<MeditationSessionModel>> _fetchSessions(DateTime date) async {
    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
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
    final date = ref.read(selectedMeditationDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSessions(date));
  }

  Future<void> addSession(MeditationSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add sessions while offline');
    }

    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
    final date = ref.read(selectedMeditationDateProvider);
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
    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
  }

  Future<void> markComplete(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot mark session complete while offline');
    }

    final api = ref.read(meditationApiServiceProvider);
    await api.markComplete(id);

    // Refresh records and invalidate stats/history
    await refresh();
    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
  }

  Future<void> updateSession(MeditationSessionModel session) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update sessions while offline');
    }

    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
    final date = ref.read(selectedMeditationDateProvider);
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

    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
  }

  Future<void> deleteSession(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete sessions while offline');
    }

    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
    final date = ref.read(selectedMeditationDateProvider);
    await api.deleteSession(id);

    state = state.whenData((sessions) => sessions.where((s) => s.id != id).toList());

    if (state.hasValue) {
      await cache.cacheSessions(state.value!, date: date);
    }

    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
  }
}

// Meditation goal provider
final meditationGoalProvider =
    AsyncNotifierProvider<MeditationGoalNotifier, MeditationGoal>(
        MeditationGoalNotifier.new);

class MeditationGoalNotifier extends AsyncNotifier<MeditationGoal> {
  @override
  Future<MeditationGoal> build() async {
    return _fetchGoal();
  }

  Future<MeditationGoal> _fetchGoal() async {
    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return MeditationGoal.fromJson(cachedGoal);
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
        return MeditationGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(MeditationGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(meditationApiServiceProvider);
    final cache = ref.read(meditationCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(meditationStatsProvider);
    ref.invalidate(meditationHistoryProvider);
  }
}

// Meditation stats provider
final meditationStatsProvider = FutureProvider<MeditationStats>((ref) async {
  final api = ref.read(meditationApiServiceProvider);
  final cache = ref.read(meditationCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return MeditationStats.fromJson(cachedStats);
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
      return MeditationStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Meditation history provider (last 7 days)
final meditationHistoryProvider = FutureProvider<List<MeditationDailySummary>>((ref) async {
  final api = ref.read(meditationApiServiceProvider);
  final cache = ref.read(meditationCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => MeditationDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => MeditationDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
