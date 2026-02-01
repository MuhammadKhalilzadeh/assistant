import 'package:flutter/material.dart';
import 'circular_progress_painter.dart';

class CaloriesProgressCard extends StatelessWidget {
  final int currentCalories;
  final int goalCalories;
  final Animation<double> animation;

  const CaloriesProgressCard({
    super.key,
    required this.currentCalories,
    required this.goalCalories,
    required this.animation,
  });

  Color _getProgressColor(double progress) {
    if (progress > 1.0) {
      return Colors.red.shade400;
    } else if (progress >= 0.8) {
      return Colors.amber.shade400;
    }
    return Colors.green.shade400;
  }

  String _getMotivationalMessage(double progress) {
    if (progress > 1.0) {
      return 'You\'ve exceeded your goal';
    } else if (progress >= 0.8 && progress <= 1.0) {
      return 'Great job! Almost at your goal';
    } else if (progress >= 0.5) {
      return 'Halfway there, keep going!';
    } else if (progress > 0) {
      return 'Good start to the day!';
    }
    return 'Start logging your meals';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedProgress =
            (currentCalories / goalCalories) * animation.value;
        final animatedCalories = (currentCalories * animation.value).round();
        final remaining = (goalCalories - animatedCalories).clamp(0, goalCalories);
        final progressColor = _getProgressColor(animatedProgress);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: CircularProgressPainter(
                        progress: animatedProgress.clamp(0.0, 1.5),
                        progressColor: progressColor,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        strokeWidth: 14,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$animatedCalories',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'of $goalCalories cal',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Goal',
                    '$goalCalories',
                    Icons.flag_outlined,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  _buildStatItem(
                    'Remaining',
                    '$remaining',
                    Icons.trending_down_outlined,
                    color: progressColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      animatedProgress > 1.0
                          ? Icons.warning_amber_rounded
                          : Icons.emoji_emotions_outlined,
                      color: progressColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMotivationalMessage(animatedProgress),
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Colors.white.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
