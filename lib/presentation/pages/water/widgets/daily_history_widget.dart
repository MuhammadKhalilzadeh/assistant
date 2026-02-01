import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// 7-day bar chart showing daily water intake history
class DailyHistoryWidget extends StatelessWidget {
  final Map<String, int> last7DaysIntake;
  final int dailyGoal;
  final double padding;
  final Animation<double>? animation;

  const DailyHistoryWidget({
    super.key,
    required this.last7DaysIntake,
    required this.dailyGoal,
    required this.padding,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
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
              children: last7DaysIntake.entries.map((entry) {
                final intake = entry.value;
                final goalMet = intake >= dailyGoal;
                final progress = dailyGoal > 0 ? (intake / dailyGoal).clamp(0.0, 1.0) : 0.0;

                return _DayBar(
                  dayName: entry.key,
                  intake: intake,
                  progress: progress,
                  goalMet: goalMet,
                  dailyGoal: dailyGoal,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Goal line indicator
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Goal: ${dailyGoal}ml',
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
                'In progress',
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
  final int intake;
  final double progress;
  final bool goalMet;
  final int dailyGoal;

  const _DayBar({
    required this.dayName,
    required this.intake,
    required this.progress,
    required this.goalMet,
    required this.dailyGoal,
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
        // Intake value on top
        Text(
          widget.intake > 0 ? '${(widget.intake / 1000).toStringAsFixed(1)}L' : '-',
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
                bottom: 90 * (widget.dailyGoal > 0 ? 1.0 : 0.0).clamp(0.0, 1.0),
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
