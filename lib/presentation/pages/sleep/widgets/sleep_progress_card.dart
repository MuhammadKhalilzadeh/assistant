import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'moon_phase_painter.dart';
import 'sleep_quality_badge.dart';

/// Main progress card displaying moon animation and last night's sleep stats
class SleepProgressCard extends StatelessWidget {
  final SleepRecordModel? lastNight;
  final int goalMinutes;
  final double progress;
  final double moonPhase;
  final double padding;

  const SleepProgressCard({
    super.key,
    required this.lastNight,
    required this.goalMinutes,
    required this.progress,
    required this.moonPhase,
    required this.padding,
  });

  String _getMotivationalMessage() {
    if (lastNight == null) {
      return 'Log your sleep to start tracking!';
    }
    if (progress >= 1.0) {
      return 'Goal achieved! Great rest last night!';
    } else if (progress >= 0.9) {
      return 'Almost there! You\'re doing great!';
    } else if (progress >= 0.75) {
      return 'Good progress towards your goal!';
    } else if (progress >= 0.5) {
      return 'Halfway there! Keep prioritizing rest.';
    } else {
      return 'Focus on getting more sleep tonight.';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatGoal(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h goal';
    return '${hours}h ${mins}m goal';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final moonSize = math.min(screenWidth * 0.45, 180.0);

    if (lastNight == null) {
      return _buildEmptyState(moonSize);
    }

    final hours = lastNight!.durationHours;
    final hoursInt = hours.floor();
    final minutes = ((hours - hoursInt) * 60).round();

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Moon animation container
          SizedBox(
            width: moonSize,
            height: moonSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Moon painter
                CustomPaint(
                  size: Size(moonSize, moonSize),
                  painter: MoonPhasePainter(
                    progress: progress.clamp(0.0, 1.0),
                    glowPhase: moonPhase,
                    accentColor: AppTheme.primaryColor,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Duration display
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: hoursInt),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            );
                          },
                        ),
                        Text(
                          'h ',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: minutes),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            );
                          },
                        ),
                        Text(
                          'm',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatGoal(goalMinutes),
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quality badge
          SleepQualityBadge(quality: lastNight!.quality),
          const SizedBox(height: 16),

          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                progress >= 1.0
                    ? 'Goal achieved!'
                    : '${((goalMinutes - lastNight!.duration.inMinutes).clamp(0, goalMinutes) / 60).toStringAsFixed(1)}h remaining',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bedtime and wake time info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeInfo(
                icon: Icons.bedtime,
                label: 'Bedtime',
                time: _formatTime(lastNight!.bedTime),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              _TimeInfo(
                icon: Icons.wb_sunny,
                label: 'Wake up',
                time: _formatTime(lastNight!.wakeTime),
              ),
            ],
          ),
          const SizedBox(height: 16),

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

  Widget _buildEmptyState(double moonSize) {
    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          SizedBox(
            width: moonSize,
            height: moonSize,
            child: CustomPaint(
              size: Size(moonSize, moonSize),
              painter: MoonPhasePainter(
                progress: 0.0,
                glowPhase: moonPhase,
                accentColor: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.bedtime,
            size: 48,
            color: AppTheme.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No sleep data yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to log your sleep',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
