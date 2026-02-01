import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// CustomPainter for animated wave effect in water progress display
class WaterWavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color primaryColor;
  final Color secondaryColor;

  WaterWavePainter({
    required this.progress,
    required this.wavePhase,
    this.primaryColor = AppTheme.primaryColor,
    this.secondaryColor = AppTheme.primaryLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Create circular clip path
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // Background - light pink tint
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.backgroundColor,
          const Color(0xFFFFEBEE),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Calculate wave level (from bottom)
    final waveLevel = size.height - (size.height * progress.clamp(0.0, 1.0));

    // Draw secondary wave (behind)
    _drawWave(
      canvas,
      size,
      waveLevel + 8,
      wavePhase + math.pi,
      secondaryColor.withValues(alpha: 0.4),
      amplitude: 8,
      frequency: 1.5,
    );

    // Draw primary wave (front)
    _drawWave(
      canvas,
      size,
      waveLevel,
      wavePhase,
      primaryColor.withValues(alpha: 0.6),
      amplitude: 12,
      frequency: 2.0,
    );

    // Draw filled area below waves with gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.7),
          secondaryColor.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, waveLevel, size.width, size.height - waveLevel));

    final fillPath = Path();
    fillPath.moveTo(0, waveLevel);

    // Add wave shape to top of fill
    for (double x = 0; x <= size.width; x++) {
      final y = waveLevel +
          math.sin((x / size.width * 2 * math.pi * 2.0) + wavePhase) * 12;
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Draw circular border
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double baseY,
    double phase,
    Color color, {
    double amplitude = 10,
    double frequency = 2.0,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      final y = baseY +
          math.sin((x / size.width * 2 * math.pi * frequency) + phase) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
