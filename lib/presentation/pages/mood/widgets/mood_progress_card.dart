import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/mood_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Main progress card displaying today's mood with large emoji
class MoodProgressCard extends StatelessWidget {
  final MoodEntryModel? todayMood;
  final int streakDays;
  final int weeklyEntries;
  final double progress;
  final double animationPhase;
  final double padding;
  final VoidCallback? onLogMood;

  const MoodProgressCard({
    super.key,
    required this.todayMood,
    required this.streakDays,
    required this.weeklyEntries,
    required this.progress,
    required this.animationPhase,
    required this.padding,
    this.onLogMood,
  });

  String _getMotivationalMessage() {
    if (todayMood == null) {
      return 'How are you feeling today?';
    }
    switch (todayMood!.mood) {
      case MoodLevel.great:
        return 'Fantastic! Keep spreading that positivity!';
      case MoodLevel.good:
        return 'Nice! You\'re doing well today!';
      case MoodLevel.okay:
        return 'It\'s okay to have neutral days.';
      case MoodLevel.bad:
        return 'Tomorrow is a new opportunity.';
      case MoodLevel.awful:
        return 'Remember: it\'s okay to not be okay.';
    }
  }

  Color _getMoodColor() {
    if (todayMood == null) return AppTheme.textTertiary;
    switch (todayMood!.mood) {
      case MoodLevel.great:
        return AppTheme.successColor;
      case MoodLevel.good:
        return AppTheme.infoColor;
      case MoodLevel.okay:
        return AppTheme.warningColor;
      case MoodLevel.bad:
        return const Color(0xFFFF9800);
      case MoodLevel.awful:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);
    final moodColor = _getMoodColor();

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring with mood face
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _MoodProgressPainter(
                    progress: progress,
                    animationValue: animationPhase,
                    moodColor: moodColor,
                    hasMood: todayMood != null,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large mood emoji or placeholder
                    if (todayMood != null) ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Text(
                              todayMood!.moodEmoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todayMood!.moodLabel,
                        style: TextStyle(
                          color: moodColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.sentiment_neutral,
                        color: AppTheme.textTertiary,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Not logged',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Activity tags if any
          if (todayMood != null && todayMood!.activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: todayMood!.activities.map((activity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moodColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    activity,
                    style: TextStyle(
                      color: moodColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat(
                icon: Icons.local_fire_department,
                value: '$streakDays',
                label: 'Day Streak',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.calendar_today,
                value: '$weeklyEntries',
                label: 'This Week',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.emoji_emotions,
                value: todayMood != null ? '1' : '0',
                label: 'Today',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Log mood button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: todayMood != null ? moodColor : AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(todayMood != null ? Icons.edit : Icons.add),
              label: Text(
                todayMood != null ? 'Update Mood' : 'Log Mood',
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
              color: moodColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getMotivationalMessage(),
              style: TextStyle(
                color: moodColor,
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

class _MoodProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final Color moodColor;
  final bool hasMood;

  _MoodProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.moodColor,
    required this.hasMood,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    final strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = moodColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = moodColor
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

    // Animated pulse effect when mood is logged
    if (hasMood) {
      final pulsePaint = Paint()
        ..color = moodColor.withValues(alpha: 0.3 * (1 - animationValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (8 * animationValue);

      canvas.drawCircle(center, radius, pulsePaint);
    }

    // Decorative dots
    final dotPaint = Paint()
      ..color = moodColor.withValues(alpha: 0.3)
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
  bool shouldRepaint(covariant _MoodProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.moodColor != moodColor ||
        oldDelegate.hasMood != hasMood;
  }
}
