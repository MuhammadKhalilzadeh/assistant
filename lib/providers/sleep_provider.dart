import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/services/sleep_api_service.dart';
import 'package:assistant/data/cache/sleep_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final sleepCacheProvider = Provider<SleepCache>((ref) {
  return SleepCache();
});

// API Service provider
final sleepApiServiceProvider = Provider<SleepApiService>((ref) {
  return SleepApiService();
});

// Selected date for sleep records (defaults to today)
final selectedSleepDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Sleep records provider for selected date
final sleepRecordsProvider =
    AsyncNotifierProvider<SleepRecordsNotifier, List<SleepRecordModel>>(
        SleepRecordsNotifier.new);

class SleepRecordsNotifier extends AsyncNotifier<List<SleepRecordModel>> {
  @override
  Future<List<SleepRecordModel>> build() async {
    final date = ref.watch(selectedSleepDateProvider);
    return _fetchRecords(date);
  }

  Future<List<SleepRecordModel>> _fetchRecords(DateTime date) async {
    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
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
    final date = ref.read(selectedSleepDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecords(date));
  }

  Future<void> addRecord(SleepRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add records while offline');
    }

    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
    final date = ref.read(selectedSleepDateProvider);
    final newRecord = await api.createRecord(record);

    // Check if the new record belongs to the selected date
    final recordDate = DateTime(newRecord.wakeTime.year, newRecord.wakeTime.month, newRecord.wakeTime.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (recordDate == selectedDate) {
      state = state.whenData((records) => [newRecord, ...records]);

      if (state.hasValue) {
        await cache.cacheRecords(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(sleepStatsProvider);
    ref.invalidate(sleepHistoryProvider);
  }

  Future<void> updateRecord(SleepRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update records while offline');
    }

    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
    final date = ref.read(selectedSleepDateProvider);
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

    ref.invalidate(sleepStatsProvider);
    ref.invalidate(sleepHistoryProvider);
  }

  Future<void> deleteRecord(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete records while offline');
    }

    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
    final date = ref.read(selectedSleepDateProvider);
    await api.deleteRecord(id);

    state = state.whenData((records) => records.where((r) => r.id != id).toList());

    if (state.hasValue) {
      await cache.cacheRecords(state.value!, date: date);
    }

    ref.invalidate(sleepStatsProvider);
    ref.invalidate(sleepHistoryProvider);
  }
}

// Sleep goal provider
final sleepGoalProvider =
    AsyncNotifierProvider<SleepGoalNotifier, SleepGoal>(
        SleepGoalNotifier.new);

class SleepGoalNotifier extends AsyncNotifier<SleepGoal> {
  @override
  Future<SleepGoal> build() async {
    return _fetchGoal();
  }

  Future<SleepGoal> _fetchGoal() async {
    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return SleepGoal.fromJson(cachedGoal);
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
        return SleepGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(SleepGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(sleepApiServiceProvider);
    final cache = ref.read(sleepCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(sleepStatsProvider);
    ref.invalidate(sleepHistoryProvider);
  }
}

// Sleep stats provider
final sleepStatsProvider = FutureProvider<SleepStats>((ref) async {
  final api = ref.read(sleepApiServiceProvider);
  final cache = ref.read(sleepCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return SleepStats.fromJson(cachedStats);
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
      return SleepStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Sleep history provider (last 7 days)
final sleepHistoryProvider = FutureProvider<List<SleepDailySummary>>((ref) async {
  final api = ref.read(sleepApiServiceProvider);
  final cache = ref.read(sleepCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => SleepDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => SleepDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
