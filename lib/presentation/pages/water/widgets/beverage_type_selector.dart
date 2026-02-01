import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/water_log_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Horizontal beverage type selector with icons and labels
class BeverageTypeSelector extends StatelessWidget {
  final BeverageType selectedType;
  final ValueChanged<BeverageType> onTypeSelected;

  const BeverageTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  IconData _getIcon(BeverageType type) {
    switch (type) {
      case BeverageType.water:
        return Icons.water_drop;
      case BeverageType.coffee:
        return Icons.coffee;
      case BeverageType.tea:
        return Icons.emoji_food_beverage;
      case BeverageType.juice:
        return Icons.local_bar;
      case BeverageType.milk:
        return Icons.local_cafe;
      case BeverageType.other:
        return Icons.local_drink;
    }
  }

  Color _getColor(BeverageType type) {
    switch (type) {
      case BeverageType.water:
        return AppTheme.primaryColor; // Red
      case BeverageType.coffee:
        return const Color(0xFF8B5A2B); // Brown
      case BeverageType.tea:
        return AppTheme.warningColor; // Amber
      case BeverageType.juice:
        return const Color(0xFFEA580C); // Orange
      case BeverageType.milk:
        return AppTheme.textSecondary; // Gray
      case BeverageType.other:
        return AppTheme.infoColor; // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BeverageType.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = BeverageType.values[index];
          final isSelected = type == selectedType;
          final color = _getColor(type);

          return GestureDetector(
            onTap: () => onTypeSelected(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color
                      : AppTheme.textTertiary.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _getIcon(type),
                      color: isSelected ? color : AppTheme.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
