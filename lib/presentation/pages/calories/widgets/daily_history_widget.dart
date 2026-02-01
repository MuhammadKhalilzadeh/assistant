import 'package:flutter/material.dart';

class DailyHistoryWidget extends StatelessWidget {
  final Map<String, int> last7DaysCalories;
  final int goalCalories;
  final Animation<double> animation;

  const DailyHistoryWidget({
    super.key,
    required this.last7DaysCalories,
    required this.goalCalories,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final maxCalories = last7DaysCalories.values.isEmpty
        ? goalCalories
        : last7DaysCalories.values.reduce((a, b) => a > b ? a : b);
    final chartMax = (maxCalories > goalCalories ? maxCalories : goalCalories) * 1.1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_view_week, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SizedBox(
                height: 140,
                child: Stack(
                  children: [
                    // Goal line
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: (goalCalories / chartMax) * 100 + 30,
                      child: Row(
                        children: [
                          Container(
                            height: 1,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Goal label
                    Positioned(
                      right: 0,
                      bottom: (goalCalories / chartMax) * 100 + 32,
                      child: Text(
                        'Goal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    // Bars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: last7DaysCalories.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final dayEntry = entry.value;
                        final delay = index * 0.1;
                        final animValue =
                            ((animation.value - delay) / (1 - delay * 7 / 6))
                                .clamp(0.0, 1.0);

                        return _DayBar(
                          day: dayEntry.key,
                          calories: dayEntry.value,
                          maxHeight: 100,
                          chartMax: chartMax,
                          goalCalories: goalCalories,
                          animationValue: animValue,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String day;
  final int calories;
  final double maxHeight;
  final double chartMax;
  final int goalCalories;
  final double animationValue;

  const _DayBar({
    required this.day,
    required this.calories,
    required this.maxHeight,
    required this.chartMax,
    required this.goalCalories,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = (calories / chartMax) * maxHeight * animationValue;
    final isWithinGoal =
        calories >= goalCalories * 0.8 && calories <= goalCalories;
    final isOverGoal = calories > goalCalories;

    Color barColor;
    if (isOverGoal) {
      barColor = Colors.red.shade400;
    } else if (isWithinGoal) {
      barColor = Colors.green.shade400;
    } else if (calories > 0) {
      barColor = Colors.amber.shade400;
    } else {
      barColor = Colors.white.withValues(alpha: 0.2);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Calorie label
        SizedBox(
          height: 16,
          child: animationValue > 0.5 && calories > 0
              ? Text(
                  '${(calories * animationValue).round()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        // Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: 28,
          height: barHeight.clamp(4.0, maxHeight),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: calories > 0 && animationValue > 0.5
                ? [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        // Day label
        Text(
          day,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
