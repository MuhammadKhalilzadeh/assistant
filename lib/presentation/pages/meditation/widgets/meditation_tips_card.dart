import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating mindfulness tips card with tap-to-change functionality
class MeditationTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const MeditationTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<MeditationTipsCard> createState() => _MeditationTipsCardState();
}

class _MeditationTipsCardState extends State<MeditationTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_MindfulnessTip> _tips = [
    _MindfulnessTip(
      icon: Icons.air,
      text: 'Focus on your breath. Let thoughts pass like clouds in the sky.',
    ),
    _MindfulnessTip(
      icon: Icons.wb_sunny_outlined,
      text: 'Morning meditation sets a peaceful tone for your entire day.',
    ),
    _MindfulnessTip(
      icon: Icons.nightlight_round,
      text: 'Evening meditation helps release the stress of the day.',
    ),
    _MindfulnessTip(
      icon: Icons.schedule,
      text: 'Start with just 5 minutes. Consistency matters more than duration.',
    ),
    _MindfulnessTip(
      icon: Icons.chair,
      text: 'Find a comfortable position. You don\'t need to sit perfectly still.',
    ),
    _MindfulnessTip(
      icon: Icons.psychology,
      text: 'A wandering mind is normal. Gently return focus to your breath.',
    ),
    _MindfulnessTip(
      icon: Icons.favorite,
      text: 'Practice self-compassion. There\'s no "perfect" meditation.',
    ),
    _MindfulnessTip(
      icon: Icons.notifications_off,
      text: 'Create a quiet space free from distractions for deeper practice.',
    ),
    _MindfulnessTip(
      icon: Icons.nature,
      text: 'Nature sounds or silence can enhance your meditation experience.',
    ),
    _MindfulnessTip(
      icon: Icons.repeat,
      text: 'Regular practice rewires your brain for reduced stress and anxiety.',
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
                        'Mindfulness Tip',
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

class _MindfulnessTip {
  final IconData icon;
  final String text;

  const _MindfulnessTip({
    required this.icon,
    required this.text,
  });
}
