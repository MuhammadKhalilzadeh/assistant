import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'event_item.dart';
import 'calendar_empty_state.dart';

/// Day detail/timeline view
class DayView extends StatefulWidget {
  final DateTime selectedDate;
  final List<CalendarEventModel> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEventModel>? onEventTap;
  final ValueChanged<CalendarEventModel>? onEventDelete;
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
  static const int _initialPage = 3650; // ~10 years in each direction
  static const double _hourHeight = 60.0;
  static const int _startHour = 6;
  static const int _endHour = 23;

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

  List<CalendarEventModel> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate == targetDate;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date navigation header
        _buildDateHeader(),
        const SizedBox(height: 16),
        // All-day events
        _buildAllDayEvents(),
        // Timeline with swipe
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

  Widget _buildDateHeader() {
    final isToday = _isToday(widget.selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatDate(widget.selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Go to today',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
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
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildAllDayEvents() {
    final allDayEvents = _getEventsForDate(widget.selectedDate)
        .where((e) => e.isAllDay)
        .toList();

    if (allDayEvents.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Day',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...allDayEvents.map((event) => EventItem(
                event: event,
                isCompact: true,
                onTap: () => widget.onEventTap?.call(event),
              )),
        ],
      ),
    );
  }

  Widget _buildDayTimeline(DateTime date) {
    final events = _getEventsForDate(date).where((e) => !e.isAllDay).toList();
    final isToday = _isToday(date);

    if (events.isEmpty) {
      return DateEmptyState(
        date: date,
        onAddEvent: widget.onAddEvent,
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // Hour slots
          Column(
            children: List.generate(_endHour - _startHour + 1, (index) {
              final hour = _startHour + index;
              return _buildHourSlot(hour, date);
            }),
          ),
          // Events overlay
          _buildEventsOverlay(events),
          // Current time indicator
          if (isToday) _buildCurrentTimeIndicator(),
        ],
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
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
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
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsOverlay(List<CalendarEventModel> events) {
    return Positioned(
      left: 70,
      right: 8,
      top: 0,
      bottom: 0,
      child: Stack(
        children: events.map((event) => _buildEventBlock(event)).toList(),
      ),
    );
  }

  Widget _buildEventBlock(CalendarEventModel event) {
    final startMinutes =
        (event.startTime.hour - _startHour) * 60 + event.startTime.minute;
    final endMinutes =
        (event.endTime.hour - _startHour) * 60 + event.endTime.minute;
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
      left: 0,
      right: 0,
      height: height.clamp(50.0, double.infinity),
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: eventColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: eventColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              if (event.location != null && height > 80) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
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
                color: AppTheme.errorColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.errorColor.withValues(alpha: 0.4),
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
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

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
