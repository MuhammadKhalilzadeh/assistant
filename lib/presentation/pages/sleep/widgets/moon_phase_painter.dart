import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Custom painter for moon with stars visual effect and glow animation
class MoonPhasePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 for fill progress
  final double glowPhase; // 0.0 to 1.0 for glow animation cycle
  final Color accentColor;

  MoonPhasePainter({
    required this.progress,
    required this.glowPhase,
    this.accentColor = AppTheme.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background circle with subtle gradient
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.surfaceColor.withValues(alpha: 0.3),
          AppTheme.backgroundColor.withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw stars
    _drawStars(canvas, size, radius);

    // Draw progress arc (the "filled" part showing sleep progress)
    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            accentColor.withValues(alpha: 0.3),
            accentColor.withValues(alpha: 0.7),
            accentColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius - 4));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }

    // Draw track (unfilled portion)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = accentColor.withValues(alpha: 0.15)
      ..strokeCap = StrokeCap.round;

    if (progress < 1.0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 2 + 2 * math.pi * progress,
        2 * math.pi * (1 - progress),
        false,
        trackPaint,
      );
    }

    // Draw moon icon in center with glow
    _drawMoon(canvas, center, radius * 0.35, glowPhase);
  }

  void _drawStars(Canvas canvas, Size size, double radius) {
    final random = math.Random(42); // Fixed seed for consistent stars
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 15; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = radius * 0.5 + random.nextDouble() * radius * 0.35;
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = size.height / 2 + math.sin(angle) * distance;
      final starSize = 1.0 + random.nextDouble() * 1.5;

      // Twinkle effect based on glowPhase
      final twinkle = 0.3 + 0.7 * math.sin(glowPhase * 2 * math.pi + i * 0.5).abs();
      starPaint.color = Colors.white.withValues(alpha: twinkle * 0.6);

      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }
  }

  void _drawMoon(Canvas canvas, Offset center, double moonRadius, double phase) {
    // Calculate glow intensity
    final glowIntensity = 0.3 + 0.2 * math.sin(phase * 2 * math.pi);

    // Draw outer glow
    final glowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, moonRadius * 0.4);

    for (double i = 3; i > 0; i--) {
      glowPaint.color = accentColor.withValues(alpha: glowIntensity * (0.1 / i));
      canvas.drawCircle(center, moonRadius + moonRadius * i * 0.3, glowPaint);
    }

    // Draw moon body gradient
    final moonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.white,
          const Color(0xFFF5F5DC), // Beige/cream
          const Color(0xFFE5E0D5),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: moonRadius));

    canvas.drawCircle(center, moonRadius, moonPaint);

    // Draw moon craters for texture
    _drawCraters(canvas, center, moonRadius);

    // Draw crescent shadow for moon phase effect
    _drawCrescentShadow(canvas, center, moonRadius);
  }

  void _drawCraters(Canvas canvas, Offset center, double moonRadius) {
    final craterPaint = Paint()
      ..color = const Color(0xFFD4D0C8).withValues(alpha: 0.4);

    // Small craters
    final craters = [
      Offset(center.dx - moonRadius * 0.3, center.dy - moonRadius * 0.2),
      Offset(center.dx + moonRadius * 0.2, center.dy + moonRadius * 0.3),
      Offset(center.dx - moonRadius * 0.1, center.dy + moonRadius * 0.4),
      Offset(center.dx + moonRadius * 0.4, center.dy - moonRadius * 0.1),
    ];
    final sizes = [moonRadius * 0.12, moonRadius * 0.08, moonRadius * 0.06, moonRadius * 0.1];

    for (int i = 0; i < craters.length; i++) {
      canvas.drawCircle(craters[i], sizes[i], craterPaint);
    }
  }

  void _drawCrescentShadow(Canvas canvas, Offset center, double moonRadius) {
    // Create a subtle crescent shadow on the right side
    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCircle(center: center, radius: moonRadius));

    // Offset circle for crescent effect
    final offsetCenter = Offset(center.dx + moonRadius * 0.3, center.dy);
    final clipPath = Path();
    clipPath.addOval(Rect.fromCircle(center: offsetCenter, radius: moonRadius * 0.9));

    // Combine paths
    final shadowPaint = Paint()
      ..color = AppTheme.surfaceColor.withValues(alpha: 0.15);

    canvas.save();
    canvas.clipPath(shadowPath);
    canvas.drawPath(clipPath, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MoonPhasePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowPhase != glowPhase ||
        oldDelegate.accentColor != accentColor;
  }
}
