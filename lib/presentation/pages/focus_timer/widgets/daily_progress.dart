import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import '../focus_timer_page.dart';

/// Daily goal progress ring showing sessions completed vs goal
class DailyProgress extends StatelessWidget {
  final int completedSessions;
  final int goalSessions;
  final TimerMode timerMode;

  const DailyProgress({
    super.key,
    required this.completedSessions,
    required this.goalSessions,
    required this.timerMode,
  });

  double get _progress =>
      goalSessions > 0 ? (completedSessions / goalSessions).clamp(0.0, 1.0) : 0;

  int get _percentage => (_progress * 100).round();

  String get _motivationalMessage {
    if (completedSessions == 0) {
      return "Let's start your first session!";
    } else if (_progress < 0.25) {
      return "Great start! Keep going!";
    } else if (_progress < 0.5) {
      return "You're making progress!";
    } else if (_progress < 0.75) {
      return "Halfway there! Stay focused!";
    } else if (_progress < 1) {
      return "Almost at your goal!";
    } else {
      return "Daily goal achieved!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: value,
                    backgroundColor: AppTheme.textTertiary.withValues(alpha: 0.2),
                    progressColor: _getProgressColor(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_percentage%',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 20),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Goal',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedSessions of $goalSessions sessions',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _motivationalMessage,
                  style: TextStyle(
                    color: _progress >= 1 ? AppTheme.successColor : AppTheme.textTertiary,
                    fontSize: 12,
                    fontStyle: completedSessions >= goalSessions
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (_progress >= 1) {
      return AppTheme.successColor; // Green for completed
    }
    return AppTheme.primaryColor; // Red for in progress
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
