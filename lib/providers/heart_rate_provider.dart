import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/services/heart_rate_api_service.dart';
import 'package:assistant/data/cache/heart_rate_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final heartRateCacheProvider = Provider<HeartRateCache>((ref) {
  return HeartRateCache();
});

// API Service provider
final heartRateApiServiceProvider = Provider<HeartRateApiService>((ref) {
  return HeartRateApiService();
});

// Selected date for heart rate records (defaults to today)
final selectedHeartRateDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Heart rate records provider for selected date
final heartRateRecordsProvider =
    AsyncNotifierProvider<HeartRateRecordsNotifier, List<HeartRateRecordModel>>(
        HeartRateRecordsNotifier.new);

class HeartRateRecordsNotifier extends AsyncNotifier<List<HeartRateRecordModel>> {
  @override
  Future<List<HeartRateRecordModel>> build() async {
    final date = ref.watch(selectedHeartRateDateProvider);
    return _fetchRecords(date);
  }

  Future<List<HeartRateRecordModel>> _fetchRecords(DateTime date) async {
    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedRecords = await cache.getCachedRecords(date: date);
      if (cachedRecords != null) {
        return cachedRecords;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final records = await api.getRecordsForDate(date: date);
      await cache.cacheRecords(records, date: date);
      return records;
    } on NetworkError {
      final cachedRecords = await cache.getCachedRecords(date: date);
      if (cachedRecords != null) {
        return cachedRecords;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    final date = ref.read(selectedHeartRateDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecords(date));
  }

  Future<void> addRecord(HeartRateRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add records while offline');
    }

    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final date = ref.read(selectedHeartRateDateProvider);
    final newRecord = await api.createRecord(record);

    // Check if the new record belongs to the selected date
    final recordDate = DateTime(newRecord.recordedAt.year, newRecord.recordedAt.month, newRecord.recordedAt.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (recordDate == selectedDate) {
      state = state.whenData((records) => [newRecord, ...records]);

      if (state.hasValue) {
        await cache.cacheRecords(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(heartRateStatsProvider);
    ref.invalidate(heartRateHistoryProvider);
  }

  Future<void> updateRecord(HeartRateRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update records while offline');
    }

    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final date = ref.read(selectedHeartRateDateProvider);
    final updatedRecord = await api.updateRecord(record);

    state = state.whenData((records) {
      final index = records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        final newRecords = [...records];
        newRecords[index] = updatedRecord;
        return newRecords;
      }
      return records;
    });

    if (state.hasValue) {
      await cache.cacheRecords(state.value!, date: date);
    }

    ref.invalidate(heartRateStatsProvider);
    ref.invalidate(heartRateHistoryProvider);
  }

  Future<void> deleteRecord(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete records while offline');
    }

    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final date = ref.read(selectedHeartRateDateProvider);
    await api.deleteRecord(id);

    state = state.whenData((records) => records.where((r) => r.id != id).toList());

    if (state.hasValue) {
      await cache.cacheRecords(state.value!, date: date);
    }

    ref.invalidate(heartRateStatsProvider);
    ref.invalidate(heartRateHistoryProvider);
  }
}

// Heart rate goal provider
final heartRateGoalProvider =
    AsyncNotifierProvider<HeartRateGoalNotifier, HeartRateGoal>(
        HeartRateGoalNotifier.new);

class HeartRateGoalNotifier extends AsyncNotifier<HeartRateGoal> {
  @override
  Future<HeartRateGoal> build() async {
    return _fetchGoal();
  }

  Future<HeartRateGoal> _fetchGoal() async {
    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return HeartRateGoal.fromJson(cachedGoal);
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
        return HeartRateGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(HeartRateGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(heartRateApiServiceProvider);
    final cache = ref.read(heartRateCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(heartRateStatsProvider);
    ref.invalidate(heartRateHistoryProvider);
  }
}

// Heart rate stats provider
final heartRateStatsProvider = FutureProvider<HeartRateStats>((ref) async {
  final api = ref.read(heartRateApiServiceProvider);
  final cache = ref.read(heartRateCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return HeartRateStats.fromJson(cachedStats);
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
      return HeartRateStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Heart rate history provider (last 7 days)
final heartRateHistoryProvider = FutureProvider<List<HeartRateDailySummary>>((ref) async {
  final api = ref.read(heartRateApiServiceProvider);
  final cache = ref.read(heartRateCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => HeartRateDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => HeartRateDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
