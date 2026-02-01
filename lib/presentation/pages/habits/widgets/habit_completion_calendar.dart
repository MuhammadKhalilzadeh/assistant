import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HabitCompletionCalendar extends StatefulWidget {
  final List<DateTime> completedDates;
  final int streak;
  final DateTime createdAt;

  const HabitCompletionCalendar({
    super.key,
    required this.completedDates,
    required this.streak,
    required this.createdAt,
  });

  @override
  State<HabitCompletionCalendar> createState() => _HabitCompletionCalendarState();
}

class _HabitCompletionCalendarState extends State<HabitCompletionCalendar> {
  late DateTime _displayMonth;
  late Set<DateTime> _completedDatesSet;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _completedDatesSet = widget.completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  @override
  void didUpdateWidget(HabitCompletionCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedDates != oldWidget.completedDates) {
      _completedDatesSet = widget.completedDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
    }
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        _displayMonth = nextMonth;
      });
    }
  }

  bool _isCompleted(DateTime date) {
    return _completedDatesSet.contains(DateTime(date.year, date.month, date.day));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today);
  }

  bool _isPartOfStreak(DateTime date) {
    if (widget.streak == 0) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if this date is within the current streak period
    for (int i = 0; i < widget.streak; i++) {
      final streakDate = today.subtract(Duration(days: i));
      if (date.year == streakDate.year &&
          date.month == streakDate.month &&
          date.day == streakDate.day) {
        return _isCompleted(date);
      }
    }
    return false;
  }

  Color _getDateColor(DateTime date) {
    if (_isFuture(date)) {
      return AppTheme.textTertiary.withValues(alpha: 0.1);
    }
    if (_isCompleted(date)) {
      if (_isPartOfStreak(date)) {
        return AppTheme.primaryColor; // Streak color - red
      }
      return AppTheme.successColor; // Completed color - green
    }
    return AppTheme.textTertiary.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Month navigation
          _buildMonthNavigation(),
          const SizedBox(height: 16),
          // Weekday headers
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final now = DateTime.now();
    final canGoNext = DateTime(_displayMonth.year, _displayMonth.month + 1, 1)
        .isBefore(DateTime(now.year, now.month + 1, 1));

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(
            Icons.chevron_left,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          '${monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: canGoNext ? _nextMonth : null,
          icon: Icon(
            Icons.chevron_right,
            color: canGoNext
                ? AppTheme.textSecondary
                : AppTheme.textTertiary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 36,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = _displayMonth;
    final lastDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);

    // Monday = 1, Sunday = 7 in Dart
    // We want Monday as first day, so offset is weekday - 1
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = firstWeekday - 1;

    final totalDays = lastDayOfMonth.day;
    final totalCells = startOffset + totalDays;
    final totalRows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > totalDays) {
                return const SizedBox(width: 36, height: 36);
              }

              final date = DateTime(
                _displayMonth.year,
                _displayMonth.month,
                dayNumber,
              );

              return _buildDateCell(date, dayNumber);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDateCell(DateTime date, int dayNumber) {
    final isToday = _isToday(date);
    final isCompleted = _isCompleted(date);
    final isFuture = _isFuture(date);
    final isStreak = _isPartOfStreak(date);
    final color = _getDateColor(date);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: isStreak && isCompleted
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                color: isFuture
                    ? AppTheme.textTertiary
                    : isCompleted
                        ? AppTheme.textOnPrimary
                        : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isToday || isCompleted
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            if (isStreak && isCompleted)
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.textOnPrimary,
                size: 10,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: AppTheme.successColor,
          label: 'Completed',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: AppTheme.primaryColor,
          label: 'Current Streak',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: AppTheme.textTertiary.withValues(alpha: 0.1),
          label: 'Missed',
          border: true,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool border = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border
                ? Border.all(color: AppTheme.textTertiary.withValues(alpha: 0.3))
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
