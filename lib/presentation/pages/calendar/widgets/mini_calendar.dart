import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Compact month picker shown in a constrained bottom sheet
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
      isScrollControlled: true,
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
    final leadingEmptyDays = startWeekday == 7 ? 0 : startWeekday;

    final dayCells = <Widget>[];

    for (var i = 0; i < leadingEmptyDays; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    final today = DateTime.now();
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = widget.selectedDate.year == date.year &&
          widget.selectedDate.month == date.month &&
          widget.selectedDate.day == date.day;
      final isToday = today.year == date.year &&
          today.month == date.month &&
          today.day == date.day;

      dayCells.add(
        GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : isToday
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
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
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
            ),
            Text(
              _formatMonth(_focusedMonth),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Static day names row
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _DayNameLabel('S'),
              _DayNameLabel('M'),
              _DayNameLabel('T'),
              _DayNameLabel('W'),
              _DayNameLabel('T'),
              _DayNameLabel('F'),
              _DayNameLabel('S'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Grid of day cells
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1.2,
          children: dayCells,
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

class _DayNameLabel extends StatelessWidget {
  final String label;
  const _DayNameLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet wrapper for MiniCalendar with polished UI
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          const Text(
            'Select Date',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MiniCalendar(
              selectedDate: _selectedDate,
              focusedMonth: _focusedMonth,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
              onMonthChanged: (month) {
                setState(() => _focusedMonth = month);
              },
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
        ],
      ),
    );
  }
}
