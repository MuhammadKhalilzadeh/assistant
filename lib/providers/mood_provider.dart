import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/services/mood_api_service.dart';
import 'package:assistant/data/cache/mood_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final moodCacheProvider = Provider<MoodCache>((ref) {
  return MoodCache();
});

// API Service provider
final moodApiServiceProvider = Provider<MoodApiService>((ref) {
  return MoodApiService();
});

// Selected date for mood entries (defaults to today)
final selectedMoodDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Mood entries provider for selected date
final moodEntriesProvider =
    AsyncNotifierProvider<MoodEntriesNotifier, List<MoodEntryModel>>(
        MoodEntriesNotifier.new);

class MoodEntriesNotifier extends AsyncNotifier<List<MoodEntryModel>> {
  @override
  Future<List<MoodEntryModel>> build() async {
    final date = ref.watch(selectedMoodDateProvider);
    return _fetchEntries(date);
  }

  Future<List<MoodEntryModel>> _fetchEntries(DateTime date) async {
    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
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
    final date = ref.read(selectedMoodDateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchEntries(date));
  }

  Future<void> addEntry(MoodEntryModel entry) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add entries while offline');
    }

    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
    final date = ref.read(selectedMoodDateProvider);
    final newEntry = await api.createEntry(entry);

    // Check if the new entry belongs to the selected date
    final entryDate = DateTime(newEntry.recordedAt.year, newEntry.recordedAt.month, newEntry.recordedAt.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (entryDate == selectedDate) {
      state = state.whenData((entries) => [newEntry, ...entries]);

      if (state.hasValue) {
        await cache.cacheEntries(state.value!, date: date);
      }
    }

    // Invalidate stats and history
    ref.invalidate(moodStatsProvider);
    ref.invalidate(moodHistoryProvider);
  }

  Future<void> updateEntry(MoodEntryModel entry) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update entries while offline');
    }

    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
    final date = ref.read(selectedMoodDateProvider);
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

    ref.invalidate(moodStatsProvider);
    ref.invalidate(moodHistoryProvider);
  }

  Future<void> deleteEntry(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete entries while offline');
    }

    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
    final date = ref.read(selectedMoodDateProvider);
    await api.deleteEntry(id);

    state = state.whenData((entries) => entries.where((e) => e.id != id).toList());

    if (state.hasValue) {
      await cache.cacheEntries(state.value!, date: date);
    }

    ref.invalidate(moodStatsProvider);
    ref.invalidate(moodHistoryProvider);
  }
}

// Mood goal provider
final moodGoalProvider =
    AsyncNotifierProvider<MoodGoalNotifier, MoodGoal>(
        MoodGoalNotifier.new);

class MoodGoalNotifier extends AsyncNotifier<MoodGoal> {
  @override
  Future<MoodGoal> build() async {
    return _fetchGoal();
  }

  Future<MoodGoal> _fetchGoal() async {
    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedGoal = await cache.getCachedGoal();
      if (cachedGoal != null) {
        return MoodGoal.fromJson(cachedGoal);
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
        return MoodGoal.fromJson(cachedGoal);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoal());
  }

  Future<void> updateGoal(MoodGoal goal) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update goal while offline');
    }

    final api = ref.read(moodApiServiceProvider);
    final cache = ref.read(moodCacheProvider);
    final updatedGoal = await api.updateGoal(goal);

    state = AsyncValue.data(updatedGoal);
    await cache.cacheGoal(updatedGoal.toJson());

    // Invalidate stats since goal affects progress calculations
    ref.invalidate(moodStatsProvider);
    ref.invalidate(moodHistoryProvider);
  }
}

// Mood stats provider
final moodStatsProvider = FutureProvider<MoodStats>((ref) async {
  final api = ref.read(moodApiServiceProvider);
  final cache = ref.read(moodCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return MoodStats.fromJson(cachedStats);
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
      return MoodStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Mood history provider (last 7 days)
final moodHistoryProvider = FutureProvider<List<MoodDailySummary>>((ref) async {
  final api = ref.read(moodApiServiceProvider);
  final cache = ref.read(moodCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedHistory = await cache.getCachedHistory();
    if (cachedHistory != null) {
      return cachedHistory.map((h) => MoodDailySummary.fromJson(h)).toList();
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
      return cachedHistory.map((h) => MoodDailySummary.fromJson(h)).toList();
    }
    rethrow;
  }
});
