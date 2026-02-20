import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HabitStreakDisplay extends StatefulWidget {
  final int currentStreak;
  final int bestStreak;
  final bool compact;

  const HabitStreakDisplay({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    this.compact = false,
  });

  @override
  State<HabitStreakDisplay> createState() => _HabitStreakDisplayState();
}

class _HabitStreakDisplayState extends State<HabitStreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get _isAtBest => widget.currentStreak >= widget.bestStreak && widget.currentStreak > 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.currentStreak > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(HabitStreakDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStreak > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.currentStreak == 0 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactStreak();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.currentStreak > 0
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryLight,
                ],
              )
            : null,
        color: widget.currentStreak == 0
            ? AppTheme.cardColor
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: widget.currentStreak > 0
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Animated flame icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.currentStreak > 0
                    ? AppTheme.textOnPrimary.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_fire_department,
                color: widget.currentStreak > 0
                    ? AppTheme.textOnPrimary
                    : AppTheme.textTertiary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.currentStreak > 0
                          ? '${widget.currentStreak} Day Streak!'
                          : 'No Active Streak',
                      style: TextStyle(
                        color: widget.currentStreak > 0
                            ? AppTheme.textOnPrimary
                            : AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isAtBest) ...[
                      const SizedBox(width: 8),
                      _buildBestBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.currentStreak > 0
                      ? 'Keep up the great work!'
                      : 'Complete a habit to start a streak',
                  style: TextStyle(
                    color: widget.currentStreak > 0
                        ? AppTheme.textOnPrimary.withValues(alpha: 0.8)
                        : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Best streak
          if (!_isAtBest && widget.bestStreak > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Best',
                  style: TextStyle(
                    color: widget.currentStreak > 0
                        ? AppTheme.textOnPrimary.withValues(alpha: 0.7)
                        : AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${widget.bestStreak}',
                  style: TextStyle(
                    color: widget.currentStreak > 0
                        ? AppTheme.textOnPrimary
                        : AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactStreak() {
    if (widget.currentStreak == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: const Icon(
            Icons.local_fire_department,
            color: AppTheme.primaryColor,
            size: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.currentStreak} day streak',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        if (_isAtBest) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BEST',
              style: TextStyle(
                color: AppTheme.warningColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBestBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.warningColor, AppTheme.accentColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warningColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppTheme.textOnPrimary,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'BEST',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
