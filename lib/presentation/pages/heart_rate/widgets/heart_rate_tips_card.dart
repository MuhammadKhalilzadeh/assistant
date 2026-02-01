import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Rotating heart health tips card with tap-to-change functionality
class HeartRateTipsCard extends StatefulWidget {
  final double padding;
  final Animation<double>? animation;

  const HeartRateTipsCard({
    super.key,
    required this.padding,
    this.animation,
  });

  @override
  State<HeartRateTipsCard> createState() => _HeartRateTipsCardState();
}

class _HeartRateTipsCardState extends State<HeartRateTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentTipIndex = 0;

  static const List<_HeartRateTip> _tips = [
    _HeartRateTip(
      icon: Icons.directions_run,
      text: 'Regular cardio exercise strengthens your heart and lowers resting heart rate.',
    ),
    _HeartRateTip(
      icon: Icons.self_improvement,
      text: 'Deep breathing and meditation can help reduce heart rate and stress.',
    ),
    _HeartRateTip(
      icon: Icons.water_drop,
      text: 'Stay hydrated! Dehydration can cause your heart rate to increase.',
    ),
    _HeartRateTip(
      icon: Icons.coffee,
      text: 'Limit caffeine intake as it can temporarily increase heart rate.',
    ),
    _HeartRateTip(
      icon: Icons.nightlight_round,
      text: 'Quality sleep is essential for maintaining a healthy resting heart rate.',
    ),
    _HeartRateTip(
      icon: Icons.smoke_free,
      text: 'Avoiding smoking helps keep your heart rate and blood pressure in check.',
    ),
    _HeartRateTip(
      icon: Icons.restaurant,
      text: 'A balanced diet rich in omega-3s supports cardiovascular health.',
    ),
    _HeartRateTip(
      icon: Icons.monitor_weight,
      text: 'Maintaining a healthy weight reduces strain on your heart.',
    ),
    _HeartRateTip(
      icon: Icons.psychology,
      text: 'Managing stress through relaxation techniques benefits heart health.',
    ),
    _HeartRateTip(
      icon: Icons.medical_services,
      text: 'Regular health check-ups help monitor your cardiovascular health.',
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
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tip.icon,
                  color: AppTheme.errorColor,
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
                        'Heart Health Tip',
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

class _HeartRateTip {
  final IconData icon;
  final String text;

  const _HeartRateTip({
    required this.icon,
    required this.text,
  });
}
