import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/data/services/screen_time_api_service.dart';
import 'package:assistant/data/cache/screen_time_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final screenTimeCacheProvider = Provider<ScreenTimeCache>((ref) {
  return ScreenTimeCache();
});

// API Service provider
final screenTimeApiServiceProvider = Provider<ScreenTimeApiService>((ref) {
  return ScreenTimeApiService();
});

// Today's screen time record provider
final screenTimeRecordProvider =
    AsyncNotifierProvider<ScreenTimeRecordNotifier, ScreenTimeRecord?>(
        ScreenTimeRecordNotifier.new);

class ScreenTimeRecordNotifier extends AsyncNotifier<ScreenTimeRecord?> {
  @override
  Future<ScreenTimeRecord?> build() async {
    return _fetchRecord();
  }

  Future<ScreenTimeRecord?> _fetchRecord({DateTime? date}) async {
    final api = ref.read(screenTimeApiServiceProvider);
    final cache = ref.read(screenTimeCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cached = await cache.getCachedRecord(date: date);
      if (cached != null) return cached;
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final record = await api.getByDate(date: date);
      if (record != null) {
        await cache.cacheRecord(record, date: date);
      }
      return record;
    } on NetworkError {
      final cached = await cache.getCachedRecord(date: date);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecord());
  }

  Future<void> syncRecord(ScreenTimeRecord record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot sync screen time while offline');
    }

    final api = ref.read(screenTimeApiServiceProvider);
    final cache = ref.read(screenTimeCacheProvider);
    final saved = await api.createRecord(record);

    state = AsyncValue.data(saved);
    await cache.cacheRecord(saved);

    ref.invalidate(screenTimeStatsProvider);
    ref.invalidate(screenTimeHistoryProvider);
  }
}

// Screen time goal provider
final screenTimeGoalProvider =
    AsyncNotifierProvider<ScreenTimeGoalNotifier, ScreenTimeGoal>(
        ScreenTimeGoalNotifier.new);

class ScreenTimeGoalNotifier extends AsyncNotifier<ScreenTimeGoal> {
  @override
  Future<ScreenTimeGoal> build() async {
    return _fetchGoal();
  }

  Future<ScreenTimeGoal> _fetchGoal() async {
    final api = ref.read(screenTimeApiServiceProvider);
    final cache = ref.read(screenTimeCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return ScreenTimeGoal.fromJson(cachedGoal);
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
        return ScreenTimeGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(ScreenTimeGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(screenTimeApiServiceProvider);
    final cache = ref.read(screenTimeCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    ref.invalidate(screenTimeStatsProvider);
    ref.invalidate(screenTimeHistoryProvider);
  }
}

// Screen time stats provider
final screenTimeStatsProvider = FutureProvider<ScreenTimeStats>((ref) async {
  final api = ref.read(screenTimeApiServiceProvider);
  final cache = ref.read(screenTimeCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return ScreenTimeStats.fromJson(cachedStats);
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
      return ScreenTimeStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Screen time history provider (last 7 days)
final screenTimeHistoryProvider = FutureProvider<List<ScreenTimeDailySummary>>((ref) async {
  final api = ref.read(screenTimeApiServiceProvider);
  final cache = ref.read(screenTimeCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => ScreenTimeDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => ScreenTimeDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
