import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating mental wellness tips card with tap-to-change functionality
class MoodTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const MoodTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<MoodTipsCard> createState() => _MoodTipsCardState();
}

class _MoodTipsCardState extends State<MoodTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_MoodTip> _tips = [
    _MoodTip(
      icon: Icons.self_improvement,
      text: 'Practice mindfulness: Take 5 minutes to focus on your breathing.',
    ),
    _MoodTip(
      icon: Icons.wb_sunny_outlined,
      text: 'Get some sunlight. Natural light boosts serotonin and mood.',
    ),
    _MoodTip(
      icon: Icons.directions_walk,
      text: 'A short walk can reduce stress and improve mental clarity.',
    ),
    _MoodTip(
      icon: Icons.water_drop,
      text: 'Stay hydrated. Dehydration can affect mood and concentration.',
    ),
    _MoodTip(
      icon: Icons.bedtime,
      text: 'Prioritize sleep. Good rest is essential for emotional balance.',
    ),
    _MoodTip(
      icon: Icons.people,
      text: 'Connect with others. Social support improves mental well-being.',
    ),
    _MoodTip(
      icon: Icons.edit_note,
      text: 'Write down 3 things you\'re grateful for to shift perspective.',
    ),
    _MoodTip(
      icon: Icons.music_note,
      text: 'Listen to uplifting music. It can quickly change your mood.',
    ),
    _MoodTip(
      icon: Icons.spa,
      text: 'Take breaks throughout the day to prevent mental fatigue.',
    ),
    _MoodTip(
      icon: Icons.favorite,
      text: 'Practice self-compassion. Treat yourself with kindness.',
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
                        'Wellness Tip',
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

class _MoodTip {
  final IconData icon;
  final String text;

  const _MoodTip({
    required this.icon,
    required this.text,
  });
}
