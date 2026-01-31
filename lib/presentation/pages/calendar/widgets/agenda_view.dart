import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'event_item.dart';
import 'calendar_empty_state.dart';

/// Agenda list view grouped by date
class AgendaView extends StatefulWidget {
  final DateTime selectedDate;
  final List<CalendarEventModel> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEventModel>? onEventTap;
  final ValueChanged<CalendarEventModel>? onEventDelete;
  final VoidCallback? onAddEvent;

  const AgendaView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    this.onEventTap,
    this.onEventDelete,
    this.onAddEvent,
  });

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late ScrollController _scrollController;
  final Map<DateTime, GlobalKey> _dateKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<DateTime, List<CalendarEventModel>> _groupEventsByDate() {
    final grouped = <DateTime, List<CalendarEventModel>>{};

    for (final event in widget.events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }

    // Sort events within each date
    for (final date in grouped.keys) {
      grouped[date]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  List<DateTime> _getSortedDates(Map<DateTime, List<CalendarEventModel>> grouped) {
    final dates = grouped.keys.toList();
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupEventsByDate();
    final dates = _getSortedDates(grouped);

    if (dates.isEmpty) {
      return CalendarEmptyState(
        title: 'No upcoming events',
        subtitle: 'Your agenda is clear',
        icon: Icons.event_note,
        onAddEvent: widget.onAddEvent,
      );
    }

    // Find dates to show (starting from selected date or today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = widget.selectedDate.isBefore(today) ? widget.selectedDate : today;

    // Filter to show only dates >= startDate
    final visibleDates = dates.where((d) => !d.isBefore(startDate)).toList();

    if (visibleDates.isEmpty) {
      // Show past events if no future events
      return _buildAgendaList(dates, grouped);
    }

    return _buildAgendaList(visibleDates, grouped);
  }

  Widget _buildAgendaList(
    List<DateTime> dates,
    Map<DateTime, List<CalendarEventModel>> grouped,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final events = grouped[date]!;

        if (!_dateKeys.containsKey(date)) {
          _dateKeys[date] = GlobalKey();
        }

        return _buildDateSection(date, events, index);
      },
    );
  }

  Widget _buildDateSection(DateTime date, List<CalendarEventModel> events, int index) {
    final isToday = _isToday(date);
    final isSelected = _isSameDay(date, widget.selectedDate);

    return Column(
      key: _dateKeys[date],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header (sticky)
        GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.only(
              top: index == 0 ? 0 : 16,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(date.weekday),
                        style: TextStyle(
                          color: isToday
                              ? AppTheme.primaryColor
                              : Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isToday ? AppTheme.primaryColor : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateHeader(date),
                        style: TextStyle(
                          color: isToday
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${events.length} event${events.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        // Events for this date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: events.asMap().entries.map((entry) {
              final eventIndex = entry.key;
              final event = entry.value;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 200 + (eventIndex * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: EventItem(
                  event: event,
                  onTap: () => widget.onEventTap?.call(event),
                  onDelete: () => widget.onEventDelete?.call(event),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDateHeader(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (_isToday(date)) {
      return 'Today';
    }

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    // Show full date
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
