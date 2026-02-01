import 'dart:math';
import 'package:flutter/material.dart';

/// Rotating hydration tips card with tap-to-change functionality
class HydrationTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const HydrationTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<HydrationTipsCard> createState() => _HydrationTipsCardState();
}

class _HydrationTipsCardState extends State<HydrationTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_HydrationTip> _tips = [
    _HydrationTip(
      icon: Icons.wb_sunny_outlined,
      text: 'Start your day with a glass of water to kickstart your metabolism.',
      timeOfDay: TimeOfDayPeriod.morning,
    ),
    _HydrationTip(
      icon: Icons.alarm,
      text: 'Set hourly reminders to stay consistently hydrated throughout the day.',
      timeOfDay: TimeOfDayPeriod.any,
    ),
    _HydrationTip(
      icon: Icons.restaurant,
      text: 'Drink a glass of water 30 minutes before meals to aid digestion.',
      timeOfDay: TimeOfDayPeriod.any,
    ),
    _HydrationTip(
      icon: Icons.fitness_center,
      text: 'Drink extra water before, during, and after exercise.',
      timeOfDay: TimeOfDayPeriod.any,
    ),
    _HydrationTip(
      icon: Icons.local_florist,
      text: 'Add lemon, cucumber, or mint to make water more enjoyable.',
      timeOfDay: TimeOfDayPeriod.any,
    ),
    _HydrationTip(
      icon: Icons.nightlight_outlined,
      text: 'Keep a glass of water by your bedside for nighttime hydration.',
      timeOfDay: TimeOfDayPeriod.evening,
    ),
    _HydrationTip(
      icon: Icons.coffee,
      text: 'Balance caffeinated drinks with extra water to stay hydrated.',
      timeOfDay: TimeOfDayPeriod.afternoon,
    ),
    _HydrationTip(
      icon: Icons.monitor_weight_outlined,
      text: 'Thirst can be mistaken for hunger. Try water first!',
      timeOfDay: TimeOfDayPeriod.any,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _selectTimeRelevantTip();
  }

  void _selectTimeRelevantTip() {
    final hour = DateTime.now().hour;
    TimeOfDayPeriod currentPeriod;

    if (hour >= 5 && hour < 12) {
      currentPeriod = TimeOfDayPeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      currentPeriod = TimeOfDayPeriod.afternoon;
    } else {
      currentPeriod = TimeOfDayPeriod.evening;
    }

    // Find tips relevant to current time or any time
    final relevantTips = _tips
        .asMap()
        .entries
        .where((e) =>
            e.value.timeOfDay == currentPeriod ||
            e.value.timeOfDay == TimeOfDayPeriod.any)
        .toList();

    if (relevantTips.isNotEmpty) {
      _currentTipIndex = relevantTips[Random().nextInt(relevantTips.length)].key;
    }
  }

  void _nextTip() {
    _iconController.forward().then((_) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
      });
      _iconController.reverse();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_currentTipIndex];

    Widget content = GestureDetector(
      onTap: _nextTip,
      child: Container(
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(
                CurvedAnimation(
                  parent: _iconController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tip.icon,
                  color: const Color(0xFF06B6D4),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hydration Tip',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.touch_app,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      tip.text,
                      key: ValueKey(_currentTipIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.animation != null) {
      return FadeTransition(
        opacity: widget.animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: widget.animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }
}

enum TimeOfDayPeriod { morning, afternoon, evening, any }

class _HydrationTip {
  final IconData icon;
  final String text;
  final TimeOfDayPeriod timeOfDay;

  const _HydrationTip({
    required this.icon,
    required this.text,
    required this.timeOfDay,
  });
}
