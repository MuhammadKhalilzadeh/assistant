import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Compact month picker shown in bottom sheet or dropdown
class MiniCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const MiniCalendar({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime selectedDate,
    required DateTime focusedMonth,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MiniCalendarSheet(
        selectedDate: selectedDate,
        focusedMonth: focusedMonth,
      ),
    );
  }

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.focusedMonth;
  }

  @override
  void didUpdateWidget(MiniCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth != widget.focusedMonth) {
      _focusedMonth = widget.focusedMonth;
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    widget.onMonthChanged(_focusedMonth);
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    widget.onMonthChanged(_focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return _buildCalendarGrid();
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;

    // Adjust for Sunday start (weekday is 1-7 with Monday=1)
    final leadingEmptyDays = startWeekday == 7 ? 0 : startWeekday;

    final days = <Widget>[];

    // Day names header
    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var name in dayNames) {
      days.add(
        Center(
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Leading empty cells
    for (var i = 0; i < leadingEmptyDays; i++) {
      days.add(const SizedBox.shrink());
    }

    // Day cells
    final today = DateTime.now();
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = widget.selectedDate.year == date.year &&
          widget.selectedDate.month == date.month &&
          widget.selectedDate.day == date.day;
      final isToday = today.year == date.year &&
          today.month == date.month &&
          today.day == date.day;

      days.add(
        GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontSize: 14,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            Text(
              _formatMonth(_focusedMonth),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1.2,
          children: days,
        ),
      ],
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _MiniCalendarSheet extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;

  const _MiniCalendarSheet({
    required this.selectedDate,
    required this.focusedMonth,
  });

  @override
  State<_MiniCalendarSheet> createState() => _MiniCalendarSheetState();
}

class _MiniCalendarSheetState extends State<_MiniCalendarSheet> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _focusedMonth = widget.focusedMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Date',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          MiniCalendar(
            selectedDate: _selectedDate,
            focusedMonth: _focusedMonth,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
            onMonthChanged: (month) {
              setState(() => _focusedMonth = month);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
