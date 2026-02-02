import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/config/app_config.dart';

/// Hive-based cache for todos with TTL support
class TodoCache {
  static const _todosBoxName = 'todos_cache';
  static const _todosKey = 'todos';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';

  Box? _todosBox;
  Box? _statsBox;

  /// Initialize the cache
  Future<void> init() async {
    _todosBox = await Hive.openBox(_todosBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
  }

  /// Get cached todos if they exist and are not expired
  Future<List<TodoModel>?> getCachedTodos() async {
    final box = _todosBox ?? await Hive.openBox(_todosBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) {
      // Cache expired
      return null;
    }

    final todosJson = box.get(_todosKey) as List<dynamic>?;
    if (todosJson == null) return null;

    try {
      return todosJson
          .map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Invalid cache data, clear it
      await clearTodosCache();
      return null;
    }
  }

  /// Cache todos with current timestamp
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final box = _todosBox ?? await Hive.openBox(_todosBoxName);
    await box.put(_todosKey, todos.map((t) => t.toJson()).toList());
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear the todos cache
  Future<void> clearTodosCache() async {
    final box = _todosBox ?? await Hive.openBox(_todosBoxName);
    await box.delete(_todosKey);
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
    await clearTodosCache();
    await clearStatsCache();
  }

  /// Check if we have any cached data (for offline mode)
  Future<bool> hasCachedData() async {
    final todos = await getCachedTodos();
    return todos != null && todos.isNotEmpty;
  }
}
