import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Custom painter for the circular steps progress indicator with animated ring
class StepsProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  StepsProgressPainter({
    required this.progress,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Color based on progress
    if (progress >= 1.0) {
      progressPaint.color = AppTheme.successColor;
    } else if (progress >= 0.5) {
      progressPaint.color = AppTheme.warningColor;
    } else {
      progressPaint.color = AppTheme.primaryColor;
    }

    // Add gradient effect for progress
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Animated glow effect at the end of progress
      if (animationValue > 0) {
        final glowPaint = Paint()
          ..color = progressPaint.color.withValues(alpha: 0.3 * (1 - animationValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20 + (8 * animationValue)
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        final glowSweep = sweepAngle * 0.1;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + sweepAngle - glowSweep,
          glowSweep,
          false,
          glowPaint,
        );
      }
    }

    // Inner decorative circle
    final innerPaint = Paint()
      ..color = AppTheme.cardColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 20, innerPaint);

    // Inner border
    final innerBorderPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 20, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant StepsProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue;
  }
}
