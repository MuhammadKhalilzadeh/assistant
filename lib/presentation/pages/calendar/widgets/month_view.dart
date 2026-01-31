import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'day_cell.dart';
import 'event_item.dart';
import 'calendar_empty_state.dart';

/// Month grid view with swipe navigation
class MonthView extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final List<CalendarEventModel> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<CalendarEventModel>? onEventTap;
  final ValueChanged<CalendarEventModel>? onEventDelete;
  final VoidCallback? onAddEvent;

  const MonthView({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.events,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.onEventTap,
    this.onEventDelete,
    this.onAddEvent,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late PageController _pageController;
  static const int _initialPage = 1200; // ~100 years in each direction

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
        oldWidget.focusedMonth.month != widget.focusedMonth.month) {
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      final targetMonth = DateTime(widget.focusedMonth.year, widget.focusedMonth.month);
      final monthDiff = (targetMonth.year - currentMonth.year) * 12 +
          (targetMonth.month - currentMonth.month);
      final targetPage = _initialPage + monthDiff;

      if ((_pageController.page?.round() ?? _initialPage) != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  DateTime _getMonthForPage(int page) {
    final now = DateTime.now();
    final monthDiff = page - _initialPage;
    return DateTime(now.year, now.month + monthDiff);
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

  List<Color> _getEventColorsForDate(DateTime date) {
    return _getEventsForDate(date).map((event) {
      try {
        return Color(int.parse(event.color.replaceFirst('#', '0xFF')));
      } catch (_) {
        return AppTheme.primaryColor;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateEvents = _getEventsForDate(widget.selectedDate);

    return Column(
      children: [
        // Month grid with swipe
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              widget.onMonthChanged(_getMonthForPage(page));
            },
            itemBuilder: (context, page) {
              final month = _getMonthForPage(page);
              return _buildMonthGrid(month);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Events for selected date
        Expanded(
          child: _buildSelectedDateEvents(selectedDateEvents),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Start with Sunday
    final startWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    // Days from previous month
    final prevMonth = DateTime(month.year, month.month - 1);
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;

    final cells = <Widget>[];

    // Previous month trailing days
    for (var i = startWeekday - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      cells.add(_buildDayCell(date, false));
    }

    // Current month days
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      cells.add(_buildDayCell(date, true));
    }

    // Next month leading days
    final totalCells = cells.length;
    final remainingCells = (totalCells % 7 == 0) ? 0 : (7 - totalCells % 7);
    final nextMonth = DateTime(month.year, month.month + 1);
    for (var day = 1; day <= remainingCells; day++) {
      final date = DateTime(nextMonth.year, nextMonth.month, day);
      cells.add(_buildDayCell(date, false));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Day headers
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isCurrentMonth) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isSelected = date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;

    return DayCell(
      date: date,
      isSelected: isSelected,
      isToday: isToday,
      isCurrentMonth: isCurrentMonth,
      eventCount: _getEventsForDate(date).length,
      eventColors: _getEventColorsForDate(date),
      onTap: () => widget.onDateSelected(date),
    );
  }

  Widget _buildSelectedDateEvents(List<CalendarEventModel> events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _formatSelectedDate(widget.selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${events.length} event${events.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? DateEmptyState(
                    date: widget.selectedDate,
                    onAddEvent: widget.onAddEvent,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventItem(
                        event: event,
                        onTap: () => widget.onEventTap?.call(event),
                        onDelete: () => widget.onEventDelete?.call(event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today, ${months[date.month - 1]} ${date.day}';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow, ${months[date.month - 1]} ${date.day}';
    }

    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }
}
