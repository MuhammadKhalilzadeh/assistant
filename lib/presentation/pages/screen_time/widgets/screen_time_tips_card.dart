import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating digital wellness tips card with tap-to-change functionality
class ScreenTimeTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const ScreenTimeTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<ScreenTimeTipsCard> createState() => _ScreenTimeTipsCardState();
}

class _ScreenTimeTipsCardState extends State<ScreenTimeTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_WellnessTip> _tips = [
    _WellnessTip(
      icon: Icons.bedtime_outlined,
      text: 'Put your phone away 1 hour before bed for better sleep quality.',
    ),
    _WellnessTip(
      icon: Icons.notifications_off_outlined,
      text: 'Turn off non-essential notifications to reduce distractions.',
    ),
    _WellnessTip(
      icon: Icons.timer_outlined,
      text: 'Take a 5-minute break every hour of screen time.',
    ),
    _WellnessTip(
      icon: Icons.visibility_outlined,
      text: 'Follow the 20-20-20 rule: Every 20 min, look 20 feet away for 20 sec.',
    ),
    _WellnessTip(
      icon: Icons.lunch_dining_outlined,
      text: 'Keep meals phone-free for mindful eating and better connections.',
    ),
    _WellnessTip(
      icon: Icons.nature_people_outlined,
      text: 'Replace 30 minutes of screen time with outdoor activity daily.',
    ),
    _WellnessTip(
      icon: Icons.do_not_disturb_on_outlined,
      text: 'Use Do Not Disturb mode during focused work or family time.',
    ),
    _WellnessTip(
      icon: Icons.app_blocking_outlined,
      text: 'Set app time limits for social media and entertainment apps.',
    ),
    _WellnessTip(
      icon: Icons.phone_android_outlined,
      text: 'Create phone-free zones in your home, like the bedroom or dining area.',
    ),
    _WellnessTip(
      icon: Icons.dark_mode_outlined,
      text: 'Use night mode or blue light filters after sunset.',
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
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tip.icon,
                  color: AppTheme.infoColor,
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
                        'Digital Wellness Tip',
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

class _WellnessTip {
  final IconData icon;
  final String text;

  const _WellnessTip({
    required this.icon,
    required this.text,
  });
}
