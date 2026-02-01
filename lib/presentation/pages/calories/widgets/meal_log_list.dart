import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'food_category_selector.dart';

class MealLogList extends StatelessWidget {
  final List<CalorieEntryModel> entries;
  final Animation<double> animation;
  final Function(String) onDeleteEntry;

  const MealLogList({
    super.key,
    required this.entries,
    required this.animation,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    final groupedEntries = <MealType, List<CalorieEntryModel>>{};
    for (final entry in entries) {
      groupedEntries.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_menu, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Today\'s Meals',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...MealType.values
            .where((type) => groupedEntries.containsKey(type))
            .toList()
            .asMap()
            .entries
            .map((mapEntry) {
          final index = mapEntry.key;
          final type = mapEntry.value;
          final typeEntries = groupedEntries[type]!;

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final delay = index * 0.15;
              final animValue =
                  ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(0, 20 * (1 - animValue)),
                child: Opacity(
                  opacity: animValue,
                  child: _MealTypeSection(
                    mealType: type,
                    entries: typeEntries,
                    onDeleteEntry: onDeleteEntry,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 56,
            color: AppTheme.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No meals logged today',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first meal',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTypeSection extends StatelessWidget {
  final MealType mealType;
  final List<CalorieEntryModel> entries;
  final Function(String) onDeleteEntry;

  const _MealTypeSection({
    required this.mealType,
    required this.entries,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold(0, (sum, e) => sum + e.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getMealColor(mealType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMealIcon(mealType),
                    color: _getMealColor(mealType),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMealLabel(mealType),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${entries.length} item${entries.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMealColor(mealType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCalories cal',
                    style: TextStyle(
                      color: _getMealColor(mealType),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Entries
          ...entries.map((entry) => _MealEntryItem(
                entry: entry,
                onDelete: () => onDeleteEntry(entry.id),
              )),
        ],
      ),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  String _getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppTheme.warningColor;
      case MealType.lunch:
        return AppTheme.successColor;
      case MealType.dinner:
        return AppTheme.infoColor;
      case MealType.snack:
        return AppTheme.primaryColor;
    }
  }
}

class _MealEntryItem extends StatelessWidget {
  final CalorieEntryModel entry;
  final VoidCallback onDelete;

  const _MealEntryItem({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            // Category icon
            if (entry.foodCategory != null)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: FoodCategorySelector.getCategoryData(entry.foodCategory!)
                      .color
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FoodCategorySelector.getCategoryData(entry.foodCategory!).icon,
                  color: FoodCategorySelector.getCategoryData(entry.foodCategory!)
                      .color,
                  size: 18,
                ),
              )
            else
              const SizedBox(width: 44),
            // Food name and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(entry.loggedAt),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Calories
            Text(
              '${entry.calories} cal',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
