import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Main progress card displaying screen time vs daily limit
class ScreenTimeProgressCard extends StatelessWidget {
  final ScreenTimeRecord? todayScreenTime;
  final ScreenTimeRecord? yesterdayScreenTime;
  final int dailyLimit;
  final double progress;
  final double animationPhase;
  final double padding;

  const ScreenTimeProgressCard({
    super.key,
    required this.todayScreenTime,
    required this.yesterdayScreenTime,
    required this.dailyLimit,
    required this.progress,
    required this.animationPhase,
    required this.padding,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String _getStatusMessage() {
    if (progress > 1.0) {
      final overMinutes = (todayScreenTime?.totalMinutes ?? 0) - dailyLimit;
      return '${_formatTime(overMinutes)} over limit';
    } else if (progress >= 0.9) {
      return 'Approaching daily limit';
    } else if (progress >= 0.75) {
      return 'Consider taking a break';
    } else if (progress >= 0.5) {
      return 'Halfway through your limit';
    } else {
      return 'Great digital balance!';
    }
  }

  String _getComparisonText() {
    final todayMinutes = todayScreenTime?.totalMinutes ?? 0;
    final yesterdayMinutes = yesterdayScreenTime?.totalMinutes ?? 0;

    if (yesterdayMinutes == 0) {
      return 'No data from yesterday';
    }

    final diff = todayMinutes - yesterdayMinutes;
    if (diff > 0) {
      return '${_formatTime(diff.abs())} more than yesterday';
    } else if (diff < 0) {
      return '${_formatTime(diff.abs())} less than yesterday';
    } else {
      return 'Same as yesterday';
    }
  }

  IconData _getComparisonIcon() {
    final todayMinutes = todayScreenTime?.totalMinutes ?? 0;
    final yesterdayMinutes = yesterdayScreenTime?.totalMinutes ?? 0;

    if (yesterdayMinutes == 0) return Icons.remove;
    if (todayMinutes > yesterdayMinutes) return Icons.arrow_upward;
    if (todayMinutes < yesterdayMinutes) return Icons.arrow_downward;
    return Icons.remove;
  }

  Color _getComparisonColor() {
    final todayMinutes = todayScreenTime?.totalMinutes ?? 0;
    final yesterdayMinutes = yesterdayScreenTime?.totalMinutes ?? 0;

    if (yesterdayMinutes == 0) return AppTheme.textTertiary;
    // For screen time, LESS is better
    if (todayMinutes > yesterdayMinutes) return AppTheme.errorColor;
    if (todayMinutes < yesterdayMinutes) return AppTheme.successColor;
    return AppTheme.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.55).clamp(180.0, 220.0);
    final totalMinutes = todayScreenTime?.totalMinutes ?? 0;
    final pickups = todayScreenTime?.pickups ?? 0;
    final isOverLimit = progress > 1.0;

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress ring
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress painter
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _ScreenTimeProgressPainter(
                    progress: progress,
                    animationValue: animationPhase,
                    isOverLimit: isOverLimit,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverLimit ? Icons.warning_amber : Icons.phone_android,
                      color: isOverLimit ? AppTheme.errorColor : AppTheme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    // Animated time count
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: totalMinutes),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          _formatTime(value),
                          style: TextStyle(
                            color: isOverLimit ? AppTheme.errorColor : AppTheme.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Text(
                      'of ${_formatTime(dailyLimit)} limit',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
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
                icon: Icons.touch_app,
                value: '$pickups',
                label: 'Pickups',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.timer_outlined,
                value: _formatTime(dailyLimit),
                label: 'Limit',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              _QuickStat(
                icon: Icons.hourglass_empty,
                value: isOverLimit ? '+${_formatTime(totalMinutes - dailyLimit)}' : _formatTime((dailyLimit - totalMinutes).clamp(0, dailyLimit)),
                label: isOverLimit ? 'Over' : 'Remaining',
                valueColor: isOverLimit ? AppTheme.errorColor : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit
                    ? AppTheme.errorColor
                    : progress >= 0.8
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Comparison row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).clamp(0, 100).toInt()}% of limit',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Icon(
                    _getComparisonIcon(),
                    color: _getComparisonColor(),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getComparisonText(),
                    style: TextStyle(
                      color: _getComparisonColor(),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isOverLimit
                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                  : progress >= 0.8
                      ? AppTheme.warningColor.withValues(alpha: 0.1)
                      : AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusMessage(),
              style: TextStyle(
                color: isOverLimit
                    ? AppTheme.errorColor
                    : progress >= 0.8
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
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
  final Color? valueColor;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
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
            color: valueColor ?? AppTheme.textPrimary,
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

class _ScreenTimeProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final bool isOverLimit;

  _ScreenTimeProgressPainter({
    required this.progress,
    this.animationValue = 0.0,
    this.isOverLimit = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Color based on progress (reverse logic - less is better)
    if (isOverLimit) {
      progressPaint.color = AppTheme.errorColor;
    } else if (progress >= 0.8) {
      progressPaint.color = AppTheme.warningColor;
    } else {
      progressPaint.color = AppTheme.successColor;
    }

    // Draw progress arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Animated glow effect
      if (animationValue > 0) {
        final glowPaint = Paint()
          ..color = progressPaint.color.withValues(alpha: 0.3 * (1 - animationValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20 + (8 * animationValue)
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        final glowSweep = sweepAngle * 0.1;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + sweepAngle - glowSweep,
          glowSweep,
          false,
          glowPaint,
        );
      }
    }

    // Inner decorative circle
    final innerPaint = Paint()
      ..color = AppTheme.cardColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 20, innerPaint);

    // Inner border
    final innerBorderPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 20, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScreenTimeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isOverLimit != isOverLimit;
  }
}
