import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating sleep hygiene tips card with tap-to-change functionality
class SleepTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const SleepTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<SleepTipsCard> createState() => _SleepTipsCardState();
}

class _SleepTipsCardState extends State<SleepTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_SleepTip> _tips = [
    _SleepTip(
      icon: Icons.schedule,
      text: 'Stick to a consistent sleep schedule, even on weekends.',
      timeOfDay: _TimeOfDayPeriod.any,
    ),
    _SleepTip(
      icon: Icons.no_drinks,
      text: 'Avoid caffeine at least 6 hours before bedtime.',
      timeOfDay: _TimeOfDayPeriod.afternoon,
    ),
    _SleepTip(
      icon: Icons.phone_android,
      text: 'Put away screens 1 hour before bed - blue light disrupts sleep.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.thermostat,
      text: 'Keep your bedroom cool (65-68°F / 18-20°C) for optimal sleep.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.wb_sunny_outlined,
      text: 'Get natural sunlight exposure in the morning to regulate your body clock.',
      timeOfDay: _TimeOfDayPeriod.morning,
    ),
    _SleepTip(
      icon: Icons.fitness_center,
      text: 'Exercise regularly, but not too close to bedtime.',
      timeOfDay: _TimeOfDayPeriod.any,
    ),
    _SleepTip(
      icon: Icons.restaurant,
      text: 'Avoid heavy meals within 3 hours of bedtime.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.self_improvement,
      text: 'Practice relaxation techniques like deep breathing before bed.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.dark_mode,
      text: 'Create a dark sleep environment with blackout curtains.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.volume_off,
      text: 'Use white noise or earplugs to block disruptive sounds.',
      timeOfDay: _TimeOfDayPeriod.any,
    ),
    _SleepTip(
      icon: Icons.local_cafe,
      text: 'Try herbal tea like chamomile to help you relax before sleep.',
      timeOfDay: _TimeOfDayPeriod.evening,
    ),
    _SleepTip(
      icon: Icons.hotel,
      text: 'Reserve your bed for sleep only - avoid working in bed.',
      timeOfDay: _TimeOfDayPeriod.any,
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
    _TimeOfDayPeriod currentPeriod;

    if (hour >= 5 && hour < 12) {
      currentPeriod = _TimeOfDayPeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      currentPeriod = _TimeOfDayPeriod.afternoon;
    } else {
      currentPeriod = _TimeOfDayPeriod.evening;
    }

    // Find tips relevant to current time or any time
    final relevantTips = _tips
        .asMap()
        .entries
        .where((e) =>
            e.value.timeOfDay == currentPeriod ||
            e.value.timeOfDay == _TimeOfDayPeriod.any)
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
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
          boxShadow: AppTheme.cardShadow,
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
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tip.icon,
                  color: AppTheme.primaryColor,
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
                        color: AppTheme.textTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sleep Tip',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.touch_app,
                        color: AppTheme.textTertiary.withValues(alpha: 0.5),
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
                      style: TextStyle(
                        color: AppTheme.textPrimary,
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

enum _TimeOfDayPeriod { morning, afternoon, evening, any }

class _SleepTip {
  final IconData icon;
  final String text;
  final _TimeOfDayPeriod timeOfDay;

  const _SleepTip({
    required this.icon,
    required this.text,
    required this.timeOfDay,
  });
}
