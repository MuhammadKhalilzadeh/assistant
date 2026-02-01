import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quick add buttons for common water amounts with animations
class QuickAddButtons extends StatelessWidget {
  final Function(int amount) onAddWater;
  final double padding;
  final Animation<double>? animation;
  final int index;

  const QuickAddButtons({
    super.key,
    required this.onAddWater,
    required this.padding,
    this.animation,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final amounts = [
      (100, Icons.local_cafe, const Color(0xFF8B5A2B), 'Coffee cup'),
      (250, Icons.local_drink, const Color(0xFF3B82F6), 'Glass'),
      (500, Icons.water_drop, const Color(0xFF06B6D4), 'Water bottle'),
      (1000, Icons.water, const Color(0xFF0D9488), 'Large bottle'),
    ];

    Widget content = Container(
      padding: EdgeInsets.all(padding),
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
                Icons.add_circle_outline,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: amounts.map((item) {
              return _QuickAddButton(
                amount: item.$1,
                icon: item.$2,
                color: item.$3,
                label: item.$4,
                onTap: () => onAddWater(item.$1),
              );
            }).toList(),
          ),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _QuickAddButton extends StatefulWidget {
  final int amount;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.icon,
    required this.color,
    required this.label,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.amount}ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
