import 'package:flutter/material.dart';

/// Filter options for the todo list
enum TodoFilter {
  all,
  active,
  completed,
  today,
  upcoming,
}

extension TodoFilterExtension on TodoFilter {
  String get label {
    switch (this) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.today:
        return 'Today';
      case TodoFilter.upcoming:
        return 'Upcoming';
    }
  }

  IconData get icon {
    switch (this) {
      case TodoFilter.all:
        return Icons.list_rounded;
      case TodoFilter.active:
        return Icons.radio_button_unchecked;
      case TodoFilter.completed:
        return Icons.check_circle_outline;
      case TodoFilter.today:
        return Icons.today_rounded;
      case TodoFilter.upcoming:
        return Icons.upcoming_rounded;
    }
  }
}

class TodoFilters extends StatelessWidget {
  final TodoFilter selected;
  final ValueChanged<TodoFilter> onChanged;
  final Map<TodoFilter, int> counts;

  const TodoFilters({
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
        itemCount: TodoFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = TodoFilter.values[index];
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
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.white,
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
                                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.white,
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
