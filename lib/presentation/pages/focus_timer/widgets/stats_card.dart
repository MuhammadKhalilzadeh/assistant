import 'package:flutter/material.dart';
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                "Today's Stats",
                style: TextStyle(
                  color: Colors.white,
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
                  iconColor: _getAccentColor(),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.check_circle_rounded,
                  value: sessionsToday.toString(),
                  label: 'Sessions',
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
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

  Color _getAccentColor() {
    switch (timerMode) {
      case TimerMode.focus:
        return Colors.white;
      case TimerMode.shortBreak:
        return const Color(0xFF10B981);
      case TimerMode.longBreak:
        return const Color(0xFFEC4899);
    }
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
            color: iconColor.withValues(alpha: 0.2),
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
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
