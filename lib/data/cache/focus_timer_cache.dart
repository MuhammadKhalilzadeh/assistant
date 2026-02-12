import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/config/app_config.dart';

class FocusTimerCache {
  static const _sessionsBoxName = 'focus_timer_sessions_cache';
  static const _sessionsKey = 'sessions';
  static const _sessionsDateKey = 'sessions_date';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'focus_timer_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';
  static const _goalBoxName = 'focus_timer_goal_cache';
  static const _goalKey = 'goal';
  static const _goalTimestampKey = 'goal_timestamp';
  static const _historyBoxName = 'focus_timer_history_cache';
  static const _historyKey = 'history';
  static const _historyTimestampKey = 'history_timestamp';

  Box? _sessionsBox;
  Box? _statsBox;
  Box? _goalBox;
  Box? _historyBox;

  Future<void> init() async {
    _sessionsBox = await Hive.openBox(_sessionsBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
    _goalBox = await Hive.openBox(_goalBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
  }

  Future<List<FocusSessionModel>?> getCachedSessions({DateTime? date}) async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      return null;
    }

    final cachedDateStr = box.get(_sessionsDateKey) as String?;
    final requestedDateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    if (cachedDateStr != requestedDateStr) {
      return null;
    }

    final sessionsJson = box.get(_sessionsKey) as List<dynamic>?;
    if (sessionsJson == null) return null;

    try {
      return sessionsJson
          .map((e) => FocusSessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearSessionsCache();
      return null;
    }
  }

  Future<void> cacheSessions(List<FocusSessionModel> sessions, {DateTime? date}) async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);
    final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    await box.put(_sessionsKey, sessions.map((s) => s.toJson()).toList());
    await box.put(_sessionsDateKey, dateStr);
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearSessionsCache() async {
    final box = _sessionsBox ?? await Hive.openBox(_sessionsBoxName);
    await box.delete(_sessionsKey);
    await box.delete(_sessionsDateKey);
    await box.delete(_timestampKey);
  }

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

  Future<void> cacheStats(Map<String, dynamic> stats) async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.put(_statsKey, stats);
    await box.put(_statsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearStatsCache() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.delete(_statsKey);
    await box.delete(_statsTimestampKey);
  }

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

  Future<void> cacheGoal(Map<String, dynamic> goal) async {
    final box = _goalBox ?? await Hive.openBox(_goalBoxName);
    await box.put(_goalKey, goal);
    await box.put(_goalTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearGoalCache() async {
    final box = _goalBox ?? await Hive.openBox(_goalBoxName);
    await box.delete(_goalKey);
    await box.delete(_goalTimestampKey);
  }

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

  Future<void> cacheHistory(List<Map<String, dynamic>> history) async {
    final box = _historyBox ?? await Hive.openBox(_historyBoxName);
    await box.put(_historyKey, history);
    await box.put(_historyTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearHistoryCache() async {
    final box = _historyBox ?? await Hive.openBox(_historyBoxName);
    await box.delete(_historyKey);
    await box.delete(_historyTimestampKey);
  }

  Future<void> clearAll() async {
    await clearSessionsCache();
    await clearStatsCache();
    await clearGoalCache();
    await clearHistoryCache();
  }

  Future<bool> hasCachedData() async {
    final sessions = await getCachedSessions();
    return sessions != null && sessions.isNotEmpty;
  }
}
