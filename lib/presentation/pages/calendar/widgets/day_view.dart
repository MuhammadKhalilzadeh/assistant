import 'package:flutter/material.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'event_item.dart';
import 'calendar_empty_state.dart';

/// Day detail/timeline view with compact header and constrained all-day events
class DayView extends StatefulWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEvent>? onEventTap;
  final ValueChanged<CalendarEvent>? onEventDelete;
  final Function(DateTime, TimeOfDay)? onTimeSlotTap;
  final VoidCallback? onAddEvent;

  const DayView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    this.onEventTap,
    this.onEventDelete,
    this.onTimeSlotTap,
    this.onAddEvent,
  });

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late PageController _pageController;
  late ScrollController _scrollController;
  static const int _initialPage = 3650;
  static const double _hourHeight = 60.0;
  static const int _startHour = 6;
  static const int _endHour = 23;

  bool _allDayExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    if (_isToday(widget.selectedDate)) {
      final scrollOffset = ((now.hour - _startHour) * _hourHeight +
              (now.minute / 60) * _hourHeight)
          .clamp(0.0, double.infinity);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DateTime _getDateForPage(int page) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDiff = page - _initialPage;
    return today.add(Duration(days: dayDiff));
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year, event.startTime.month, event.startTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate == targetDate;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Compact date header (~56px)
        _buildCompactDateHeader(),
        const SizedBox(height: 8),
        // All-day events (constrained)
        _buildAllDayEvents(),
        // Day timeline or empty state
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              widget.onDateSelected(_getDateForPage(page));
            },
            itemBuilder: (context, page) {
              final date = _getDateForPage(page);
              return _buildDayTimeline(date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDateHeader() {
    final isToday = _isToday(widget.selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary, size: 22),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(widget.selectedDate),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isToday)
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          _initialPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          'Go to today',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 22),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayEvents() {
    final allDayEvents = _getEventsForDate(widget.selectedDate)
        .where((e) => e.isAllDay)
        .toList();

    if (allDayEvents.isEmpty) return const SizedBox.shrink();

    // Show max 2 events by default, expandable
    final maxVisible = _allDayExpanded ? allDayEvents.length : 2;
    final visibleEvents = allDayEvents.take(maxVisible).toList();
    final hasMore = allDayEvents.length > 2 && !_allDayExpanded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'All Day',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            ...visibleEvents.map((event) => EventItem(
                  event: event,
                  isCompact: true,
                  onTap: () => widget.onEventTap?.call(event),
                )),
            if (hasMore)
              GestureDetector(
                onTap: () => setState(() => _allDayExpanded = true),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${allDayEvents.length - 2} more',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTimeline(DateTime date) {
    final events = _getEventsForDate(date).where((e) => !e.isAllDay).toList();
    final isToday = _isToday(date);
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    if (events.isEmpty) {
      return DateEmptyState(
        date: date,
        onAddEvent: widget.onAddEvent,
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Hour slots
            Column(
              children: List.generate(_endHour - _startHour + 1, (index) {
                final hour = _startHour + index;
                return _buildHourSlot(hour, date);
              }),
            ),
            // Event blocks (clamped positions)
            _buildEventsOverlay(events, totalHeight),
            // Current time indicator
            if (isToday) _buildCurrentTimeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHourSlot(int hour, DateTime date) {
    return GestureDetector(
      onTap: () {
        widget.onTimeSlotTap?.call(date, TimeOfDay(hour: hour, minute: 0));
      },
      child: SizedBox(
        height: _hourHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: Text(
                  _formatHour(hour),
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                    left: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsOverlay(List<CalendarEvent> events, double totalHeight) {
    return Positioned(
      left: 70,
      right: 8,
      top: 0,
      bottom: 0,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: events.map((event) => _buildEventBlock(event, totalHeight)).toList(),
      ),
    );
  }

  Widget _buildEventBlock(CalendarEvent event, double totalHeight) {
    final startMinutes =
        (event.startTime.hour - _startHour) * 60 + event.startTime.minute;
    final endMinutes =
        (event.endTime.hour - _startHour) * 60 + event.endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    final top = ((startMinutes / 60) * _hourHeight).clamp(0.0, totalHeight);
    final remaining = totalHeight - top;
    final height = ((durationMinutes / 60) * _hourHeight).clamp(24.0, remaining);

    final eventColor = event.calendarColor != null
        ? Color(event.calendarColor!)
        : AppTheme.primaryColor;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border(
              left: BorderSide(color: eventColor, width: 4),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 40) ...[
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              if (event.location != null && height > 70) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    if (now.hour < _startHour || now.hour > _endHour) {
      return const SizedBox.shrink();
    }

    final minutesSinceStart = (now.hour - _startHour) * 60 + now.minute;
    final top = (minutesSinceStart / 60) * _hourHeight;

    return Positioned(
      top: top - 5,
      left: 55,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    if (_isToday(date)) {
      return 'Today, ${months[date.month - 1]} ${date.day}';
    }

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow, ${months[date.month - 1]} ${date.day}';
    }

    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatHour(int hour) {
    if (hour == 0 || hour == 24) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
