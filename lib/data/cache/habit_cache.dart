import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/config/app_config.dart';

/// Hive-based cache for habits with TTL support
class HabitCache {
  static const _habitsBoxName = 'habits_cache';
  static const _habitsKey = 'habits';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'habits_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';

  Box? _habitsBox;
  Box? _statsBox;

  /// Initialize the cache
  Future<void> init() async {
    _habitsBox = await Hive.openBox(_habitsBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
  }

  /// Get cached habits if they exist and are not expired
  Future<List<HabitModel>?> getCachedHabits() async {
    final box = _habitsBox ?? await Hive.openBox(_habitsBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      // Cache expired
      return null;
    }

    final habitsJson = box.get(_habitsKey) as List<dynamic>?;
    if (habitsJson == null) return null;

    try {
      return habitsJson
          .map((e) => HabitModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Invalid cache data, clear it
      await clearHabitsCache();
      return null;
    }
  }

  /// Cache habits with current timestamp
  Future<void> cacheHabits(List<HabitModel> habits) async {
    final box = _habitsBox ?? await Hive.openBox(_habitsBoxName);
    await box.put(_habitsKey, habits.map((h) => h.toJson()).toList());
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the habits cache
  Future<void> clearHabitsCache() async {
    final box = _habitsBox ?? await Hive.openBox(_habitsBoxName);
    await box.delete(_habitsKey);
    await box.delete(_timestampKey);
  }

  /// Get cached stats if they exist and are not expired
  Future<Map<String, dynamic>?> getCachedStats() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);

    final timestampMs = box.get(_statsTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    final statsJson = box.get(_statsKey);
    if (statsJson == null) return null;

    try {
      return Map<String, dynamic>.from(statsJson as Map);
    } catch (_) {
      await clearStatsCache();
      return null;
    }
  }

  /// Cache stats with current timestamp
  Future<void> cacheStats(Map<String, dynamic> stats) async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.put(_statsKey, stats);
    await box.put(_statsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the stats cache
  Future<void> clearStatsCache() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.delete(_statsKey);
    await box.delete(_statsTimestampKey);
  }

  /// Clear all caches
  Future<void> clearAll() async {
    await clearHabitsCache();
    await clearStatsCache();
  }

  /// Check if we have any cached data (for offline mode)
  Future<bool> hasCachedData() async {
    final habits = await getCachedHabits();
    return habits != null && habits.isNotEmpty;
  }
}
