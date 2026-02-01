import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating workout/fitness tips card with tap-to-change functionality
class WorkoutTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const WorkoutTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<WorkoutTipsCard> createState() => _WorkoutTipsCardState();
}

class _WorkoutTipsCardState extends State<WorkoutTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_WorkoutTip> _tips = [
    _WorkoutTip(
      icon: Icons.wb_sunny_outlined,
      text: 'Morning workouts boost metabolism and energy throughout the day.',
    ),
    _WorkoutTip(
      icon: Icons.water_drop,
      text: 'Stay hydrated! Drink water before, during, and after exercise.',
    ),
    _WorkoutTip(
      icon: Icons.hotel,
      text: 'Rest days are essential for muscle recovery and growth.',
    ),
    _WorkoutTip(
      icon: Icons.restaurant,
      text: 'Eat protein within 30 minutes after workout for optimal recovery.',
    ),
    _WorkoutTip(
      icon: Icons.accessibility_new,
      text: 'Always warm up for 5-10 minutes before intense exercise.',
    ),
    _WorkoutTip(
      icon: Icons.trending_up,
      text: 'Progressive overload: gradually increase weight or reps over time.',
    ),
    _WorkoutTip(
      icon: Icons.timer,
      text: 'HIIT workouts burn more calories in less time than steady cardio.',
    ),
    _WorkoutTip(
      icon: Icons.straighten,
      text: 'Focus on proper form to prevent injuries and maximize results.',
    ),
    _WorkoutTip(
      icon: Icons.groups,
      text: 'Working out with a partner increases motivation and consistency.',
    ),
    _WorkoutTip(
      icon: Icons.music_note,
      text: 'Upbeat music can increase workout performance by up to 15%.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentTipIndex = Random().nextInt(_tips.length);
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
                        'Fitness Tip',
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

class _WorkoutTip {
  final IconData icon;
  final String text;

  const _WorkoutTip({
    required this.icon,
    required this.text,
  });
}
