import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Single day cell in month grid view
class DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final int eventCount;
  final List<Color> eventColors;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isCurrentMonth,
    required this.eventCount,
    required this.eventColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isToday
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isCurrentMonth
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                fontSize: 16,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              child: Text('${date.day}'),
            ),
            const SizedBox(height: 2),
            _buildEventDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDots() {
    if (eventColors.isEmpty) {
      return const SizedBox(height: 4);
    }

    final displayColors = eventColors.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayColors.map((color) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.9) : color,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }
}
