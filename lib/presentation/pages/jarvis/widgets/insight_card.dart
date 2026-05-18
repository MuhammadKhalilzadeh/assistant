import 'package:assistant/data/services/jarvis_insights_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A card displaying a cross-domain insight with trend data.
class InsightCard extends StatelessWidget {
  final SmartInsight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = insight.trend == 'up'
        ? AppTheme.successColor
        : (insight.trend == 'down' ? AppTheme.warningColor : AppTheme.textTertiary);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with colored background
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _resolveIcon(insight.icon),
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        insight.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${insight.trend == 'up' ? '\u2191' : '\u2193'} ${insight.delta.round()}%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insight.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'bedtime' => Icons.bedtime_outlined,
      'self_improvement' => Icons.self_improvement_outlined,
      'emoji_emotions' => Icons.emoji_emotions_outlined,
      'directions_walk' => Icons.directions_walk_outlined,
      'phone_android' => Icons.phone_android_outlined,
      'water_drop' => Icons.water_drop_outlined,
      'event' => Icons.event_outlined,
      'timer' => Icons.timer_outlined,
      'fitness_center' => Icons.fitness_center_outlined,
      _ => Icons.insights_outlined,
    };
  }
}
