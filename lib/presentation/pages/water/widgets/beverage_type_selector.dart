import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/water_log_model.dart';

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
        return const Color(0xFF06B6D4); // Cyan
      case BeverageType.coffee:
        return const Color(0xFF8B5A2B); // Brown
      case BeverageType.tea:
        return const Color(0xFFF59E0B); // Amber
      case BeverageType.juice:
        return const Color(0xFFEA580C); // Orange
      case BeverageType.milk:
        return const Color(0xFFF5F5F5); // White
      case BeverageType.other:
        return const Color(0xFF6366F1); // Indigo
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
                    ? color.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color
                      : Colors.white.withValues(alpha: 0.2),
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
                      color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
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
