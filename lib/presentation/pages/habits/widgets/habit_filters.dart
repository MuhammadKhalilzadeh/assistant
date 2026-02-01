import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// Filter options for the habit list
enum HabitFilter {
  all,
  completed,
  inProgress,
  streaks,
}

extension HabitFilterExtension on HabitFilter {
  String get label {
    switch (this) {
      case HabitFilter.all:
        return 'All';
      case HabitFilter.completed:
        return 'Done';
      case HabitFilter.inProgress:
        return 'Pending';
      case HabitFilter.streaks:
        return 'Streaks';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitFilter.all:
        return Icons.list_rounded;
      case HabitFilter.completed:
        return Icons.check_circle_outline;
      case HabitFilter.inProgress:
        return Icons.radio_button_unchecked;
      case HabitFilter.streaks:
        return Icons.local_fire_department;
    }
  }
}

class HabitFilters extends StatelessWidget {
  final HabitFilter selected;
  final ValueChanged<HabitFilter> onChanged;
  final Map<HabitFilter, int> counts;

  const HabitFilters({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: HabitFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = HabitFilter.values[index];
          final isSelected = filter == selected;
          final count = counts[filter] ?? 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(filter),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 16,
                        color: isSelected
                            ? AppTheme.textOnPrimary
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.textOnPrimary
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        child: Text(filter.label),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.textOnPrimary.withValues(alpha: 0.2)
                                : AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.textOnPrimary
                                  : AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
