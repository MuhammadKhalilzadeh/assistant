import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAddItem {
  final String name;
  final int calories;
  final IconData icon;
  final Color color;
  final FoodCategory category;
  final int? protein;
  final int? carbs;
  final int? fat;

  const QuickAddItem({
    required this.name,
    required this.calories,
    required this.icon,
    required this.color,
    required this.category,
    this.protein,
    this.carbs,
    this.fat,
  });
}

class QuickAddButtons extends StatelessWidget {
  final Function(QuickAddItem) onQuickAdd;

  const QuickAddButtons({
    super.key,
    required this.onQuickAdd,
  });

  static const List<QuickAddItem> _quickItems = [
    QuickAddItem(
      name: 'Apple',
      calories: 95,
      icon: Icons.apple,
      color: Color(0xFF4CAF50),
      category: FoodCategory.fruits,
      carbs: 25,
    ),
    QuickAddItem(
      name: 'Coffee',
      calories: 5,
      icon: Icons.coffee,
      color: Color(0xFF795548),
      category: FoodCategory.beverages,
    ),
    QuickAddItem(
      name: 'Sandwich',
      calories: 350,
      icon: Icons.lunch_dining,
      color: Color(0xFFFF9800),
      category: FoodCategory.grains,
      protein: 15,
      carbs: 40,
      fat: 12,
    ),
    QuickAddItem(
      name: 'Salad',
      calories: 150,
      icon: Icons.eco,
      color: Color(0xFF8BC34A),
      category: FoodCategory.vegetables,
      protein: 5,
      carbs: 15,
      fat: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: Colors.amber.shade300,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _quickItems
                .map((item) => _QuickAddButton(
                      item: item,
                      onTap: () => onQuickAdd(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  final QuickAddItem item;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.item,
    required this.onTap,
  });

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _handleTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.item.color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: widget.item.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.item.calories} cal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
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
