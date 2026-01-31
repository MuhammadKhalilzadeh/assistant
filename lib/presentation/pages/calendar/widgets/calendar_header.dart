import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'mini_calendar.dart';

/// Month/week navigation header
class CalendarHeader extends StatefulWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarHeader({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _displayedMonth = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _displayedMonth = _formatMonth(widget.focusedMonth);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CalendarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
        oldWidget.focusedMonth.month != widget.focusedMonth.month) {
      _animateMonthChange();
    }
  }

  void _animateMonthChange() async {
    await _animationController.reverse();
    setState(() {
      _displayedMonth = _formatMonth(widget.focusedMonth);
    });
    await _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    final newMonth = DateTime(
      widget.focusedMonth.year,
      widget.focusedMonth.month - 1,
    );
    widget.onMonthChanged(newMonth);
  }

  void _nextMonth() {
    final newMonth = DateTime(
      widget.focusedMonth.year,
      widget.focusedMonth.month + 1,
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Previous month button
          _NavigationButton(
            icon: Icons.chevron_left,
            onPressed: _previousMonth,
          ),
          // Month/year display (tap to open mini calendar)
          Expanded(
            child: GestureDetector(
              onTap: _openMiniCalendar,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _displayedMonth,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Next month button
          _NavigationButton(
            icon: Icons.chevron_right,
            onPressed: _nextMonth,
          ),
        ],
      ),
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

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
