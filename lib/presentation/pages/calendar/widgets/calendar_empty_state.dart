import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Empty state widget for when there are no events
class CalendarEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAddEvent;

  const CalendarEmptyState({
    super.key,
    this.title = 'No events scheduled',
    this.subtitle = 'Tap + to add an event',
    this.icon = Icons.event_available,
    this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddEvent != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Event'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for specific date
class DateEmptyState extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onAddEvent;

  const DateEmptyState({
    super.key,
    required this.date,
    this.onAddEvent,
  });

  String _formatDate(DateTime date) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return CalendarEmptyState(
      title: 'No events on ${_formatDate(date)}',
      subtitle: 'Your schedule is free',
      icon: Icons.event_available,
      onAddEvent: onAddEvent,
    );
  }
}

/// Empty state for week view
class WeekEmptyState extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback? onAddEvent;

  const WeekEmptyState({
    super.key,
    required this.weekStart,
    this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarEmptyState(
      title: 'No events this week',
      subtitle: 'Enjoy your free time',
      icon: Icons.calendar_today,
      onAddEvent: onAddEvent,
    );
  }
}
