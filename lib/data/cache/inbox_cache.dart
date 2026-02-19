import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/inbox_message_model.dart';
import 'package:assistant/config/app_config.dart';

class InboxCache {
  static const _messagesBoxName = 'inbox_messages_cache';
  static const _messagesKey = 'messages';
  static const _timestampKey = 'timestamp';
  static const _statsBoxName = 'inbox_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';

  Box? _messagesBox;
  Box? _statsBox;

  Future<void> init() async {
    _messagesBox = await Hive.openBox(_messagesBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
  }

  Future<List<InboxMessage>?> getCachedMessages() async {
    final box = _messagesBox ?? await Hive.openBox(_messagesBoxName);

    final timestampMs = box.get(_timestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) return null;

    final messagesJson = box.get(_messagesKey) as List<dynamic>?;
    if (messagesJson == null) return null;

    try {
      return messagesJson
          .map((e) => InboxMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearMessagesCache();
      return null;
    }
  }

  Future<void> cacheMessages(List<InboxMessage> messages) async {
    final box = _messagesBox ?? await Hive.openBox(_messagesBoxName);
    await box.put(_messagesKey, messages.map((m) => m.toJson()).toList());
    await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearMessagesCache() async {
    final box = _messagesBox ?? await Hive.openBox(_messagesBoxName);
    await box.delete(_messagesKey);
    await box.delete(_timestampKey);
  }

  Future<Map<String, dynamic>?> getCachedStats() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);

    final timestampMs = box.get(_statsTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;

    if (DateTime.now().difference(timestamp) > ttl) return null;

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

  Future<void> clearAll() async {
    await clearMessagesCache();
    await clearStatsCache();
  }
}
