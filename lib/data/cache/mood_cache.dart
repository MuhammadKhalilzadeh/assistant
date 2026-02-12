import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/config/app_config.dart';

/// Hive-based cache for mood entries with TTL support
class MoodCache {
  static const _entriesBoxName = 'mood_entries_cache';
  static const _entriesKey = 'entries';
  static const _entriesDateKey = 'entries_date';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'mood_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';
  static const _goalBoxName = 'mood_goal_cache';
  static const _goalKey = 'goal';
  static const _goalTimestampKey = 'goal_timestamp';
  static const _historyBoxName = 'mood_history_cache';
  static const _historyKey = 'history';
  static const _historyTimestampKey = 'history_timestamp';

  Box? _entriesBox;
  Box? _statsBox;
  Box? _goalBox;
  Box? _historyBox;

  /// Initialize the cache
  Future<void> init() async {
    _entriesBox = await Hive.openBox(_entriesBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
    _goalBox = await Hive.openBox(_goalBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
  }

  /// Get cached mood entries if they exist, are not expired, and match the date
  Future<List<MoodEntryModel>?> getCachedEntries({DateTime? date}) async {
    final box = _entriesBox ?? await Hive.openBox(_entriesBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    // Check if cached date matches requested date
    final cachedDateStr = box.get(_entriesDateKey) as String?;
    final requestedDateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    if (cachedDateStr != requestedDateStr) {
      return null;
    }

    final entriesJson = box.get(_entriesKey) as List<dynamic>?;
    if (entriesJson == null) return null;

    try {
      return entriesJson
          .map((e) => MoodEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearEntriesCache();
      return null;
    }
  }

  /// Cache mood entries with current timestamp
  Future<void> cacheEntries(List<MoodEntryModel> entries, {DateTime? date}) async {
    final box = _entriesBox ?? await Hive.openBox(_entriesBoxName);
    final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    await box.put(_entriesKey, entries.map((e) => e.toJson()).toList());
    await box.put(_entriesDateKey, dateStr);
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the entries cache
  Future<void> clearEntriesCache() async {
    final box = _entriesBox ?? await Hive.openBox(_entriesBoxName);
    await box.delete(_entriesKey);
    await box.delete(_entriesDateKey);
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

  /// Get cached goal if it exists and is not expired
  Future<Map<String, dynamic>?> getCachedGoal() async {
    final box = _goalBox ?? await Hive.openBox(_goalBoxName);

    final timestampMs = box.get(_goalTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    final goalJson = box.get(_goalKey);
    if (goalJson == null) return null;

    try {
      return Map<String, dynamic>.from(goalJson as Map);
    } catch (_) {
      await clearGoalCache();
      return null;
    }
  }

  /// Cache goal with current timestamp
  Future<void> cacheGoal(Map<String, dynamic> goal) async {
    final box = _goalBox ?? await Hive.openBox(_goalBoxName);
    await box.put(_goalKey, goal);
    await box.put(_goalTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the goal cache
  Future<void> clearGoalCache() async {
    final box = _goalBox ?? await Hive.openBox(_goalBoxName);
    await box.delete(_goalKey);
    await box.delete(_goalTimestampKey);
  }

  /// Get cached history if it exists and is not expired
  Future<List<Map<String, dynamic>>?> getCachedHistory() async {
    final box = _historyBox ?? await Hive.openBox(_historyBoxName);

    final timestampMs = box.get(_historyTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    final historyJson = box.get(_historyKey) as List<dynamic>?;
    if (historyJson == null) return null;

    try {
      return historyJson
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      await clearHistoryCache();
      return null;
    }
  }

  /// Cache history with current timestamp
  Future<void> cacheHistory(List<Map<String, dynamic>> history) async {
    final box = _historyBox ?? await Hive.openBox(_historyBoxName);
    await box.put(_historyKey, history);
    await box.put(_historyTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the history cache
  Future<void> clearHistoryCache() async {
    final box = _historyBox ?? await Hive.openBox(_historyBoxName);
    await box.delete(_historyKey);
    await box.delete(_historyTimestampKey);
  }

  /// Clear all caches
  Future<void> clearAll() async {
    await clearEntriesCache();
    await clearStatsCache();
    await clearGoalCache();
    await clearHistoryCache();
  }

  /// Check if we have any cached data (for offline mode)
  Future<bool> hasCachedData() async {
    final entries = await getCachedEntries();
    return entries != null && entries.isNotEmpty;
  }
}
