import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/providers/calendar_provider.dart';
import 'package:assistant/providers/connectivity_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

import 'widgets/calendar_app_bar.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';
import 'widgets/day_view.dart';
import 'widgets/agenda_view.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/calendar_filter_chips.dart';

/// Calendar page with offline support, pull-to-refresh, and view toggle
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with SingleTickerProviderStateMixin {
  CalendarViewType _currentView = CalendarViewType.month;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  late AnimationController _viewTransitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _viewTransitionController,
        curve: Curves.easeOut,
      ),
    );
    _viewTransitionController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    final service = ref.read(deviceCalendarServiceProvider);
    final hasPerms = await service.hasPermissions();
    if (!hasPerms) {
      final granted = await service.requestPermissions();
      if (granted) {
        ref.invalidate(calendarPermissionProvider);
        ref.invalidate(deviceCalendarsProvider);
        ref.invalidate(calendarEventsProvider);
        ref.invalidate(calendarStatsProvider);
      }
    }
  }

  List<CalendarEvent> _filterEvents(List<CalendarEvent> events) {
    final selectedIds = ref.read(selectedCalendarIdsProvider);
    if (selectedIds.isEmpty) return events;
    return events.where((e) => selectedIds.contains(e.calendarId)).toList();
  }

  void _onViewChanged(CalendarViewType view) async {
    if (view == _currentView) return;

    await _viewTransitionController.reverse();
    setState(() => _currentView = view);
    await _viewTransitionController.forward();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = DateTime(date.year, date.month);
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _focusedMonth = month);
    _ensureDateRangeCovers(month);
  }

  /// Extend the loaded date range if the user navigates beyond it
  void _ensureDateRangeCovers(DateTime month) {
    final current = ref.read(calendarDateRangeProvider);
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    if (monthStart.isBefore(current.start) || monthEnd.isAfter(current.end)) {
      // Extend range by 6 months in the direction needed
      final newStart = monthStart.isBefore(current.start)
          ? DateTime(month.year, month.month - 6, 1)
          : current.start;
      final newEnd = monthEnd.isAfter(current.end)
          ? DateTime(month.year, month.month + 7, 0, 23, 59, 59)
          : current.end;

      ref.read(calendarDateRangeProvider.notifier).state = DateTimeRange(
        start: newStart,
        end: newEnd,
      );
    }
  }

  void _onTodayPressed() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _focusedMonth = DateTime(now.year, now.month);
    });
  }

  void _onEventTap(CalendarEvent event) {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    final calendars = ref.read(deviceCalendarsProvider).valueOrNull ?? [];
    final writableCalendars = calendars.where((c) => !c.isReadOnly).toList();

    AddEventSheet.show(
      context,
      event: event,
      calendars: writableCalendars,
      onSave: (updatedEvent) {
        ref.read(calendarEventsProvider.notifier).updateEvent(updatedEvent);
      },
      onDelete: () {
        if (event.calendarId != null && event.eventId != null) {
          ref.read(calendarEventsProvider.notifier)
              .deleteEvent(event.calendarId!, event.eventId!);
        }
      },
    );
  }

  void _onEventDelete(CalendarEvent event) {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    if (event.calendarId != null && event.eventId != null) {
      ref.read(calendarEventsProvider.notifier)
          .deleteEvent(event.calendarId!, event.eventId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${event.title}"'),
          backgroundColor: AppTheme.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  void _onAddEvent({DateTime? date, TimeOfDay? time}) {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    final calendars = ref.read(deviceCalendarsProvider).valueOrNull ?? [];
    final writableCalendars = calendars.where((c) => !c.isReadOnly).toList();

    AddEventSheet.show(
      context,
      initialDate: date ?? _selectedDate,
      initialTime: time,
      calendars: writableCalendars,
      onSave: (event) {
        ref.read(calendarEventsProvider.notifier).addEvent(event);
      },
    );
  }

  void _onTimeSlotTap(DateTime date, TimeOfDay time) {
    _onAddEvent(date: date, time: time);
  }

  Future<void> _onRefresh() async {
    ref.invalidate(calendarEventsProvider);
    ref.invalidate(deviceCalendarsProvider);
    // Wait for the events to reload
    await ref.read(calendarEventsProvider.future);
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day - weekday);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final permissionAsync = ref.watch(calendarPermissionProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final calendars = ref.watch(deviceCalendarsProvider).valueOrNull ?? [];
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: AppTheme.warningColor,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'You are offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // App bar (just title row)
            CalendarAppBar(
              onTodayPressed: _onTodayPressed,
            ),

            const SizedBox(height: 4),

            // View toggle (in page body, not in AppBar)
            CalendarViewToggle(
              currentView: _currentView,
              onViewChanged: _onViewChanged,
            ),

            const SizedBox(height: 4),

            // Calendar filter chips
            if (calendars.length > 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 2),
                child: CalendarFilterChips(calendars: calendars),
              ),

            // Content area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTheme.primaryColor,
                  child: permissionAsync.when(
                    data: (hasPermission) {
                      if (!hasPermission) {
                        return _buildPermissionRequest();
                      }
                      return eventsAsync.when(
                        data: (events) {
                          final filtered = _filterEvents(events);
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildCurrentView(filtered),
                          );
                        },
                        loading: () => _buildLoadingState(),
                        error: (e, _) => _buildErrorState(),
                      );
                    },
                    loading: () => _buildLoadingState(),
                    error: (e, _) => _buildPermissionRequest(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isOffline ? null : () => _onAddEvent(),
        backgroundColor: isOffline ? AppTheme.textTertiary : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentView(List<CalendarEvent> events) {
    switch (_currentView) {
      case CalendarViewType.month:
        return MonthView(
          selectedDate: _selectedDate,
          focusedMonth: _focusedMonth,
          events: events,
          onDateSelected: _onDateSelected,
          onMonthChanged: _onMonthChanged,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onAddEvent: () => _onAddEvent(),
        );

      case CalendarViewType.week:
        return WeekView(
          selectedDate: _selectedDate,
          focusedWeek: _getWeekStart(_selectedDate),
          events: events,
          onDateSelected: _onDateSelected,
          onWeekChanged: (weekStart) {
            setState(() {
              _focusedMonth = DateTime(weekStart.year, weekStart.month);
            });
          },
          onEventTap: _onEventTap,
          onTimeSlotTap: _onTimeSlotTap,
        );

      case CalendarViewType.day:
        return DayView(
          selectedDate: _selectedDate,
          events: events,
          onDateSelected: _onDateSelected,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onTimeSlotTap: _onTimeSlotTap,
          onAddEvent: () => _onAddEvent(),
        );

      case CalendarViewType.agenda:
        return AgendaView(
          selectedDate: _selectedDate,
          events: events,
          onDateSelected: _onDateSelected,
          onEventTap: _onEventTap,
          onEventDelete: _onEventDelete,
          onAddEvent: () => _onAddEvent(),
        );
    }
  }

  Widget _buildPermissionRequest() {
    return ListView(
      children: [
        const SizedBox(height: 48),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      size: 40,
                      color: AppTheme.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Calendar Access Required',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Grant calendar access to view events from all your calendar accounts (Google, Samsung, Exchange, etc.)',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkAndRequestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    child: const Text(
                      'Grant Access',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 48),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load calendar',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your permissions and try again',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(calendarEventsProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
