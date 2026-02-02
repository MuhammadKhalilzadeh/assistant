import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/models/habit_stats.dart';
import 'package:assistant/data/services/habit_api_service.dart';
import 'package:assistant/data/cache/habit_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_filters.dart';

// Cache provider
final habitCacheProvider = Provider<HabitCache>((ref) {
  return HabitCache();
});

// API Service provider
final habitApiServiceProvider = Provider<HabitApiService>((ref) {
  return HabitApiService();
});

// Habit list provider
final habitListProvider =
    AsyncNotifierProvider<HabitNotifier, List<HabitModel>>(HabitNotifier.new);

class HabitNotifier extends AsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() async {
    return _fetchHabits();
  }

  Future<List<HabitModel>> _fetchHabits() async {
    final api = ref.read(habitApiServiceProvider);
    final cache = ref.read(habitCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    // If offline, try to return cached data
    if (isOffline) {
      final cachedHabits = await cache.getCachedHabits();
      if (cachedHabits != null) {
        return cachedHabits;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final habits = await api.getHabits();
      // Cache the fresh data
      await cache.cacheHabits(habits);
      return habits;
    } on NetworkError {
      // On network error, try to return cached data
      final cachedHabits = await cache.getCachedHabits();
      if (cachedHabits != null) {
        return cachedHabits;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabits());
  }

  Future<void> addHabit(HabitModel habit) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add habits while offline');
    }

    final api = ref.read(habitApiServiceProvider);
    final cache = ref.read(habitCacheProvider);
    final newHabit = await api.createHabit(habit);

    state = state.whenData((habits) => [newHabit, ...habits]);

    // Update cache
    if (state.hasValue) {
      await cache.cacheHabits(state.value!);
    }

    // Invalidate stats
    ref.invalidate(habitStatsProvider);
  }

  Future<void> updateHabit(HabitModel habit) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update habits while offline');
    }

    final api = ref.read(habitApiServiceProvider);
    final cache = ref.read(habitCacheProvider);
    final updatedHabit = await api.updateHabit(habit);

    state = state.whenData((habits) {
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        final newHabits = [...habits];
        newHabits[index] = updatedHabit;
        return newHabits;
      }
      return habits;
    });

    // Update cache
    if (state.hasValue) {
      await cache.cacheHabits(state.value!);
    }

    // Invalidate stats
    ref.invalidate(habitStatsProvider);
  }

  Future<void> deleteHabit(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete habits while offline');
    }

    final api = ref.read(habitApiServiceProvider);
    final cache = ref.read(habitCacheProvider);
    await api.deleteHabit(id);

    state = state.whenData((habits) => habits.where((h) => h.id != id).toList());

    // Update cache
    if (state.hasValue) {
      await cache.cacheHabits(state.value!);
    }

    // Invalidate stats
    ref.invalidate(habitStatsProvider);
  }

  Future<void> toggleComplete(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update habits while offline');
    }

    final api = ref.read(habitApiServiceProvider);
    final cache = ref.read(habitCacheProvider);
    final updatedHabit = await api.toggleComplete(id);

    state = state.whenData((habits) {
      final index = habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        final newHabits = [...habits];
        newHabits[index] = updatedHabit;
        return newHabits;
      }
      return habits;
    });

    // Update cache
    if (state.hasValue) {
      await cache.cacheHabits(state.value!);
    }

    // Invalidate stats
    ref.invalidate(habitStatsProvider);
  }

  // Helper to restore a deleted habit (for undo functionality)
  Future<void> restoreHabit(HabitModel habit) async {
    await addHabit(habit);
  }
}

// Habit stats provider with caching
final habitStatsProvider = FutureProvider<HabitStats>((ref) async {
  final api = ref.read(habitApiServiceProvider);
  final cache = ref.read(habitCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return HabitStats.fromJson(cachedStats);
    }
    throw NetworkError('No internet connection and no cached stats available');
  }

  try {
    final stats = await api.getStats();
    // Cache the stats
    await cache.cacheStats(stats.toJson());
    return stats;
  } on NetworkError {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return HabitStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Filter state (HabitFilter enum imported from habit_filters.dart)
final habitFilterProvider = StateProvider<HabitFilter>((ref) => HabitFilter.all);

// Search query state
final habitSearchQueryProvider = StateProvider<String>((ref) => '');

// Category filter state
final habitCategoryFilterProvider = StateProvider<HabitCategory?>((ref) => null);

// Filtered and sorted habits
final filteredHabitsProvider = Provider<AsyncValue<List<HabitModel>>>((ref) {
  final habitsAsync = ref.watch(habitListProvider);
  final filter = ref.watch(habitFilterProvider);
  final searchQuery = ref.watch(habitSearchQueryProvider);
  final categoryFilter = ref.watch(habitCategoryFilterProvider);

  return habitsAsync.whenData((habits) {
    var filtered = [...habits];

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((habit) {
        return habit.name.toLowerCase().contains(query) ||
            (habit.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != null) {
      filtered = filtered.where((h) => h.category == categoryFilter).toList();
    }

    // Apply main filter
    switch (filter) {
      case HabitFilter.all:
        break;
      case HabitFilter.completed:
        filtered = filtered.where((h) => h.isCompletedToday).toList();
        break;
      case HabitFilter.inProgress:
        filtered = filtered.where((h) => !h.isCompletedToday && h.isTodayTargetDay).toList();
        break;
      case HabitFilter.streaks:
        filtered = filtered.where((h) => h.streak > 0).toList();
        break;
    }

    // Sort by streak (descending), then by name
    filtered.sort((a, b) {
      if (a.streak != b.streak) {
        return b.streak.compareTo(a.streak);
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  });
});

// Filter counts provider
final habitFilterCountsProvider = Provider<Map<HabitFilter, int>>((ref) {
  final habitsAsync = ref.watch(habitListProvider);

  return habitsAsync.when(
    data: (habits) => {
      HabitFilter.all: habits.length,
      HabitFilter.completed: habits.where((h) => h.isCompletedToday).length,
      HabitFilter.inProgress: habits.where((h) => !h.isCompletedToday && h.isTodayTargetDay).length,
      HabitFilter.streaks: habits.where((h) => h.streak > 0).length,
    },
    loading: () => {
      HabitFilter.all: 0,
      HabitFilter.completed: 0,
      HabitFilter.inProgress: 0,
      HabitFilter.streaks: 0,
    },
    error: (e, s) => {
      HabitFilter.all: 0,
      HabitFilter.completed: 0,
      HabitFilter.inProgress: 0,
      HabitFilter.streaks: 0,
    },
  );
});
