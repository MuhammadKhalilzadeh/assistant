import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import '../focus_timer_page.dart';

/// Statistics overview card showing today's focus time and sessions
class StatsCard extends StatelessWidget {
  final int sessionsToday;
  final TimerMode timerMode;

  const StatsCard({
    super.key,
    required this.sessionsToday,
    required this.timerMode,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = sessionsToday * 25;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                "Today's Stats",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.timer_rounded,
                  value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                  label: 'Focus Time',
                  iconColor: AppTheme.primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_rounded,
                  value: sessionsToday.toString(),
                  label: 'Sessions',
                  iconColor: AppTheme.successColor,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.stars_rounded,
                  value: '${sessionsToday * 10}',
                  label: 'Points',
                  iconColor: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
