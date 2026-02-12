import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/services/calories_api_service.dart';
import 'package:assistant/data/cache/calories_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final caloriesCacheProvider = Provider<CaloriesCache>((ref) {
  return CaloriesCache();
});

// API Service provider
final caloriesApiServiceProvider = Provider<CaloriesApiService>((ref) {
  return CaloriesApiService();
});

// Selected date for calorie entries (defaults to today)
final selectedCaloriesDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Calorie entries provider for selected date
final calorieEntriesProvider =
    AsyncNotifierProvider<CalorieEntriesNotifier, List<CalorieEntryModel>>(
        CalorieEntriesNotifier.new);

class CalorieEntriesNotifier extends AsyncNotifier<List<CalorieEntryModel>> {
  @override
  Future<List<CalorieEntryModel>> build() async {
    final date = ref.watch(selectedCaloriesDateProvider);
    return _fetchEntries(date);
  }

  Future<List<CalorieEntryModel>> _fetchEntries(DateTime date) async {
    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedEntries = await cache.getCachedEntries(date: date);
      if (cachedEntries != null) {
        return cachedEntries;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final entries = await api.getEntriesForDate(date: date);
      await cache.cacheEntries(entries, date: date);
      return entries;
    } on NetworkError {
      final cachedEntries = await cache.getCachedEntries(date: date);
      if (cachedEntries != null) {
        return cachedEntries;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    final date = ref.read(selectedCaloriesDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchEntries(date));
  }

  Future<void> addEntry(CalorieEntryModel entry) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add entries while offline');
    }

    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final date = ref.read(selectedCaloriesDateProvider);
    final newEntry = await api.createEntry(entry);

    // Check if the new entry belongs to the selected date
    final entryDate = DateTime(newEntry.loggedAt.year, newEntry.loggedAt.month, newEntry.loggedAt.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (entryDate == selectedDate) {
      state = state.whenData((entries) => [newEntry, ...entries]);

      if (state.hasValue) {
        await cache.cacheEntries(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(nutritionStatsProvider);
    ref.invalidate(nutritionHistoryProvider);
  }

  Future<void> updateEntry(CalorieEntryModel entry) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update entries while offline');
    }

    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final date = ref.read(selectedCaloriesDateProvider);
    final updatedEntry = await api.updateEntry(entry);

    state = state.whenData((entries) {
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        final newEntries = [...entries];
        newEntries[index] = updatedEntry;
        return newEntries;
      }
      return entries;
    });

    if (state.hasValue) {
      await cache.cacheEntries(state.value!, date: date);
    }

    ref.invalidate(nutritionStatsProvider);
    ref.invalidate(nutritionHistoryProvider);
  }

  Future<void> deleteEntry(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete entries while offline');
    }

    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final date = ref.read(selectedCaloriesDateProvider);
    await api.deleteEntry(id);

    state = state.whenData((entries) => entries.where((e) => e.id != id).toList());

    if (state.hasValue) {
      await cache.cacheEntries(state.value!, date: date);
    }

    ref.invalidate(nutritionStatsProvider);
    ref.invalidate(nutritionHistoryProvider);
  }
}

// Nutrition goal provider
final nutritionGoalProvider =
    AsyncNotifierProvider<NutritionGoalNotifier, NutritionGoal>(
        NutritionGoalNotifier.new);

class NutritionGoalNotifier extends AsyncNotifier<NutritionGoal> {
  @override
  Future<NutritionGoal> build() async {
    return _fetchGoal();
  }

  Future<NutritionGoal> _fetchGoal() async {
    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return NutritionGoal.fromJson(cachedGoal);
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
        return NutritionGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(NutritionGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(caloriesApiServiceProvider);
    final cache = ref.read(caloriesCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(nutritionStatsProvider);
    ref.invalidate(nutritionHistoryProvider);
  }
}

// Nutrition stats provider
final nutritionStatsProvider = FutureProvider<NutritionStats>((ref) async {
  final api = ref.read(caloriesApiServiceProvider);
  final cache = ref.read(caloriesCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return NutritionStats.fromJson(cachedStats);
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
      return NutritionStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Nutrition history provider (last 7 days)
final nutritionHistoryProvider = FutureProvider<List<DailyNutritionSummary>>((ref) async {
  final api = ref.read(caloriesApiServiceProvider);
  final cache = ref.read(caloriesCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => DailyNutritionSummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => DailyNutritionSummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
