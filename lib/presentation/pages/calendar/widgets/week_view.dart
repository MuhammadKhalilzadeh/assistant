import 'package:flutter/material.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'calendar_empty_state.dart';

/// Week timeline view with swipe navigation — tracks page index in state
class WeekView extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedWeek;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<CalendarEvent>? onEventTap;
  final Function(DateTime, TimeOfDay)? onTimeSlotTap;

  const WeekView({
    super.key,
    required this.selectedDate,
    required this.focusedWeek,
    required this.events,
    required this.onDateSelected,
    required this.onWeekChanged,
    this.onEventTap,
    this.onTimeSlotTap,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late PageController _pageController;
  late ScrollController _scrollController;
  static const int _initialPage = 520;
  static const double _hourHeight = 60.0;
  static const int _startHour = 6;
  static const int _endHour = 23;

  // Track current page in state instead of reading .page during build
  int _currentPage = _initialPage;

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
    final scrollOffset = ((now.hour - _startHour) * _hourHeight +
        (now.minute / 60) * _hourHeight).clamp(0.0, double.infinity);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  DateTime _getWeekStartForPage(int page) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekDiff = page - _initialPage;
    return DateTime(
      currentWeekStart.year,
      currentWeekStart.month,
      currentWeekStart.day + (weekDiff * 7),
    );
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year, event.startTime.month, event.startTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate == targetDate;
    }).toList();
  }

  bool _hasAnyEventsThisWeek(DateTime weekStart) {
    final days = _getWeekDays(weekStart);
    return days.any((d) => _getEventsForDate(d).isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStartForPage(_currentPage);
    final selectedDayEvents = _getEventsForDate(widget.selectedDate)
        .where((e) => !e.isAllDay)
        .toList();

    return Column(
      children: [
        // Week day headers (swipeable)
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              widget.onWeekChanged(_getWeekStartForPage(page));
            },
            itemBuilder: (context, page) {
              final ws = _getWeekStartForPage(page);
              return _buildWeekHeader(ws);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Timeline or empty state
        Expanded(
          child: !_hasAnyEventsThisWeek(weekStart) && selectedDayEvents.isEmpty
              ? DateEmptyState(date: widget.selectedDate)
              : _buildTimeline(),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(DateTime weekStart) {
    final days = _getWeekDays(weekStart);
    final today = DateTime.now();

    return Row(
      children: [
        const SizedBox(width: 50),
        ...days.map((date) {
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final hasEvents = _getEventsForDate(date).isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : isToday
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: isToday && !isSelected
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                  boxShadow: isSelected ? AppTheme.cardShadow : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (hasEvents)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeline() {
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Hour rows
            Column(
              children: List.generate(_endHour - _startHour + 1, (index) {
                final hour = _startHour + index;
                return _buildHourRow(hour);
              }),
            ),
            // Event blocks (clipped)
            _buildEventsOverlay(),
            // Current time indicator
            _buildCurrentTimeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    return SizedBox(
      height: _hourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Text(
                _formatHour(hour),
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
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
                  top: BorderSide(color: AppTheme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final weekStart = _getWeekStartForPage(_currentPage);
                        final date = weekStart.add(Duration(days: dayIndex));
                        widget.onTimeSlotTap?.call(date, TimeOfDay(hour: hour, minute: 0));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.cardColor,
                              width: dayIndex == 0 ? 0 : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsOverlay() {
    final weekStart = _getWeekStartForPage(_currentPage);
    final days = _getWeekDays(weekStart);
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return Positioned(
      left: 50,
      right: 0,
      top: 0,
      bottom: 0,
      child: ClipRect(
        child: Row(
          children: days.map((date) {
            final dayEvents = _getEventsForDate(date)
                .where((e) => !e.isAllDay)
                .toList();

            return Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: dayEvents.map((event) {
                  return _buildEventBlock(event, totalHeight);
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventBlock(CalendarEvent event, double totalHeight) {
    final startMinutes = (event.startTime.hour - _startHour) * 60 + event.startTime.minute;
    final endMinutes = (event.endTime.hour - _startHour) * 60 + event.endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    final top = ((startMinutes / 60) * _hourHeight).clamp(0.0, totalHeight);
    final height = ((durationMinutes / 60) * _hourHeight).clamp(20.0, totalHeight - top);

    final eventColor = event.calendarColor != null
        ? Color(event.calendarColor!)
        : AppTheme.primaryColor;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(color: eventColor, width: 3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 40 && event.location != null)
                Text(
                  event.location!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final weekStart = _getWeekStartForPage(_currentPage);
    final weekEnd = weekStart.add(const Duration(days: 7));

    if (now.isBefore(weekStart) ||
        now.isAfter(weekEnd) ||
        now.hour < _startHour ||
        now.hour > _endHour) {
      return const SizedBox.shrink();
    }

    final minutesSinceStart = (now.hour - _startHour) * 60 + now.minute;
    final top = (minutesSinceStart / 60) * _hourHeight;

    return Positioned(
      top: top - 5,
      left: 48,
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
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0 || hour == 24) return '12a';
    if (hour == 12) return '12p';
    if (hour < 12) return '${hour}a';
    return '${hour - 12}p';
  }
}
