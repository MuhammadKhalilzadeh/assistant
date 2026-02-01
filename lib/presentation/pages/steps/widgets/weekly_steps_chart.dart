import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Weekly bar chart showing steps for the last 7 days with goal line
class WeeklyStepsChart extends StatelessWidget {
  final Map<String, int> last7DaysSteps;
  final int dailyGoal;
  final double padding;
  final Animation<double>? animation;

  const WeeklyStepsChart({
    super.key,
    required this.last7DaysSteps,
    required this.dailyGoal,
    required this.padding,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final maxSteps = last7DaysSteps.values.isEmpty
        ? dailyGoal
        : last7DaysSteps.values.reduce((a, b) => a > b ? a : b);
    final normalizedMax = (maxSteps > dailyGoal ? maxSteps : dailyGoal) * 1.1;
    final goalLinePosition = dailyGoal / normalizedMax;

    final today = DateTime.now();
    final todayDayName = _getDayName(today.weekday);

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
                'This Week',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Goal indicator
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Goal: ${_formatNumber(dailyGoal)}',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                // Goal line
                Positioned(
                  left: 0,
                  right: 0,
                  top: (1 - goalLinePosition) * 100,
                  child: Container(
                    height: 1,
                    color: AppTheme.successColor.withValues(alpha: 0.5),
                  ),
                ),
                // Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7DaysSteps.entries.map((entry) {
                    final steps = entry.value;
                    final height = normalizedMax > 0
                        ? (steps / normalizedMax * 100).clamp(4.0, 100.0)
                        : 4.0;
                    final isToday = entry.key == todayDayName;
                    final metGoal = steps >= dailyGoal;

                    return _ChartBar(
                      dayName: entry.key,
                      steps: steps,
                      height: height,
                      isToday: isToday,
                      metGoal: metGoal,
                    );
                  }).toList(),
                ),
              ],
            ),
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

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toString();
  }
}

class _ChartBar extends StatefulWidget {
  final String dayName;
  final int steps;
  final double height;
  final bool isToday;
  final bool metGoal;

  const _ChartBar({
    required this.dayName,
    required this.steps,
    required this.height,
    required this.isToday,
    required this.metGoal,
  });

  @override
  State<_ChartBar> createState() => _ChartBarState();
}

class _ChartBarState extends State<_ChartBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_ChartBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      _heightAnimation = Tween<double>(
        begin: _heightAnimation.value,
        end: widget.height,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return steps.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Steps label on hover/tap
        if (widget.steps > 0)
          Text(
            _formatSteps(widget.steps),
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 4),
        // Animated bar
        AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            return Container(
              width: 28,
              height: _heightAnimation.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: widget.metGoal
                      ? [
                          AppTheme.successColor,
                          AppTheme.successColor.withValues(alpha: 0.7),
                        ]
                      : widget.isToday
                          ? [
                              AppTheme.primaryColor,
                              AppTheme.primaryLight,
                            ]
                          : [
                              AppTheme.primaryColor.withValues(alpha: 0.5),
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                            ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: widget.isToday
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Day label
        Text(
          widget.dayName,
          style: TextStyle(
            color: widget.isToday ? AppTheme.textPrimary : AppTheme.textTertiary,
            fontSize: 11,
            fontWeight: widget.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
