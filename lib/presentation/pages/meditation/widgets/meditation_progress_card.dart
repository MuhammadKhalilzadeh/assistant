import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/meditation_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Main progress card displaying meditation timer with breathing animation
class MeditationProgressCard extends StatelessWidget {
  final int todayMinutes;
  final int todaySessions;
  final int dailyGoal;
  final double progress;
  final double animationPhase;
  final double padding;
  final bool isTimerActive;
  final bool isPaused;
  final int remainingSeconds;
  final int totalSeconds;
  final MeditationType? activeSessionType;
  final VoidCallback? onStartSession;
  final VoidCallback? onPauseSession;
  final VoidCallback? onResumeSession;
  final VoidCallback? onStopSession;

  const MeditationProgressCard({
    super.key,
    required this.todayMinutes,
    required this.todaySessions,
    required this.dailyGoal,
    required this.progress,
    required this.animationPhase,
    required this.padding,
    this.isTimerActive = false,
    this.isPaused = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 300,
    this.activeSessionType,
    this.onStartSession,
    this.onPauseSession,
    this.onResumeSession,
    this.onStopSession,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getMotivationalMessage() {
    if (isTimerActive && !isPaused) {
      return 'Breathe deeply. Find your center.';
    } else if (isPaused) {
      return 'Take your time. Resume when ready.';
    } else if (progress >= 1.0) {
      return 'Daily goal achieved! Namaste.';
    } else if (progress >= 0.75) {
      return 'Almost there! Keep meditating.';
    } else if (progress >= 0.5) {
      return 'Halfway to your daily goal!';
    } else if (progress >= 0.25) {
      return 'Great start! Continue your practice.';
    } else {
      return 'Ready to find your peace?';
    }
  }

  String _getBreathingInstruction() {
    // 4-second inhale, 4-second exhale cycle
    final cyclePosition = animationPhase % 1.0;
    if (cyclePosition < 0.5) {
      return 'Breathe In';
    } else {
      return 'Breathe Out';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);
    final timerProgress = totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0.0;

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring with breathing animation
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _MeditationProgressPainter(
                    progress: isTimerActive ? timerProgress : progress,
                    animationValue: animationPhase,
                    isActive: isTimerActive && !isPaused,
                  ),
                ),
                // Breathing circle animation (when active)
                if (isTimerActive && !isPaused)
                  _BreathingCircle(
                    animationPhase: animationPhase,
                    size: ringSize * 0.5,
                  ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isTimerActive) ...[
                      Icon(
                        Icons.self_improvement,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
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
                    ] else ...[
                      Text(
                        _getBreathingInstruction(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(remainingSeconds),
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (activeSessionType != null)
                        Text(
                          activeSessionType!.name.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                icon: Icons.timer,
                value: '$todayMinutes',
                label: 'Minutes',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
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
                icon: Icons.flag,
                value: '$dailyGoal',
                label: 'Goal (min)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Start/Pause/Stop buttons
          if (!isTimerActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Start Session',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isPaused ? onResumeSession : onPauseSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaused
                          ? AppTheme.primaryColor
                          : AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(
                      isPaused ? 'Resume' : 'Pause',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStopSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text(
                      'Stop',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
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

class _BreathingCircle extends StatelessWidget {
  final double animationPhase;
  final double size;

  const _BreathingCircle({
    required this.animationPhase,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Create smooth breathing animation (inhale/exhale)
    final breathPhase = (math.sin(animationPhase * 2 * math.pi) + 1) / 2;
    final scale = 0.6 + (breathPhase * 0.4);
    final opacity = 0.3 + (breathPhase * 0.3);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: opacity * 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
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

class _MeditationProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final bool isActive;

  _MeditationProgressPainter({
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
      final pulsePhase = (math.sin(animationValue * 2 * math.pi) + 1) / 2;
      final pulsePaint = Paint()
        ..color = AppTheme.successColor.withValues(alpha: 0.2 * (1 - pulsePhase))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (6 * pulsePhase);

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
  bool shouldRepaint(covariant _MeditationProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive;
  }
}
