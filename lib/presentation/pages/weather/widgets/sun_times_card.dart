import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunTimesCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final Animation<double>? animation;

  const SunTimesCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    this.animation,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    if (hour == 0) return '12:$minute AM';
    if (hour == 12) return '12:$minute PM';
    if (hour > 12) return '${hour - 12}:$minute PM';
    return '$hour:$minute AM';
  }

  String _getDaylightDuration() {
    final duration = sunset.difference(sunrise);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  double _getSunPosition() {
    final now = DateTime.now();
    if (now.isBefore(sunrise)) return 0.0;
    if (now.isAfter(sunset)) return 1.0;

    final totalMinutes = sunset.difference(sunrise).inMinutes;
    final elapsedMinutes = now.difference(sunrise).inMinutes;
    return elapsedMinutes / totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    Widget card = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sun Times',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Daylight: ${_getDaylightDuration()}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _SunArcPainter(
                sunPosition: _getSunPosition(),
                sunrise: sunrise,
                sunset: sunset,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLabel(Icons.wb_sunny_outlined, 'Sunrise', _formatTime(sunrise)),
              _buildTimeLabel(Icons.nights_stay_outlined, 'Sunset', _formatTime(sunset)),
            ],
          ),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation!),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildTimeLabel(IconData icon, String label, String time) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double sunPosition;
  final DateTime sunrise;
  final DateTime sunset;

  _SunArcPainter({
    required this.sunPosition,
    required this.sunrise,
    required this.sunset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.85;
    final arcHeight = size.height * 0.75;

    // Draw horizon line
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, baseY),
      Offset(size.width, baseY),
      horizonPaint,
    );

    final startX = size.width * 0.05;
    final endX = size.width * 0.95;
    final arcWidth = endX - startX;

    // Draw gradient arc
    final gradientShader = LinearGradient(
      colors: [
        Colors.orange.shade300,
        Colors.amber,
        Colors.orange.shade400,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gradientArcPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw dotted line for future path
    final futurePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pastPath = Path();
    final futurePath = Path();
    bool pastStarted = false;
    bool futureStarted = false;

    for (double t = 0; t <= 1; t += 0.01) {
      final x = startX + arcWidth * t;
      final y = baseY - arcHeight * math.sin(t * math.pi);

      if (t <= sunPosition) {
        if (!pastStarted) {
          pastPath.moveTo(x, y);
          pastStarted = true;
        } else {
          pastPath.lineTo(x, y);
        }
      } else {
        if (!futureStarted) {
          futurePath.moveTo(x, y);
          futureStarted = true;
        } else {
          futurePath.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(pastPath, gradientArcPaint);
    canvas.drawPath(futurePath, futurePaint);

    // Draw sun at current position
    if (sunPosition > 0 && sunPosition < 1) {
      final sunX = startX + arcWidth * sunPosition;
      final sunY = baseY - arcHeight * math.sin(sunPosition * math.pi);

      // Sun glow
      final glowPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(sunX, sunY), 16, glowPaint);

      // Sun
      final sunPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(sunX, sunY), 10, sunPaint);

      // Sun border
      final borderPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(sunX, sunY), 10, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.sunPosition != sunPosition;
  }
}
