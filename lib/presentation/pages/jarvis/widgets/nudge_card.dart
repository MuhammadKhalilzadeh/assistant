import 'package:assistant/data/services/jarvis_insights_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A dismissible nudge banner shown on the Home and Jarvis tabs.
/// Each nudge has an icon, message, optional action button, and dismiss button.
class NudgeCard extends StatelessWidget {
  final Nudge nudge;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  const NudgeCard({
    super.key,
    required this.nudge,
    required this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _resolveIcon(nudge.icon),
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nudge.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          if (nudge.actionLabel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nudge.actionLabel!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'water_drop' => Icons.water_drop_outlined,
      'emoji_emotions' => Icons.emoji_emotions_outlined,
      'directions_walk' => Icons.directions_walk_outlined,
      'bedtime' => Icons.bedtime_outlined,
      'celebration' => Icons.celebration_outlined,
      'checklist' => Icons.checklist_outlined,
      'event' => Icons.event_outlined,
      'timer' => Icons.timer_outlined,
      'self_improvement' => Icons.self_improvement_outlined,
      'fitness_center' => Icons.fitness_center_outlined,
      _ => Icons.lightbulb_outline,
    };
  }
}
