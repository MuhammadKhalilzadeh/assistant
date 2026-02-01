import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// 7-day bar chart showing daily sleep duration
class WeeklySleepChart extends StatelessWidget {
  final Map<String, double> last7DaysHours;
  final int goalMinutes;
  final double padding;
  final Animation<double>? animation;

  const WeeklySleepChart({
    super.key,
    required this.last7DaysHours,
    required this.goalMinutes,
    required this.padding,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final goalHours = goalMinutes / 60.0;

    Widget content = Container(
      padding: EdgeInsets.all(padding),
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
              Icon(
                Icons.bar_chart,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7DaysHours.entries.map((entry) {
                final hours = entry.value;
                final goalMet = hours >= goalHours;
                // Progress relative to 12 hours max display
                final progress = hours > 0 ? (hours / 12).clamp(0.0, 1.0) : 0.0;

                return _DayBar(
                  dayName: entry.key,
                  hours: hours,
                  progress: progress,
                  goalMet: goalMet,
                  goalHours: goalHours,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Goal: ${goalHours.toStringAsFixed(1)}h',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Goal met',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Below goal',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
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
          ).animate(CurvedAnimation(
            parent: animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _DayBar extends StatefulWidget {
  final String dayName;
  final double hours;
  final double progress;
  final bool goalMet;
  final double goalHours;

  const _DayBar({
    required this.dayName,
    required this.hours,
    required this.progress,
    required this.goalMet,
    required this.goalHours,
  });

  @override
  State<_DayBar> createState() => _DayBarState();
}

class _DayBarState extends State<_DayBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Delay animation start for stagger effect
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Hours value on top
        Text(
          widget.hours > 0 ? '${widget.hours.toStringAsFixed(1)}h' : '-',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Bar container
        SizedBox(
          height: 90,
          width: 28,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background bar
              Container(
                width: 28,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Goal line
              Positioned(
                bottom: 90 * (widget.goalHours / 12).clamp(0.0, 1.0),
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                ),
              ),
              // Animated fill bar
              AnimatedBuilder(
                animation: _heightAnimation,
                builder: (context, child) {
                  return Container(
                    width: 28,
                    height: 90 * _heightAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: widget.goalMet
                            ? [
                                AppTheme.successColor.withValues(alpha: 0.8),
                                AppTheme.successColor.withValues(alpha: 0.4),
                              ]
                            : [
                                AppTheme.primaryColor.withValues(alpha: 0.8),
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Day label
        Text(
          widget.dayName,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
