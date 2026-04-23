import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/data/services/device_calendar_service.dart';
import 'package:assistant/data/cache/calendar_cache.dart';

// Service provider
final deviceCalendarServiceProvider = Provider<DeviceCalendarService>((ref) {
  return DeviceCalendarService();
});

// Cache provider
final calendarCacheProvider = Provider<CalendarCache>((ref) {
  return CalendarCache();
});

// Permission state
final calendarPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(deviceCalendarServiceProvider);
  return service.hasPermissions();
});

// Available device calendars
final deviceCalendarsProvider = FutureProvider<List<DeviceCalendar>>((ref) async {
  final service = ref.read(deviceCalendarServiceProvider);
  final cache = ref.read(calendarCacheProvider);

  // Try cache first
  final cached = await cache.getCachedCalendars();
  if (cached != null) return cached;

  final calendars = await service.getCalendars();
  if (calendars.isNotEmpty) {
    await cache.cacheCalendars(calendars);
  }
  return calendars;
});

// User's selected calendar IDs to display (empty = all selected)
final selectedCalendarIdsProvider = StateProvider<Set<String>>((ref) => {});

// Current view date range — 1 month back + 2 months forward
final calendarDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month - 1, 1),
    end: DateTime(now.year, now.month + 2, 0, 23, 59, 59),
  );
});

// Events for current date range (reactive to dateRange + selectedCalendars)
final calendarEventsProvider =
    AsyncNotifierProvider<CalendarEventsNotifier, List<CalendarEvent>>(
        CalendarEventsNotifier.new);

class CalendarEventsNotifier extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() async {
    return _fetchEvents();
  }

  Future<List<CalendarEvent>> _fetchEvents() async {
    final service = ref.read(deviceCalendarServiceProvider);
    final cache = ref.read(calendarCacheProvider);
    final dateRange = ref.watch(calendarDateRangeProvider);
    final selectedIds = ref.watch(selectedCalendarIdsProvider);

    // Get all calendars
    final calendars = await service.getCalendars();
    if (calendars.isEmpty) {
      // Try cache fallback
      final cached = await cache.getCachedEvents();
      return cached ?? [];
    }

    // Determine which calendar IDs to query
    final calendarIds = selectedIds.isEmpty
        ? calendars.map((c) => c.id).toList()
        : selectedIds.toList();

    try {
      final events = await service.getEvents(
        calendarIds: calendarIds,
        start: dateRange.start,
        end: dateRange.end,
      );

      // Cache fresh data
      await cache.cacheEvents(events);
      return events;
    } catch (_) {
      // Fallback to cache
      final cached = await cache.getCachedEvents();
      return cached ?? [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchEvents());
  }

  Future<void> addEvent(CalendarEvent event) async {
    final service = ref.read(deviceCalendarServiceProvider);
    final eventId = await service.createEvent(event);
    if (eventId != null) {
      await refresh();
      ref.invalidate(calendarStatsProvider);
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final service = ref.read(deviceCalendarServiceProvider);
    await service.updateEvent(event);
    await refresh();
    ref.invalidate(calendarStatsProvider);
  }

  Future<void> deleteEvent(String calendarId, String eventId) async {
    final service = ref.read(deviceCalendarServiceProvider);
    await service.deleteEvent(calendarId, eventId);
    await refresh();
    ref.invalidate(calendarStatsProvider);
  }
}

// Stats for dashboard card
final calendarStatsProvider = FutureProvider<CalendarStats>((ref) async {
  final service = ref.read(deviceCalendarServiceProvider);
  final cache = ref.read(calendarCacheProvider);

  // Try cache first
  final cachedStats = await cache.getCachedStats();
  if (cachedStats != null) return cachedStats;

  final hasPerms = await service.hasPermissions();
  if (!hasPerms) return CalendarStats.empty();

  final calendars = await service.getCalendars();
  if (calendars.isEmpty) return CalendarStats.empty();

  final calendarIds = calendars.map((c) => c.id).toList();
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final weekEnd = todayEnd.add(const Duration(days: 7));

  // Get today's events
  final todayEvents = await service.getEvents(
    calendarIds: calendarIds,
    start: todayStart,
    end: todayEnd,
  );

  // Get upcoming events (next 7 days)
  final upcomingEvents = await service.getEvents(
    calendarIds: calendarIds,
    start: now,
    end: weekEnd,
  );

  // Find next event
  final futureEvents = upcomingEvents
      .where((e) => e.startTime.isAfter(now))
      .toList();

  final stats = CalendarStats(
    todayEventsCount: todayEvents.length,
    nextEventTitle: futureEvents.isNotEmpty ? futureEvents.first.title : null,
    nextEventTime: futureEvents.isNotEmpty ? futureEvents.first.startTime : null,
    upcomingCount: upcomingEvents.length,
  );

  await cache.cacheStats(stats);
  return stats;
});
