import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Main progress card displaying workout timer and active session
class WorkoutProgressCard extends StatelessWidget {
  final int todayMinutes;
  final int todaySessions;
  final int todayCalories;
  final int weeklyGoal;
  final double progress;
  final double animationPhase;
  final double padding;
  final bool isTimerActive;
  final int timerSeconds;
  final WorkoutType? activeWorkoutType;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onStopWorkout;

  const WorkoutProgressCard({
    super.key,
    required this.todayMinutes,
    required this.todaySessions,
    required this.todayCalories,
    required this.weeklyGoal,
    required this.progress,
    required this.animationPhase,
    required this.padding,
    this.isTimerActive = false,
    this.timerSeconds = 0,
    this.activeWorkoutType,
    this.onStartWorkout,
    this.onStopWorkout,
  });

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getMotivationalMessage() {
    if (isTimerActive) {
      return 'Keep pushing! You\'re doing great!';
    } else if (progress >= 1.0) {
      return 'Weekly goal achieved! Outstanding!';
    } else if (progress >= 0.75) {
      return 'Almost there! Keep it up!';
    } else if (progress >= 0.5) {
      return 'Halfway through your weekly goal!';
    } else if (progress >= 0.25) {
      return 'Good start! Stay consistent!';
    } else {
      return 'Ready to start your workout?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring with timer
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _WorkoutProgressPainter(
                    progress: progress,
                    animationValue: animationPhase,
                    isActive: isTimerActive,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTimerActive ? Icons.fitness_center : Icons.play_circle_outline,
                      color: isTimerActive ? AppTheme.successColor : AppTheme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    // Timer or today's minutes
                    if (isTimerActive) ...[
                      Text(
                        _formatTime(timerSeconds),
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (activeWorkoutType != null)
                        Text(
                          activeWorkoutType!.name.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ] else ...[
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: todayMinutes),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        'minutes today',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                icon: Icons.repeat,
                value: '$todaySessions',
                label: 'Sessions',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.local_fire_department,
                value: '$todayCalories',
                label: 'Calories',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.flag,
                value: '$weeklyGoal',
                label: 'Goal (min)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Start/Stop button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isTimerActive ? onStopWorkout : onStartWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTimerActive ? AppTheme.errorColor : AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(isTimerActive ? Icons.stop : Icons.play_arrow),
              label: Text(
                isTimerActive ? 'Stop Workout' : 'Start Workout',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
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

class _WorkoutProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final bool isActive;

  _WorkoutProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    final strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isActive ? AppTheme.successColor : AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Animated pulse effect when active
    if (isActive) {
      final pulsePaint = Paint()
        ..color = AppTheme.successColor.withValues(alpha: 0.3 * (1 - animationValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (8 * animationValue);

      canvas.drawCircle(center, radius, pulsePaint);
    }

    // Decorative dots
    final dotPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final dotRadius = i % 3 == 0 ? 4.0 : 2.0;
      final dotCenter = Offset(
        center.dx + (radius + 20) * math.cos(angle),
        center.dy + (radius + 20) * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive;
  }
}
