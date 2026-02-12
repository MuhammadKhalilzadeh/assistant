import 'package:flutter/material.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// 2x2 grid displaying weekly meditation statistics with animations
class MeditationStatsCard extends StatelessWidget {
  final MeditationStats stats;
  final double padding;
  final Animation<double>? animation;

  const MeditationStatsCard({
    super.key,
    required this.stats,
    required this.padding,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Stats',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.timer,
                  iconColor: AppTheme.primaryColor,
                  label: 'Total Time',
                  value: '${stats.weeklyMinutes}',
                  unit: 'min',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.repeat,
                  iconColor: AppTheme.infoColor,
                  label: 'Sessions',
                  value: '${stats.weeklySessions}',
                  unit: 'sessions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department,
                  iconColor: AppTheme.errorColor,
                  label: 'Streak',
                  value: '${stats.currentStreak}',
                  unit: 'days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.emoji_events,
                  iconColor: AppTheme.warningColor,
                  label: 'Best Streak',
                  value: '${stats.bestStreak}',
                  unit: 'days',
                ),
              ),
            ],
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

class _StatItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _scaleAnimation,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.value,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${widget.unit}',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
