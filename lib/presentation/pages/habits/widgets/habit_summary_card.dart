import 'dart:math' as math;
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HabitSummaryCard extends StatefulWidget {
  final int completedToday;
  final int totalToday;
  final int currentStreak;
  final int bestStreak;
  final double weeklyRate;

  const HabitSummaryCard({
    super.key,
    required this.completedToday,
    required this.totalToday,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyRate,
  });

  @override
  State<HabitSummaryCard> createState() => _HabitSummaryCardState();
}

class _HabitSummaryCardState extends State<HabitSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkForCelebration();
  }

  @override
  void didUpdateWidget(HabitSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedToday != oldWidget.completedToday) {
      _checkForCelebration();
    }
  }

  void _checkForCelebration() {
    final progress = widget.totalToday > 0
        ? widget.completedToday / widget.totalToday
        : 0.0;
    if (progress >= 1.0 && !_showCelebration) {
      setState(() => _showCelebration = true);
      _celebrationController.repeat();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _celebrationController.stop();
          setState(() => _showCelebration = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalToday > 0
        ? widget.completedToday / widget.totalToday
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular progress ring
              _buildProgressRing(progress),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Today's Progress",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_showCelebration) ...[
                          const SizedBox(width: 8),
                          _buildCelebrationBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.completedToday} of ${widget.totalToday} habits completed',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsRow(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekly progress bar
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double progress) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    value >= 1.0
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Percentage text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (value >= 1.0)
                    const Icon(
                      Icons.check,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.local_fire_department,
          iconColor: AppTheme.primaryColor,
          value: '${widget.currentStreak}',
          label: 'Streak',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.emoji_events,
          iconColor: AppTheme.warningColor,
          value: '${widget.bestStreak}',
          label: 'Best',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.calendar_today,
          iconColor: AppTheme.infoColor,
          value: '${(widget.weeklyRate * 100).round()}%',
          label: 'Week',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly completion',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(widget.weeklyRate * 100).round()}%',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: widget.weeklyRate),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  _getProgressColor(value),
                ),
                minHeight: 6,
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.successColor; // Green
    if (progress >= 0.5) return AppTheme.warningColor; // Amber
    return AppTheme.errorColor; // Red
  }

  Widget _buildCelebrationBadge() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_celebrationController.value * math.pi * 4) * 0.1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.warningColor, AppTheme.primaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warningColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, color: AppTheme.textOnPrimary, size: 14),
                SizedBox(width: 4),
                Text(
                  'Done!',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
