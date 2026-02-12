import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/calendar_event.dart';

/// Hive-based cache for calendar events and calendars with short TTL
class CalendarCache {
  static const _eventsBoxName = 'calendar_events_cache';
  static const _eventsKey = 'events';
  static const _eventsTimestampKey = 'events_timestamp';
  static const _calendarsBoxName = 'calendar_list_cache';
  static const _calendarsKey = 'calendars';
  static const _calendarsTimestampKey = 'calendars_timestamp';
  static const _statsBoxName = 'calendar_stats_cache';
  static const _statsKey = 'stats';
  static const _statsTimestampKey = 'stats_timestamp';

  // Short TTL since device calendars can change externally
  static const Duration _cacheTtl = Duration(minutes: 5);

  Box? _eventsBox;
  Box? _calendarsBox;
  Box? _statsBox;

  /// Initialize the cache
  Future<void> init() async {
    _eventsBox = await Hive.openBox(_eventsBoxName);
    _calendarsBox = await Hive.openBox(_calendarsBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
  }

  /// Get cached events if they exist and are not expired
  Future<List<CalendarEvent>?> getCachedEvents() async {
    final box = _eventsBox ?? await Hive.openBox(_eventsBoxName);

    final timestampMs = box.get(_eventsTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (DateTime.now().difference(timestamp) > _cacheTtl) {
      return null;
    }

    final eventsJson = box.get(_eventsKey) as List<dynamic>?;
    if (eventsJson == null) return null;

    try {
      return eventsJson
          .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearEventsCache();
      return null;
    }
  }

  /// Cache events with current timestamp
  Future<void> cacheEvents(List<CalendarEvent> events) async {
    final box = _eventsBox ?? await Hive.openBox(_eventsBoxName);
    await box.put(_eventsKey, events.map((e) => e.toJson()).toList());
    await box.put(_eventsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear events cache
  Future<void> clearEventsCache() async {
    final box = _eventsBox ?? await Hive.openBox(_eventsBoxName);
    await box.delete(_eventsKey);
    await box.delete(_eventsTimestampKey);
  }

  /// Get cached calendars if they exist and are not expired
  Future<List<DeviceCalendar>?> getCachedCalendars() async {
    final box = _calendarsBox ?? await Hive.openBox(_calendarsBoxName);

    final timestampMs = box.get(_calendarsTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (DateTime.now().difference(timestamp) > _cacheTtl) {
      return null;
    }

    final calendarsJson = box.get(_calendarsKey) as List<dynamic>?;
    if (calendarsJson == null) return null;

    try {
      return calendarsJson
          .map((e) => DeviceCalendar.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await clearCalendarsCache();
      return null;
    }
  }

  /// Cache calendars with current timestamp
  Future<void> cacheCalendars(List<DeviceCalendar> calendars) async {
    final box = _calendarsBox ?? await Hive.openBox(_calendarsBoxName);
    await box.put(_calendarsKey, calendars.map((c) => c.toJson()).toList());
    await box.put(_calendarsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear calendars cache
  Future<void> clearCalendarsCache() async {
    final box = _calendarsBox ?? await Hive.openBox(_calendarsBoxName);
    await box.delete(_calendarsKey);
    await box.delete(_calendarsTimestampKey);
  }

  /// Get cached stats if they exist and are not expired
  Future<CalendarStats?> getCachedStats() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);

    final timestampMs = box.get(_statsTimestampKey) as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (DateTime.now().difference(timestamp) > _cacheTtl) {
      return null;
    }

    final statsJson = box.get(_statsKey);
    if (statsJson == null) return null;

    try {
      return CalendarStats.fromJson(Map<String, dynamic>.from(statsJson as Map));
    } catch (_) {
      await clearStatsCache();
      return null;
    }
  }

  /// Cache stats with current timestamp
  Future<void> cacheStats(CalendarStats stats) async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.put(_statsKey, stats.toJson());
    await box.put(_statsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear stats cache
  Future<void> clearStatsCache() async {
    final box = _statsBox ?? await Hive.openBox(_statsBoxName);
    await box.delete(_statsKey);
    await box.delete(_statsTimestampKey);
  }

  /// Clear all caches
  Future<void> clearAll() async {
    await clearEventsCache();
    await clearCalendarsCache();
    await clearStatsCache();
  }
}
