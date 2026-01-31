import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Week timeline view with swipe navigation
class WeekView extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedWeek;
  final List<CalendarEventModel> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<CalendarEventModel>? onEventTap;
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
  static const int _initialPage = 520; // ~10 years in each direction
  static const double _hourHeight = 60.0;
  static const int _startHour = 6;
  static const int _endHour = 23;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _scrollController = ScrollController();

    // Scroll to current time on init
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

  List<CalendarEventModel> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate == targetDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Week day headers with swipe
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              widget.onWeekChanged(_getWeekStartForPage(page));
            },
            itemBuilder: (context, page) {
              final weekStart = _getWeekStartForPage(page);
              return _buildWeekHeader(weekStart);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Timeline
        Expanded(
          child: _buildTimeline(),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(DateTime weekStart) {
    final days = _getWeekDays(weekStart);
    final today = DateTime.now();

    return Row(
      children: [
        const SizedBox(width: 50), // Space for time column
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
                      ? Colors.white
                      : isToday
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
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
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white.withValues(alpha: 0.7),
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
    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // Hour slots
          Column(
            children: List.generate(_endHour - _startHour + 1, (index) {
              final hour = _startHour + index;
              return _buildHourRow(hour);
            }),
          ),
          // Events overlay
          _buildEventsOverlay(),
          // Current time indicator
          _buildCurrentTimeIndicator(),
        ],
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
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
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
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final weekStart = _getWeekStartForPage(
                          _pageController.page?.round() ?? _initialPage,
                        );
                        final date = weekStart.add(Duration(days: dayIndex));
                        widget.onTimeSlotTap?.call(date, TimeOfDay(hour: hour, minute: 0));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.white.withValues(alpha: 0.05),
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
    final weekStart = _getWeekStartForPage(
      _pageController.page?.round() ?? _initialPage,
    );
    final days = _getWeekDays(weekStart);

    return Positioned(
      left: 50,
      right: 0,
      top: 0,
      bottom: 0,
      child: Row(
        children: days.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final date = entry.value;
          final dayEvents = _getEventsForDate(date)
              .where((e) => !e.isAllDay)
              .toList();

          return Expanded(
            child: Stack(
              children: dayEvents.map((event) {
                return _buildEventBlock(event, dayIndex);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventBlock(CalendarEventModel event, int dayIndex) {
    final startMinutes = (event.startTime.hour - _startHour) * 60 + event.startTime.minute;
    final endMinutes = (event.endTime.hour - _startHour) * 60 + event.endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    final top = (startMinutes / 60) * _hourHeight;
    final height = (durationMinutes / 60) * _hourHeight;

    Color eventColor;
    try {
      eventColor = Color(int.parse(event.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      eventColor = AppTheme.primaryColor;
    }

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height.clamp(24.0, double.infinity),
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: eventColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: eventColor.withValues(alpha: 0.3),
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
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 40 && event.location != null)
                Text(
                  event.location!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
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
    final weekStart = _getWeekStartForPage(
      _pageController.page?.round() ?? _initialPage,
    );
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Only show if current time is in this week and within hour range
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
              color: AppTheme.errorColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorColor.withValues(alpha: 0.4),
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
                    AppTheme.errorColor,
                    AppTheme.errorColor.withValues(alpha: 0),
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
