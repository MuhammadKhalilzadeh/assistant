import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/data/services/water_api_service.dart';
import 'package:assistant/data/cache/water_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final waterCacheProvider = Provider<WaterCache>((ref) {
  return WaterCache();
});

// API Service provider
final waterApiServiceProvider = Provider<WaterApiService>((ref) {
  return WaterApiService();
});

// Selected date for water logs (defaults to today)
final selectedWaterDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Water logs provider for selected date
final waterLogsProvider =
    AsyncNotifierProvider<WaterLogsNotifier, List<WaterLogModel>>(
        WaterLogsNotifier.new);

class WaterLogsNotifier extends AsyncNotifier<List<WaterLogModel>> {
  @override
  Future<List<WaterLogModel>> build() async {
    final date = ref.watch(selectedWaterDateProvider);
    return _fetchLogs(date);
  }

  Future<List<WaterLogModel>> _fetchLogs(DateTime date) async {
    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedLogs = await cache.getCachedLogs(date: date);
      if (cachedLogs != null) {
        return cachedLogs;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final logs = await api.getLogsForDate(date: date);
      await cache.cacheLogs(logs, date: date);
      return logs;
    } on NetworkError {
      final cachedLogs = await cache.getCachedLogs(date: date);
      if (cachedLogs != null) {
        return cachedLogs;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    final date = ref.read(selectedWaterDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLogs(date));
  }

  Future<void> addLog(WaterLogModel log) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add water logs while offline');
    }

    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final date = ref.read(selectedWaterDateProvider);
    final newLog = await api.createLog(log);

    // Check if the new log belongs to the selected date
    final logDate = DateTime(newLog.loggedAt.year, newLog.loggedAt.month, newLog.loggedAt.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (logDate == selectedDate) {
      state = state.whenData((logs) => [newLog, ...logs]);

      if (state.hasValue) {
        await cache.cacheLogs(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(waterStatsProvider);
    ref.invalidate(waterHistoryProvider);
  }

  Future<void> updateLog(WaterLogModel log) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update water logs while offline');
    }

    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final date = ref.read(selectedWaterDateProvider);
    final updatedLog = await api.updateLog(log);

    state = state.whenData((logs) {
      final index = logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        final newLogs = [...logs];
        newLogs[index] = updatedLog;
        return newLogs;
      }
      return logs;
    });

    if (state.hasValue) {
      await cache.cacheLogs(state.value!, date: date);
    }

    ref.invalidate(waterStatsProvider);
    ref.invalidate(waterHistoryProvider);
  }

  Future<void> deleteLog(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete water logs while offline');
    }

    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final date = ref.read(selectedWaterDateProvider);
    await api.deleteLog(id);

    state = state.whenData((logs) => logs.where((l) => l.id != id).toList());

    if (state.hasValue) {
      await cache.cacheLogs(state.value!, date: date);
    }

    ref.invalidate(waterStatsProvider);
    ref.invalidate(waterHistoryProvider);
  }
}

// Hydration goal provider
final hydrationGoalProvider =
    AsyncNotifierProvider<HydrationGoalNotifier, HydrationGoal>(
        HydrationGoalNotifier.new);

class HydrationGoalNotifier extends AsyncNotifier<HydrationGoal> {
  @override
  Future<HydrationGoal> build() async {
    return _fetchGoal();
  }

  Future<HydrationGoal> _fetchGoal() async {
    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return HydrationGoal.fromJson(cachedGoal);
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
        return HydrationGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(HydrationGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(waterApiServiceProvider);
    final cache = ref.read(waterCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(waterStatsProvider);
    ref.invalidate(waterHistoryProvider);
  }
}

// Water stats provider
final waterStatsProvider = FutureProvider<WaterStats>((ref) async {
  final api = ref.read(waterApiServiceProvider);
  final cache = ref.read(waterCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return WaterStats.fromJson(cachedStats);
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
      return WaterStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Water history provider (last 7 days)
final waterHistoryProvider = FutureProvider<List<DailySummary>>((ref) async {
  final api = ref.read(waterApiServiceProvider);
  final cache = ref.read(waterCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => DailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => DailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});

// Computed provider for today's total intake
final todayIntakeProvider = Provider<int>((ref) {
  final logsAsync = ref.watch(waterLogsProvider);
  final selectedDate = ref.watch(selectedWaterDateProvider);
  final today = DateTime.now();

  // Only calculate if viewing today's logs
  if (selectedDate.year != today.year ||
      selectedDate.month != today.month ||
      selectedDate.day != today.day) {
    return 0;
  }

  return logsAsync.when(
    data: (logs) => logs.fold<int>(0, (sum, log) => sum + log.amountMl),
    loading: () => 0,
    error: (_, _) => 0,
  );
});
