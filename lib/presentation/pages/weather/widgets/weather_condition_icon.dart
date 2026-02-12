import 'dart:math' as math;
import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class WeatherConditionIcon extends StatefulWidget {
  final WeatherConditionType condition;
  final double size;
  final bool animate;

  const WeatherConditionIcon({
    super.key,
    required this.condition,
    this.size = 64,
    this.animate = true,
  });

  @override
  State<WeatherConditionIcon> createState() => _WeatherConditionIconState();
}

class _WeatherConditionIconState extends State<WeatherConditionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WeatherConditionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WeatherIconPainter(
              condition: widget.condition,
              animationValue: _controller.value,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _WeatherIconPainter extends CustomPainter {
  final WeatherConditionType condition;
  final double animationValue;

  _WeatherIconPainter({
    required this.condition,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition) {
      case WeatherConditionType.sunny:
        _paintSunny(canvas, size);
        break;
      case WeatherConditionType.cloudy:
        _paintCloudy(canvas, size);
        break;
      case WeatherConditionType.rainy:
        _paintRainy(canvas, size);
        break;
      case WeatherConditionType.stormy:
        _paintStormy(canvas, size);
        break;
      case WeatherConditionType.snowy:
        _paintSnowy(canvas, size);
        break;
      case WeatherConditionType.partlyCloudy:
        _paintPartlyCloudy(canvas, size);
        break;
    }
  }

  void _paintSunny(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;

    // Sun circle with red accent
    final sunPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sunPaint);

    // Sun rays with rotation animation
    final rayPaint = Paint()
      ..color = AppTheme.primaryLight
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final rayCount = 8;
    final rayLength = size.width * 0.15;
    final rayStart = radius + size.width * 0.05;

    for (int i = 0; i < rayCount; i++) {
      final angle =
          (i * 2 * math.pi / rayCount) + (animationValue * 2 * math.pi);
      final start = Offset(
        center.dx + rayStart * math.cos(angle),
        center.dy + rayStart * math.sin(angle),
      );
      final end = Offset(
        center.dx + (rayStart + rayLength) * math.cos(angle),
        center.dy + (rayStart + rayLength) * math.sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _paintCloudy(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Animate cloud drift
    final drift = math.sin(animationValue * 2 * math.pi) * size.width * 0.05;

    _drawCloud(canvas, size, Offset(drift, 0), cloudPaint);
  }

  void _drawCloud(Canvas canvas, Size size, Offset offset, Paint paint) {
    final path = Path();
    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy;

    // Main cloud body with circles
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: size.width * 0.2,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(centerX - size.width * 0.18, centerY + size.width * 0.05),
      radius: size.width * 0.15,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(centerX + size.width * 0.18, centerY + size.width * 0.05),
      radius: size.width * 0.15,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(centerX - size.width * 0.08, centerY - size.width * 0.1),
      radius: size.width * 0.15,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(centerX + size.width * 0.1, centerY - size.width * 0.08),
      radius: size.width * 0.13,
    ));

    canvas.drawPath(path, paint);
  }

  void _paintRainy(Canvas canvas, Size size) {
    // Draw cloud
    final cloudPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    _drawCloud(canvas, size, Offset(0, -size.height * 0.1), cloudPaint);

    // Draw rain drops with primary color accent
    final rainPaint = Paint()
      ..color = AppTheme.infoColor.withValues(alpha: 0.8)
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    final dropCount = 5;
    for (int i = 0; i < dropCount; i++) {
      final xOffset = (i - dropCount / 2) * size.width * 0.12;
      final yBase = size.height * 0.55;
      final dropY = (animationValue + i * 0.2) % 1.0;
      final y = yBase + dropY * size.height * 0.35;

      canvas.drawLine(
        Offset(size.width / 2 + xOffset, y),
        Offset(size.width / 2 + xOffset - size.width * 0.02, y + size.height * 0.08),
        rainPaint,
      );
    }
  }

  void _paintStormy(Canvas canvas, Size size) {
    // Draw dark cloud
    final cloudPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    _drawCloud(canvas, size, Offset(0, -size.height * 0.1), cloudPaint);

    // Lightning flash effect with primary color
    final flashOpacity = ((math.sin(animationValue * 8 * math.pi) + 1) / 2);
    if (flashOpacity > 0.7) {
      final lightningPaint = Paint()
        ..color = AppTheme.warningColor.withValues(alpha: flashOpacity)
        ..strokeWidth = size.width * 0.04
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.5, size.height * 0.45);
      path.lineTo(size.width * 0.42, size.height * 0.6);
      path.lineTo(size.width * 0.52, size.height * 0.6);
      path.lineTo(size.width * 0.45, size.height * 0.85);

      canvas.drawPath(path, lightningPaint);
    }

    // Rain
    final rainPaint = Paint()
      ..color = AppTheme.infoColor.withValues(alpha: 0.7)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final xOffset = (i - 1.5) * size.width * 0.15;
      final dropY = (animationValue + i * 0.25) % 1.0;
      final y = size.height * 0.55 + dropY * size.height * 0.35;

      canvas.drawLine(
        Offset(size.width / 2 + xOffset, y),
        Offset(size.width / 2 + xOffset - size.width * 0.02, y + size.height * 0.06),
        rainPaint,
      );
    }
  }

  void _paintSnowy(Canvas canvas, Size size) {
    // Draw cloud
    final cloudPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    _drawCloud(canvas, size, Offset(0, -size.height * 0.1), cloudPaint);

    // Draw snowflakes with subtle primary tint
    final snowPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final flakeCount = 6;
    for (int i = 0; i < flakeCount; i++) {
      final xOffset = (i - flakeCount / 2) * size.width * 0.1 +
          math.sin((animationValue + i * 0.3) * 2 * math.pi) * size.width * 0.05;
      final yBase = size.height * 0.5;
      final fallProgress = (animationValue + i * 0.15) % 1.0;
      final y = yBase + fallProgress * size.height * 0.4;

      canvas.drawCircle(
        Offset(size.width / 2 + xOffset, y),
        size.width * 0.025,
        snowPaint,
      );
    }
  }

  void _paintPartlyCloudy(Canvas canvas, Size size) {
    // Draw sun behind cloud with primary color
    final sunCenter = Offset(size.width * 0.65, size.height * 0.35);
    final sunRadius = size.width * 0.18;

    final sunPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.8)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    final visibleRays = [0, 1, 7]; // Only draw rays not behind cloud
    final rayLength = size.width * 0.1;
    final rayStart = sunRadius + size.width * 0.03;

    for (int i in visibleRays) {
      final angle =
          (i * 2 * math.pi / 8) + (animationValue * 2 * math.pi * 0.5);
      final start = Offset(
        sunCenter.dx + rayStart * math.cos(angle),
        sunCenter.dy + rayStart * math.sin(angle),
      );
      final end = Offset(
        sunCenter.dx + (rayStart + rayLength) * math.cos(angle),
        sunCenter.dy + (rayStart + rayLength) * math.sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }

    // Draw cloud in front
    final cloudPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final drift = math.sin(animationValue * 2 * math.pi) * size.width * 0.02;
    _drawCloud(
      canvas,
      size,
      Offset(-size.width * 0.1 + drift, size.height * 0.1),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WeatherIconPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.condition != condition;
  }
}
