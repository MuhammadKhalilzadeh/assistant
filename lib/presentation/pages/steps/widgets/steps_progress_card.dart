import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/step_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'steps_progress_painter.dart';

/// Main progress card displaying animated circular progress and step stats
class StepsProgressCard extends StatelessWidget {
  final StepRecordModel? todaySteps;
  final int dailyGoal;
  final double progress;
  final double animationPhase;
  final double padding;

  const StepsProgressCard({
    super.key,
    required this.todaySteps,
    required this.dailyGoal,
    required this.progress,
    required this.animationPhase,
    required this.padding,
  });

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.toString();
  }

  String _getMotivationalMessage() {
    if (progress >= 1.0) {
      return 'Goal achieved! Outstanding effort!';
    } else if (progress >= 0.75) {
      return 'Almost there! Keep moving!';
    } else if (progress >= 0.5) {
      return 'Halfway through! Great progress!';
    } else if (progress >= 0.25) {
      return 'Good start! Every step counts!';
    } else {
      return 'Start your walking journey!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);
    final steps = todaySteps?.steps ?? 0;
    final distance = todaySteps?.distanceKm ?? 0.0;
    final calories = todaySteps?.caloriesBurned ?? 0;

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: StepsProgressPainter(
                    progress: progress,
                    animationValue: animationPhase,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    // Animated step count
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: steps),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          _formatNumber(value),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Text(
                      'of ${_formatNumber(dailyGoal)}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat(
                icon: Icons.straighten,
                value: '${distance.toStringAsFixed(1)} km',
                label: 'Distance',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.local_fire_department,
                value: '$calories',
                label: 'Calories',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.timer,
                value: '${(steps / 100).round()} min',
                label: 'Active',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? AppTheme.successColor
                    : progress >= 0.5
                        ? AppTheme.warningColor
                        : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Remaining text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                progress >= 1.0
                    ? 'Goal completed!'
                    : '${_formatNumber((dailyGoal - steps).clamp(0, dailyGoal))} steps to go',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Motivational message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getMotivationalMessage(),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
