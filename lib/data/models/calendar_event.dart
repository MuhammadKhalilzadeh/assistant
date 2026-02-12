import 'package:device_calendar/device_calendar.dart';

/// Production calendar event model wrapping device calendar events
class CalendarEvent {
  final String? eventId;
  final String? calendarId;
  final String? calendarName;
  final int? calendarColor;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isAllDay;
  final String? recurrenceRule;

  const CalendarEvent({
    this.eventId,
    this.calendarId,
    this.calendarName,
    this.calendarColor,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isAllDay = false,
    this.recurrenceRule,
  });

  /// Create from device_calendar Event and Calendar
  factory CalendarEvent.fromDeviceEvent(Event event, Calendar calendar) {
    return CalendarEvent(
      eventId: event.eventId,
      calendarId: calendar.id,
      calendarName: calendar.name,
      calendarColor: calendar.color,
      title: event.title ?? 'Untitled',
      description: event.description,
      startTime: event.start?.toUtc().toLocal() ?? DateTime.now(),
      endTime: event.end?.toUtc().toLocal() ?? DateTime.now().add(const Duration(hours: 1)),
      location: event.location,
      isAllDay: event.allDay ?? false,
      recurrenceRule: event.recurrenceRule?.toString(),
    );
  }

  /// Convert to device_calendar Event for CRUD operations
  Event toDeviceEvent() {
    final event = Event(calendarId);
    event.eventId = eventId;
    event.title = title;
    event.description = description;
    event.start = TZDateTime.from(startTime, local);
    event.end = TZDateTime.from(endTime, local);
    event.location = location;
    event.allDay = isAllDay;
    return event;
  }

  /// Create from JSON (cache deserialization)
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['eventId'] as String?,
      calendarId: json['calendarId'] as String?,
      calendarName: json['calendarName'] as String?,
      calendarColor: json['calendarColor'] as int?,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      recurrenceRule: json['recurrenceRule'] as String?,
    );
  }

  /// Convert to JSON (cache serialization)
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'calendarId': calendarId,
      'calendarName': calendarName,
      'calendarColor': calendarColor,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'location': location,
      'isAllDay': isAllDay,
      'recurrenceRule': recurrenceRule,
    };
  }

  CalendarEvent copyWith({
    String? eventId,
    String? calendarId,
    String? calendarName,
    int? calendarColor,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    String? recurrenceRule,
  }) {
    return CalendarEvent(
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      calendarName: calendarName ?? this.calendarName,
      calendarColor: calendarColor ?? this.calendarColor,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
}

/// Calendar statistics for dashboard card
class CalendarStats {
  final int todayEventsCount;
  final String? nextEventTitle;
  final DateTime? nextEventTime;
  final int upcomingCount;

  const CalendarStats({
    required this.todayEventsCount,
    this.nextEventTitle,
    this.nextEventTime,
    required this.upcomingCount,
  });

  factory CalendarStats.empty() {
    return const CalendarStats(
      todayEventsCount: 0,
      nextEventTitle: null,
      nextEventTime: null,
      upcomingCount: 0,
    );
  }

  factory CalendarStats.fromJson(Map<String, dynamic> json) {
    return CalendarStats(
      todayEventsCount: json['todayEventsCount'] as int? ?? 0,
      nextEventTitle: json['nextEventTitle'] as String?,
      nextEventTime: json['nextEventTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextEventTime'] as int)
          : null,
      upcomingCount: json['upcomingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayEventsCount': todayEventsCount,
      'nextEventTitle': nextEventTitle,
      'nextEventTime': nextEventTime?.millisecondsSinceEpoch,
      'upcomingCount': upcomingCount,
    };
  }
}

/// Represents a device calendar account
class DeviceCalendar {
  final String id;
  final String name;
  final int color;
  final String? accountName;
  final String? accountType;
  final bool isReadOnly;

  const DeviceCalendar({
    required this.id,
    required this.name,
    required this.color,
    this.accountName,
    this.accountType,
    this.isReadOnly = false,
  });

  factory DeviceCalendar.fromNative(Calendar calendar) {
    return DeviceCalendar(
      id: calendar.id ?? '',
      name: calendar.name ?? 'Unknown',
      color: calendar.color ?? 0xFF4285F4,
      accountName: calendar.accountName,
      accountType: calendar.accountType,
      isReadOnly: calendar.isReadOnly ?? false,
    );
  }

  factory DeviceCalendar.fromJson(Map<String, dynamic> json) {
    return DeviceCalendar(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int,
      accountName: json['accountName'] as String?,
      accountType: json['accountType'] as String?,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'accountName': accountName,
      'accountType': accountType,
      'isReadOnly': isReadOnly,
    };
  }
}
