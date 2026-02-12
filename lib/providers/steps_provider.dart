import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/step_record_model.dart';
import 'package:assistant/data/services/steps_api_service.dart';
import 'package:assistant/data/cache/steps_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final stepsCacheProvider = Provider<StepsCache>((ref) {
  return StepsCache();
});

// API Service provider
final stepsApiServiceProvider = Provider<StepsApiService>((ref) {
  return StepsApiService();
});

// Selected date for step records (defaults to today)
final selectedStepsDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Step records provider for selected date
final stepRecordsProvider =
    AsyncNotifierProvider<StepRecordsNotifier, List<StepRecordModel>>(
        StepRecordsNotifier.new);

class StepRecordsNotifier extends AsyncNotifier<List<StepRecordModel>> {
  @override
  Future<List<StepRecordModel>> build() async {
    final date = ref.watch(selectedStepsDateProvider);
    return _fetchRecords(date);
  }

  Future<List<StepRecordModel>> _fetchRecords(DateTime date) async {
    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedRecords = await cache.getCachedRecords(date: date);
      if (cachedRecords != null) {
        return cachedRecords;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final record = await api.getRecordForDate(date: date);
      final records = record != null ? [record] : <StepRecordModel>[];
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
    final date = ref.read(selectedStepsDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecords(date));
  }

  Future<void> addRecord(StepRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add records while offline');
    }

    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final date = ref.read(selectedStepsDateProvider);
    final newRecord = await api.createRecord(record);

    // Check if the new record belongs to the selected date
    final recordDate = DateTime(newRecord.date.year, newRecord.date.month, newRecord.date.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (recordDate == selectedDate) {
      state = state.whenData((records) => [newRecord, ...records]);

      if (state.hasValue) {
        await cache.cacheRecords(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
  }

  Future<void> addSteps(int steps) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add steps while offline');
    }

    final api = ref.read(stepsApiServiceProvider);
    await api.addSteps(steps);

    // Refresh records and invalidate stats/history
    await refresh();
    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
  }

  Future<void> updateRecord(StepRecordModel record) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update records while offline');
    }

    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final date = ref.read(selectedStepsDateProvider);
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

    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
  }

  Future<void> deleteRecord(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete records while offline');
    }

    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final date = ref.read(selectedStepsDateProvider);
    await api.deleteRecord(id);

    state = state.whenData((records) => records.where((r) => r.id != id).toList());

    if (state.hasValue) {
      await cache.cacheRecords(state.value!, date: date);
    }

    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
  }
}

// Steps goal provider
final stepsGoalProvider =
    AsyncNotifierProvider<StepsGoalNotifier, StepsGoal>(
        StepsGoalNotifier.new);

class StepsGoalNotifier extends AsyncNotifier<StepsGoal> {
  @override
  Future<StepsGoal> build() async {
    return _fetchGoal();
  }

  Future<StepsGoal> _fetchGoal() async {
    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return StepsGoal.fromJson(cachedGoal);
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
        return StepsGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(StepsGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(stepsApiServiceProvider);
    final cache = ref.read(stepsCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(stepsStatsProvider);
    ref.invalidate(stepsHistoryProvider);
  }
}

// Steps stats provider
final stepsStatsProvider = FutureProvider<StepsStats>((ref) async {
  final api = ref.read(stepsApiServiceProvider);
  final cache = ref.read(stepsCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return StepsStats.fromJson(cachedStats);
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
      return StepsStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Steps history provider (last 7 days)
final stepsHistoryProvider = FutureProvider<List<StepsDailySummary>>((ref) async {
  final api = ref.read(stepsApiServiceProvider);
  final cache = ref.read(stepsCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => StepsDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => StepsDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
