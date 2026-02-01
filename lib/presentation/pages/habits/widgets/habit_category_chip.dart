import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:flutter/material.dart';

class HabitCategoryChip extends StatelessWidget {
  final HabitCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const HabitCategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category.iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'menu_book':
        return Icons.menu_book;
      case 'work':
        return Icons.work;
      case 'people':
        return Icons.people;
      case 'category':
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    if (compact) {
      return _buildCompactChip(color);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: isSelected ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 14,
              color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class HabitCategorySelector extends StatelessWidget {
  final HabitCategory? selected;
  final ValueChanged<HabitCategory?> onChanged;
  final bool showAllOption;

  const HabitCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          if (showAllOption) ...[
            _buildAllChip(),
            const SizedBox(width: 8),
          ],
          ...HabitCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: HabitCategoryChip(
                category: category,
                isSelected: selected == category,
                onTap: () => onChanged(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllChip() {
    final isAllSelected = selected == null;

    return GestureDetector(
      onTap: () => onChanged(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isAllSelected ? 14 : 12,
          vertical: isAllSelected ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isAllSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAllSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: isAllSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps,
              size: 14,
              color: isAllSelected
                  ? const Color(0xFF6366F1)
                  : Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'All',
              style: TextStyle(
                color: isAllSelected
                    ? const Color(0xFF6366F1)
                    : Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: isAllSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
