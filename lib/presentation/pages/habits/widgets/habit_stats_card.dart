import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HabitStatsCard extends StatelessWidget {
  final HabitModel habit;
  final double weeklyRate;

  const HabitStatsCard({
    super.key,
    required this.habit,
    required this.weeklyRate,
  });

  String get _motivationalMessage {
    if (habit.streak >= 30) {
      return "Incredible! You've built a lasting habit!";
    } else if (habit.streak >= 7) {
      return "Amazing consistency! Keep it going!";
    } else if (habit.streak >= 3) {
      return "Great momentum! You're building a streak!";
    } else if (habit.streak >= 1) {
      return "Good start! One day at a time.";
    } else if (weeklyRate >= 0.7) {
      return "Solid week! Try for a streak tomorrow.";
    } else if (weeklyRate >= 0.4) {
      return "Making progress! Aim higher this week.";
    } else {
      return "Every day is a chance to restart!";
    }
  }

  Color get _messageColor {
    if (habit.streak >= 7 || weeklyRate >= 0.7) {
      return AppTheme.successColor;
    } else if (habit.streak >= 1 || weeklyRate >= 0.4) {
      return AppTheme.warningColor;
    }
    return AppTheme.infoColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats title
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Statistics',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats grid
          Row(
            children: [
              Expanded(child: _buildStatItem(
                icon: Icons.calendar_today,
                iconColor: AppTheme.infoColor,
                value: habit.totalCompletions.toString(),
                label: 'Total Completions',
              )),
              Expanded(child: _buildStatItem(
                icon: Icons.local_fire_department,
                iconColor: AppTheme.primaryColor,
                value: habit.streak.toString(),
                label: 'Current Streak',
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem(
                icon: Icons.emoji_events,
                iconColor: AppTheme.warningColor,
                value: habit.bestStreak.toString(),
                label: 'Best Streak',
              )),
              Expanded(child: _buildStatItem(
                icon: Icons.percent,
                iconColor: AppTheme.successColor,
                value: '${(habit.completionRate * 100).round()}%',
                label: 'Completion Rate',
              )),
            ],
          ),
          const SizedBox(height: 16),
          // Weekly progress
          _buildWeeklyProgress(),
          const SizedBox(height: 16),
          // Streak comparison
          _buildStreakComparison(),
          const SizedBox(height: 16),
          // Motivational message
          _buildMotivationalMessage(),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
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
              'Weekly Completion',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(weeklyRate * 100).round()}%',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: weeklyRate,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(_getProgressColor(weeklyRate)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakComparison() {
    final progressTowardsBest = habit.bestStreak > 0
        ? (habit.streak / habit.bestStreak).clamp(0.0, 1.0)
        : 0.0;
    final isAtBest = habit.streak >= habit.bestStreak && habit.streak > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isAtBest
            ? const LinearGradient(
                colors: [AppTheme.warningColor, AppTheme.primaryColor],
              )
            : null,
        color: isAtBest ? null : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAtBest ? Icons.celebration : Icons.trending_up,
                color: isAtBest ? AppTheme.textOnPrimary : AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isAtBest
                    ? "You're at your best streak!"
                    : 'Progress to Best Streak',
                style: TextStyle(
                  color: isAtBest ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: isAtBest ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          if (!isAtBest) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressTowardsBest,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${habit.streak}/${habit.bestStreak}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              habit.bestStreak > habit.streak
                  ? '${habit.bestStreak - habit.streak} more days to beat your best!'
                  : 'Start a streak to make progress!',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _messageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _messageColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: _messageColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _motivationalMessage,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.successColor;
    if (progress >= 0.5) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
