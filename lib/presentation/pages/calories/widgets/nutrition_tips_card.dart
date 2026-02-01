import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NutritionTipsCard extends StatefulWidget {
  const NutritionTipsCard({super.key});

  @override
  State<NutritionTipsCard> createState() => _NutritionTipsCardState();
}

class _NutritionTipsCardState extends State<NutritionTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  int _currentTipIndex = 0;

  static const List<_NutritionTip> _tips = [
    _NutritionTip(
      text: 'Eat protein with every meal for better satiety',
      icon: Icons.egg_alt,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Drink water before meals to control portions',
      icon: Icons.water_drop,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Plan your meals ahead to avoid unhealthy choices',
      icon: Icons.calendar_today,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Include fiber-rich foods to stay fuller longer',
      icon: Icons.eco,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Eat slowly and mindfully for better digestion',
      icon: Icons.self_improvement,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Start your day with a balanced breakfast',
      icon: Icons.wb_sunny,
      timeRelevant: 'morning',
    ),
    _NutritionTip(
      text: 'Avoid heavy meals close to bedtime',
      icon: Icons.nightlight_round,
      timeRelevant: 'evening',
    ),
    _NutritionTip(
      text: 'Keep healthy snacks within reach',
      icon: Icons.apple,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Color your plate with varied vegetables',
      icon: Icons.palette,
      timeRelevant: null,
    ),
    _NutritionTip(
      text: 'Track consistently for better awareness',
      icon: Icons.insights,
      timeRelevant: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _selectTimeRelevantTip();
    _iconController.forward();
  }

  void _selectTimeRelevantTip() {
    final hour = DateTime.now().hour;
    String? timeOfDay;

    if (hour >= 5 && hour < 11) {
      timeOfDay = 'morning';
    } else if (hour >= 18 || hour < 5) {
      timeOfDay = 'evening';
    }

    if (timeOfDay != null) {
      final relevantIndex =
          _tips.indexWhere((tip) => tip.timeRelevant == timeOfDay);
      if (relevantIndex != -1) {
        _currentTipIndex = relevantIndex;
        return;
      }
    }

    _currentTipIndex = Random().nextInt(_tips.length);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _nextTip() {
    HapticFeedback.selectionClick();
    _iconController.reverse().then((_) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
      });
      _iconController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_currentTipIndex];

    return GestureDetector(
      onTap: _nextTip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * _iconAnimation.value),
                  child: Opacity(
                    opacity: _iconAnimation.value,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tip.icon,
                        color: Colors.amber.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade300,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nutrition Tip',
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      tip.text,
                      key: ValueKey(_currentTipIndex),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.touch_app,
              color: Colors.white.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionTip {
  final String text;
  final IconData icon;
  final String? timeRelevant;

  const _NutritionTip({
    required this.text,
    required this.icon,
    this.timeRelevant,
  });
}
