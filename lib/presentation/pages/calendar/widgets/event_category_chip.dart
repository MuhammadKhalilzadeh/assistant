import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Event categories with their colors
enum EventCategory {
  work(
    label: 'Work',
    color: Color(0xFF6366F1),
    icon: Icons.work_outline,
  ),
  personal(
    label: 'Personal',
    color: Color(0xFFEC4899),
    icon: Icons.person_outline,
  ),
  health(
    label: 'Health',
    color: Color(0xFF10B981),
    icon: Icons.favorite_outline,
  ),
  social(
    label: 'Social',
    color: Color(0xFFF59E0B),
    icon: Icons.people_outline,
  ),
  other(
    label: 'Other',
    color: Color(0xFF64748B),
    icon: Icons.more_horiz,
  );

  final String label;
  final Color color;
  final IconData icon;

  const EventCategory({
    required this.label,
    required this.color,
    required this.icon,
  });

  String get hexColor {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${hex.substring(2)}';
  }

  static EventCategory fromHexColor(String hex) {
    final normalizedHex = hex.toUpperCase().replaceFirst('#', '');
    for (final category in EventCategory.values) {
      final categoryHex = category.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
      if (categoryHex == normalizedHex) {
        return category;
      }
    }
    return EventCategory.other;
  }
}

/// Category filter chip component
class EventCategoryChip extends StatelessWidget {
  final EventCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showLabel;
  final bool isCompact;

  const EventCategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactChip();
    }
    return _buildFullChip();
  }

  Widget _buildCompactChip() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? category.color
              : category.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: category.color.withValues(alpha: 0.5)),
        ),
        child: Icon(
          category.icon,
          size: 18,
          color: isSelected ? Colors.white : category.color,
        ),
      ),
    );
  }

  Widget _buildFullChip() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: isSelected
                ? category.color
                : category.color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : category.color,
                shape: BoxShape.circle,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category selector for add/edit event sheet
class CategorySelector extends StatelessWidget {
  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory> onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EventCategory.values.map((category) {
        return EventCategoryChip(
          category: category,
          isSelected: selectedCategory == category,
          onTap: () => onCategorySelected(category),
        );
      }).toList(),
    );
  }
}

/// Category filter bar for calendar views
class CategoryFilterBar extends StatelessWidget {
  final Set<EventCategory> selectedCategories;
  final ValueChanged<EventCategory> onCategoryToggled;
  final VoidCallback? onClearAll;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategories,
    required this.onCategoryToggled,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategories.isNotEmpty &&
        selectedCategories.length < EventCategory.values.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (hasFilters) ...[
            GestureDetector(
              onTap: onClearAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ...EventCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: EventCategoryChip(
                category: category,
                isSelected: selectedCategories.contains(category),
                onTap: () => onCategoryToggled(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}
