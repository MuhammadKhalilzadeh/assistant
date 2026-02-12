import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Main progress card displaying current heart rate with pulsing animation
class HeartRateProgressCard extends StatelessWidget {
  final int? currentBpm;
  final HeartRateZone? currentZone;
  final int targetRestingBpm;
  final double animationPhase;
  final double padding;
  final List<int> quickBpmOptions;
  final Function(int) onQuickAdd;

  const HeartRateProgressCard({
    super.key,
    required this.currentBpm,
    required this.currentZone,
    required this.targetRestingBpm,
    required this.animationPhase,
    required this.padding,
    required this.quickBpmOptions,
    required this.onQuickAdd,
  });

  Color _getZoneColor(HeartRateZone? zone) {
    switch (zone) {
      case HeartRateZone.resting:
        return AppTheme.infoColor;
      case HeartRateZone.warmUp:
        return AppTheme.successColor;
      case HeartRateZone.fatBurn:
        return AppTheme.warningColor;
      case HeartRateZone.cardio:
        return const Color(0xFFFF6B35);
      case HeartRateZone.peak:
        return AppTheme.errorColor;
      case null:
        return AppTheme.textTertiary;
    }
  }

  String _getZoneLabel(HeartRateZone? zone) {
    switch (zone) {
      case HeartRateZone.resting:
        return 'Resting';
      case HeartRateZone.warmUp:
        return 'Warm Up';
      case HeartRateZone.fatBurn:
        return 'Fat Burn';
      case HeartRateZone.cardio:
        return 'Cardio';
      case HeartRateZone.peak:
        return 'Peak';
      case null:
        return 'No Data';
    }
  }

  String _getMotivationalMessage() {
    if (currentBpm == null) {
      return 'Log your first heart rate reading!';
    } else if (currentZone == HeartRateZone.resting) {
      return 'Great! You\'re well rested.';
    } else if (currentZone == HeartRateZone.warmUp) {
      return 'Light activity zone. Keep moving!';
    } else if (currentZone == HeartRateZone.fatBurn) {
      return 'Optimal fat burning zone!';
    } else if (currentZone == HeartRateZone.cardio) {
      return 'Building cardiovascular endurance!';
    } else if (currentZone == HeartRateZone.peak) {
      return 'Maximum effort! Take breaks as needed.';
    }
    return 'Track your heart health!';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);
    final zoneColor = _getZoneColor(currentZone);

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring with heart rate display
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _HeartRateProgressPainter(
                    bpm: currentBpm ?? 0,
                    maxBpm: 200,
                    zoneColor: zoneColor,
                    animationValue: animationPhase,
                  ),
                ),
                // Center content with pulsing heart
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing heart icon
                    Transform.scale(
                      scale: 1.0 + (0.15 * math.sin(animationPhase * 2 * math.pi)),
                      child: Icon(
                        Icons.favorite,
                        color: zoneColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // BPM display
                    if (currentBpm != null) ...[
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: currentBpm!),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        'BPM',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '--',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'BPM',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Zone badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: zoneColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: zoneColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getZoneLabel(currentZone),
                  style: TextStyle(
                    color: zoneColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick BPM buttons
          Text(
            'Quick Log',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: quickBpmOptions.map((bpm) {
              final buttonZone = _calculateZone(bpm);
              final buttonColor = _getZoneColor(buttonZone);
              return InkWell(
                onTap: () => onQuickAdd(bpm),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: buttonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: buttonColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$bpm',
                    style: TextStyle(
                      color: buttonColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Motivational message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getMotivationalMessage(),
              style: TextStyle(
                color: AppTheme.errorColor,
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

  HeartRateZone _calculateZone(int bpm) {
    if (bpm < 60) return HeartRateZone.resting;
    if (bpm < 100) return HeartRateZone.warmUp;
    if (bpm < 140) return HeartRateZone.fatBurn;
    if (bpm < 170) return HeartRateZone.cardio;
    return HeartRateZone.peak;
  }
}

class _HeartRateProgressPainter extends CustomPainter {
  final int bpm;
  final int maxBpm;
  final Color zoneColor;
  final double animationValue;

  _HeartRateProgressPainter({
    required this.bpm,
    required this.maxBpm,
    required this.zoneColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    final strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = zoneColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc based on BPM
    final progress = (bpm / maxBpm).clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..color = zoneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Pulsing effect
    final pulseScale = 0.3 * math.sin(animationValue * 2 * math.pi).abs();
    final pulsePaint = Paint()
      ..color = zoneColor.withValues(alpha: 0.2 * (1 - pulseScale))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + (6 * pulseScale);

    canvas.drawCircle(center, radius, pulsePaint);

    // Decorative dots
    final dotPaint = Paint()
      ..color = zoneColor.withValues(alpha: 0.3)
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
  bool shouldRepaint(covariant _HeartRateProgressPainter oldDelegate) {
    return oldDelegate.bpm != bpm ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.zoneColor != zoneColor;
  }
}
