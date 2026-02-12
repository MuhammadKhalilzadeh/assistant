import 'package:flutter/material.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'day_cell.dart';
import 'mini_calendar.dart';

/// Month grid view with inline month navigation, swipe, and events panel
class MonthView extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<CalendarEvent>? onEventTap;
  final ValueChanged<CalendarEvent>? onEventDelete;
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
  static const int _initialPage = 1200;

  static const int _crossAxisCount = 7;
  static const double _crossAxisSpacing = 2.0;
  static const double _mainAxisSpacing = 2.0;
  static const double _gridHorizontalPadding = 16.0;
  static const double _dayNamesHeight = 24.0;
  static const double _childAspectRatio = 1.5;
  static const int _maxRows = 6;

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

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year, event.startTime.month, event.startTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate == targetDate;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Color> _getEventColorsForDate(DateTime date) {
    return _getEventsForDate(date).map((event) {
      if (event.calendarColor != null) {
        return Color(event.calendarColor!);
      }
      return AppTheme.primaryColor;
    }).toList();
  }

  double _calculateGridHeight(double maxWidth) {
    final gridWidth = maxWidth - _gridHorizontalPadding;
    final totalSpacing = _crossAxisSpacing * (_crossAxisCount - 1);
    final cellWidth = (gridWidth - totalSpacing) / _crossAxisCount;
    final cellHeight = cellWidth / _childAspectRatio;
    return _dayNamesHeight +
        (_maxRows * cellHeight) +
        ((_maxRows - 1) * _mainAxisSpacing);
  }

  void _previousMonth() {
    final newMonth = DateTime(widget.focusedMonth.year, widget.focusedMonth.month - 1);
    widget.onMonthChanged(newMonth);
  }

  void _nextMonth() {
    final newMonth = DateTime(widget.focusedMonth.year, widget.focusedMonth.month + 1);
    widget.onMonthChanged(newMonth);
  }

  Future<void> _openMiniCalendar() async {
    final result = await MiniCalendar.show(
      context,
      selectedDate: widget.selectedDate,
      focusedMonth: widget.focusedMonth,
    );

    if (result != null) {
      widget.onDateSelected(result);
      widget.onMonthChanged(DateTime(result.year, result.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateEvents = _getEventsForDate(widget.selectedDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridHeight = _calculateGridHeight(constraints.maxWidth);

        return Column(
          children: [
            // Inline month navigation header
            _buildMonthNavHeader(),
            // Month grid with swipe
            SizedBox(
              height: gridHeight,
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
            // Events panel
            Expanded(
              child: _buildEventsPanel(selectedDateEvents),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthNavHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          _NavButton(icon: Icons.chevron_left, onPressed: _previousMonth),
          Expanded(
            child: GestureDetector(
              onTap: _openMiniCalendar,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatMonth(widget.focusedMonth),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          _NavButton(icon: Icons.chevron_right, onPressed: _nextMonth),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    final prevMonth = DateTime(month.year, month.month - 1);
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;

    final cells = <Widget>[];

    for (var i = startWeekday - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      cells.add(_buildDayCell(date, false));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      cells.add(_buildDayCell(date, true));
    }

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
          // Day name headers
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Day cells grid
          Expanded(
            child: GridView.count(
              crossAxisCount: _crossAxisCount,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: _childAspectRatio,
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _crossAxisSpacing,
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

  // ─── Events Panel ───────────────────────────────────────────

  Widget _buildEventsPanel(List<CalendarEvent> events) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Date header with event count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatSelectedDate(widget.selectedDate),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: events.isNotEmpty
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length} event${events.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: events.isNotEmpty
                          ? AppTheme.primaryColor
                          : AppTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onAddEvent != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onAddEvent,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          // Events list or empty state
          Expanded(
            child: events.isEmpty
                ? _buildCompactEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildCompactEventRow(events[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEventRow(CalendarEvent event) {
    final eventColor = event.calendarColor != null
        ? Color(event.calendarColor!)
        : AppTheme.primaryColor;

    return Dismissible(
      key: Key('${event.calendarId}_${event.eventId ?? event.title}'),
      direction: widget.onEventDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
      ),
      onDismissed: (_) => widget.onEventDelete?.call(event),
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: eventColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: eventColor, width: 3),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                child: Text(
                  event.isAllDay ? 'All day' : _formatTime(event.startTime),
                  style: TextStyle(
                    color: event.isAllDay ? eventColor : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (event.location != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available,
            size: 32,
            color: AppTheme.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'No events',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap + to add one',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: 22),
        ),
      ),
    );
  }
}
