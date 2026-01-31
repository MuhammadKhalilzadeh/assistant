import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../focus_timer_page.dart';

/// Animated circular timer display with mode-based styling
class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final TimerMode timerMode;
  final TimerState timerState;
  final AnimationController pulseAnimation;
  final AnimationController completionAnimation;

  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.timerMode,
    required this.timerState,
    required this.pulseAnimation,
    required this.completionAnimation,
  });

  String get _modeLabel {
    switch (timerMode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  String get _statusMessage {
    switch (timerState) {
      case TimerState.idle:
        return 'Ready to focus?';
      case TimerState.running:
        return timerMode == TimerMode.focus
            ? 'Stay focused!'
            : 'Relax...';
      case TimerState.paused:
        return 'Paused';
      case TimerState.completed:
        return 'Well done!';
    }
  }

  Color get _ringColor {
    switch (timerMode) {
      case TimerMode.focus:
        return Colors.white;
      case TimerMode.shortBreak:
        return Colors.white;
      case TimerMode.longBreak:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final timerSize = (screenWidth * 0.65).clamp(200.0, 300.0);
    final ringSize = timerSize * 0.9;
    final strokeWidth = timerSize * 0.04;

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final progress = totalSeconds > 0
        ? 1 - (remainingSeconds / totalSeconds)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(timerSize * 0.08),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseAnimation, completionAnimation]),
        builder: (context, child) {
          final pulseScale = timerState == TimerState.running
              ? 1 + (pulseAnimation.value * 0.02)
              : 1.0;

          final completionScale = timerState == TimerState.completed
              ? 1 + (completionAnimation.value * 0.1)
              : 1.0;

          return Transform.scale(
            scale: pulseScale * completionScale,
            child: SizedBox(
              width: timerSize,
              height: timerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: strokeWidth,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),

                  // Progress ring
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: value,
                            strokeWidth: strokeWidth,
                            color: _ringColor,
                            glowColor: timerState == TimerState.running
                                ? _ringColor.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        );
                      },
                    ),
                  ),

                  // Time display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mode label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _modeLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Time
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: timerSize * 0.22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Status message
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Completion burst animation
                  if (timerState == TimerState.completed)
                    ...List.generate(8, (index) {
                      final angle = (index / 8) * 2 * math.pi;
                      final distance = completionAnimation.value * 50;
                      return Positioned(
                        left: timerSize / 2 + math.cos(angle) * distance - 4,
                        top: timerSize / 2 + math.sin(angle) * distance - 4,
                        child: Opacity(
                          opacity: 1 - completionAnimation.value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for the circular progress ring with glow effect
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color glowColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Glow effect
    if (glowColor != Colors.transparent) {
      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // Main progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.glowColor != glowColor;
  }
}
