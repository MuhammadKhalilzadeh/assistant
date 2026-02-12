import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class NutritionStatsCard extends StatelessWidget {
  final NutritionStats stats;
  final Animation<double> animation;

  const NutritionStatsCard({
    super.key,
    required this.stats,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Weekly Stats',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.trending_up,
                      iconColor: AppTheme.infoColor,
                      label: 'Avg Calories',
                      value:
                          '${(stats.weeklyAverageCalories * animation.value).round()}',
                      animation: animation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.local_fire_department,
                      iconColor: AppTheme.primaryColor,
                      label: 'Current Streak',
                      value:
                          '${(stats.currentStreak * animation.value).round()} days',
                      animation: animation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.emoji_events,
                      iconColor: AppTheme.warningColor,
                      label: 'Best Streak',
                      value:
                          '${(stats.bestStreak * animation.value).round()} days',
                      animation: animation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.check_circle_outline,
                      iconColor: AppTheme.successColor,
                      label: 'Goal Rate',
                      value:
                          '${(stats.goalCompletionRate * 100 * animation.value).round()}%',
                      animation: animation,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Animation<double> animation;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
