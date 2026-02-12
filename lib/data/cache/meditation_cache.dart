import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/config/app_config.dart';

/// Hive-based cache for meditation sessions with TTL support
class MeditationCache {
  static const _sessionsBoxName = 'meditation_sessions_cache';
  static const _sessionsKey = 'sessions';
  static const _sessionsDateKey = 'sessions_date';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'meditation_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';
  static const _goalBoxName = 'meditation_goal_cache';
  static const _goalKey = 'goal';
  static const _goalTimestampKey = 'goal_timestamp';
  static const _historyBoxName = 'meditation_history_cache';
  static const _historyKey = 'history';
  static const _historyTimestampKey = 'history_timestamp';

  Box? _sessionsBox;
  Box? _statsBox;
  Box? _goalBox;
  Box? _historyBox;

  /// Initialize the cache
  Future<void> init() async {
    _sessionsBox = await Hive.openBox(_sessionsBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
    _goalBox = await Hive.openBox(_goalBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
  }

  /// Get cached meditation sessions if they exist, are not expired, and match the date
  Future<List<MeditationSessionModel>?> getCachedSessions({DateTime? date}) async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    // Check if cached date matches requested date
    final cachedDateStr = box.get(_sessionsDateKey) as String?;
    final requestedDateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    if (cachedDateStr != requestedDateStr) {
      return null;
    }

    final sessionsJson = box.get(_sessionsKey) as List<dynamic>?;
    if (sessionsJson == null) return null;

    try {
      return sessionsJson
          .map((e) => MeditationSessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearSessionsCache();
      return null;
    }
  }

  /// Cache meditation sessions with current timestamp
  Future<void> cacheSessions(List<MeditationSessionModel> sessions, {DateTime? date}) async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);
    final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    await box.put(_sessionsKey, sessions.map((s) => s.toJson()).toList());
    await box.put(_sessionsDateKey, dateStr);
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the sessions cache
  Future<void> clearSessionsCache() async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);
    await box.delete(_sessionsKey);
    await box.delete(_sessionsDateKey);
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
    await clearSessionsCache();
    await clearStatsCache();
    await clearGoalCache();
    await clearHistoryCache();
  }

  /// Check if we have any cached data (for offline mode)
  Future<bool> hasCachedData() async {
    final sessions = await getCachedSessions();
    return sessions != null && sessions.isNotEmpty;
  }
}
