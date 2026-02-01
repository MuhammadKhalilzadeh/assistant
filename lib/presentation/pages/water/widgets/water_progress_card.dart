import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'water_wave_painter.dart';

/// Main progress card displaying animated wave fill and intake stats
class WaterProgressCard extends StatelessWidget {
  final int currentIntake;
  final int dailyGoal;
  final double progress;
  final double wavePhase;
  final double padding;

  const WaterProgressCard({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
    required this.progress,
    required this.wavePhase,
    required this.padding,
  });

  String _getMotivationalMessage() {
    if (progress >= 1.0) {
      return 'Goal achieved! Great job staying hydrated!';
    } else if (progress >= 0.75) {
      return 'Almost there! Keep it up!';
    } else if (progress >= 0.5) {
      return 'Halfway through! Stay hydrated!';
    } else if (progress >= 0.25) {
      return 'Good start! Keep drinking water!';
    } else {
      return 'Start your hydration journey!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final waveSize = math.min(screenWidth * 0.5, 200.0);

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Wave animation container
          SizedBox(
            width: waveSize,
            height: waveSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Wave painter
                CustomPaint(
                  size: Size(waveSize, waveSize),
                  painter: WaterWavePainter(
                    progress: progress,
                    wavePhase: wavePhase,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    // Animated ml number
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: currentIntake),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          '${value}ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Text(
                      'of ${dailyGoal}ml',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? const Color(0xFF10B981) : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Remaining text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                progress >= 1.0
                    ? 'Goal completed!'
                    : '${(dailyGoal - currentIntake).clamp(0, dailyGoal)}ml remaining',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Motivational message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getMotivationalMessage(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
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
