import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

class MacroBreakdownCard extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final Animation<double> animation;

  const MacroBreakdownCard({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Macros',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroRing(
                    label: 'Protein',
                    current: (protein * animation.value).round(),
                    goal: proteinGoal,
                    color: AppTheme.primaryColor,
                    progress: (protein / proteinGoal) * animation.value,
                  ),
                  _MacroRing(
                    label: 'Carbs',
                    current: (carbs * animation.value).round(),
                    goal: carbsGoal,
                    color: AppTheme.infoColor,
                    progress: (carbs / carbsGoal) * animation.value,
                  ),
                  _MacroRing(
                    label: 'Fat',
                    current: (fat * animation.value).round(),
                    goal: fatGoal,
                    color: AppTheme.warningColor,
                    progress: (fat / fatGoal) * animation.value,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  final double progress;

  const _MacroRing({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(70, 70),
                painter: _MacroRingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
              Text(
                '${current}g',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '/ ${goal}g',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _MacroRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    const strokeWidth = 6.0;

    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
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
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
