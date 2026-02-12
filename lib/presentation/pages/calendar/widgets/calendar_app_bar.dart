import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Calendar view types
enum CalendarViewType {
  month,
  week,
  day,
  agenda;

  String get label {
    switch (this) {
      case CalendarViewType.month:
        return 'Month';
      case CalendarViewType.week:
        return 'Week';
      case CalendarViewType.day:
        return 'Day';
      case CalendarViewType.agenda:
        return 'Agenda';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarViewType.month:
        return Icons.calendar_view_month;
      case CalendarViewType.week:
        return Icons.calendar_view_week;
      case CalendarViewType.day:
        return Icons.calendar_view_day;
      case CalendarViewType.agenda:
        return Icons.view_agenda;
    }
  }
}

/// Compact app bar — just back + title + today button
class CalendarAppBar extends StatelessWidget {
  final VoidCallback onTodayPressed;
  final VoidCallback? onBackPressed;

  const CalendarAppBar({
    super.key,
    required this.onTodayPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Calendar',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _TodayButton(onPressed: onTodayPressed),
        ],
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _TodayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.today,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 6),
            Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented view toggle — used in CalendarPage body
class CalendarViewToggle extends StatelessWidget {
  final CalendarViewType currentView;
  final ValueChanged<CalendarViewType> onViewChanged;

  const CalendarViewToggle({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Row(
          children: CalendarViewType.values.map((view) {
            final isSelected = view == currentView;
            return Expanded(
              child: GestureDetector(
                onTap: () => onViewChanged(view),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.cardColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: isSelected ? AppTheme.cardShadow : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        view.icon,
                        size: 14,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        view.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
