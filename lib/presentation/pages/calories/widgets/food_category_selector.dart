import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class FoodCategoryData {
  final FoodCategory category;
  final String label;
  final IconData icon;
  final Color color;

  const FoodCategoryData({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class FoodCategorySelector extends StatelessWidget {
  final FoodCategory? selectedCategory;
  final Function(FoodCategory) onCategorySelected;

  const FoodCategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<FoodCategoryData> _categories = [
    FoodCategoryData(
      category: FoodCategory.grains,
      label: 'Grains',
      icon: Icons.breakfast_dining,
      color: AppTheme.foodGrains,
    ),
    FoodCategoryData(
      category: FoodCategory.protein,
      label: 'Protein',
      icon: Icons.egg_alt,
      color: AppTheme.foodProtein,
    ),
    FoodCategoryData(
      category: FoodCategory.dairy,
      label: 'Dairy',
      icon: Icons.water_drop,
      color: AppTheme.foodDairy,
    ),
    FoodCategoryData(
      category: FoodCategory.fruits,
      label: 'Fruits',
      icon: Icons.apple,
      color: AppTheme.foodFruits,
    ),
    FoodCategoryData(
      category: FoodCategory.vegetables,
      label: 'Veggies',
      icon: Icons.eco,
      color: AppTheme.foodVegetables,
    ),
    FoodCategoryData(
      category: FoodCategory.fats,
      label: 'Fats',
      icon: Icons.opacity,
      color: AppTheme.foodFats,
    ),
    FoodCategoryData(
      category: FoodCategory.sweets,
      label: 'Sweets',
      icon: Icons.cake,
      color: AppTheme.foodSweets,
    ),
    FoodCategoryData(
      category: FoodCategory.beverages,
      label: 'Drinks',
      icon: Icons.local_cafe,
      color: AppTheme.foodBeverages,
    ),
    FoodCategoryData(
      category: FoodCategory.other,
      label: 'Other',
      icon: Icons.more_horiz,
      color: AppTheme.foodOther,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = selectedCategory == category.category;

          return _CategoryItem(
            data: category,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category.category),
          );
        },
      ),
    );
  }

  static FoodCategoryData getCategoryData(FoodCategory category) {
    return _categories.firstWhere(
      (c) => c.category == category,
      orElse: () => _categories.last,
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final FoodCategoryData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _CategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.data.color
                        : widget.data.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSelected
                          ? widget.data.color
                          : widget.data.color.withValues(alpha: 0.4),
                      width: widget.isSelected ? 2 : 1,
                    ),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: widget.data.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: widget.isSelected
                        ? AppTheme.textOnPrimary
                        : widget.data.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? AppTheme.textOnPrimary
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight:
                        widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
