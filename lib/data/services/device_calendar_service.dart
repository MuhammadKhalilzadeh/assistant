import 'package:device_calendar/device_calendar.dart';
import 'package:assistant/data/models/calendar_event.dart';

/// Service wrapping device_calendar plugin for native calendar access
class DeviceCalendarService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  /// Request calendar permissions from the user
  Future<bool> requestPermissions() async {
    try {
      final result = await _plugin.requestPermissions();
      return result.isSuccess && (result.data ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Check if calendar permissions are currently granted
  Future<bool> hasPermissions() async {
    try {
      final result = await _plugin.hasPermissions();
      return result.isSuccess && (result.data ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Get all available device calendars
  Future<List<DeviceCalendar>> getCalendars() async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return [];

      final result = await _plugin.retrieveCalendars();
      if (!result.isSuccess || result.data == null) return [];

      return result.data!
          .where((c) => c.id != null && c.id!.isNotEmpty)
          .map((c) => DeviceCalendar.fromNative(c))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get events from specified calendars within a date range
  Future<List<CalendarEvent>> getEvents({
    required List<String> calendarIds,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return [];

      final calendarsResult = await _plugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return [];

      final calendarMap = <String, Calendar>{};
      for (final cal in calendarsResult.data!) {
        if (cal.id != null) {
          calendarMap[cal.id!] = cal;
        }
      }

      final allEvents = <CalendarEvent>[];

      for (final calendarId in calendarIds) {
        final calendar = calendarMap[calendarId];
        if (calendar == null) continue;

        final params = RetrieveEventsParams(
          startDate: start,
          endDate: end,
        );

        final eventsResult = await _plugin.retrieveEvents(calendarId, params);
        if (!eventsResult.isSuccess || eventsResult.data == null) continue;

        for (final event in eventsResult.data!) {
          if (event.title == null || event.title!.isEmpty) continue;
          allEvents.add(CalendarEvent.fromDeviceEvent(event, calendar));
        }
      }

      allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      return allEvents;
    } catch (_) {
      return [];
    }
  }

  /// Create a new event on the device calendar, returns event ID
  Future<String?> createEvent(CalendarEvent event) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return null;

      final deviceEvent = event.toDeviceEvent();
      final result = await _plugin.createOrUpdateEvent(deviceEvent);
      if (result == null || !result.isSuccess) return null;
      return result.data;
    } catch (_) {
      return null;
    }
  }

  /// Update an existing event on the device calendar
  Future<void> updateEvent(CalendarEvent event) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return;

      final deviceEvent = event.toDeviceEvent();
      await _plugin.createOrUpdateEvent(deviceEvent);
    } catch (_) {
      // Silently fail
    }
  }

  /// Delete an event from the device calendar
  Future<void> deleteEvent(String calendarId, String eventId) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return;

      await _plugin.deleteEvent(calendarId, eventId);
    } catch (_) {
      // Silently fail
    }
  }
}
