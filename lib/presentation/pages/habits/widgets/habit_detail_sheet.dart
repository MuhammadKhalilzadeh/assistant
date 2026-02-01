import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_category_chip.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_completion_calendar.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HabitDetailSheet extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleToday;
  final double weeklyRate;

  const HabitDetailSheet({
    super.key,
    required this.habit,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleToday,
    required this.weeklyRate,
  });

  static Future<void> show({
    required BuildContext context,
    required HabitModel habit,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleToday,
    required double weeklyRate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitDetailSheet(
        habit: habit,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleToday: onToggleToday,
        weeklyRate: weeklyRate,
      ),
    );
  }

  static const Map<String, IconData> _iconOptions = {
    'check_circle': Icons.check_circle,
    'fitness_center': Icons.fitness_center,
    'menu_book': Icons.menu_book,
    'self_improvement': Icons.self_improvement,
    'edit_note': Icons.edit_note,
    'water_drop': Icons.water_drop,
    'bedtime': Icons.bedtime,
    'directions_run': Icons.directions_run,
    'phone_disabled': Icons.phone_disabled,
    'phone': Icons.phone,
    'favorite': Icons.favorite,
    'work': Icons.work,
    'people': Icons.people,
    'local_cafe': Icons.local_cafe,
    'restaurant': Icons.restaurant,
    'music_note': Icons.music_note,
    'code': Icons.code,
    'brush': Icons.brush,
    'sports_soccer': Icons.sports_soccer,
    'pets': Icons.pets,
    'language': Icons.language,
    'savings': Icons.savings,
  };

  IconData get _iconData => _iconOptions[habit.icon] ?? Icons.check_circle;

  Color get _categoryColor => Color(habit.category.colorValue);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header with icon and title
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  // Quick complete button
                  _buildQuickCompleteButton(context),
                  const SizedBox(height: 24),
                  // Streak display
                  _buildStreakSection(),
                  const SizedBox(height: 24),
                  // Completion calendar
                  const Text(
                    'Completion History',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  HabitCompletionCalendar(
                    completedDates: habit.completedDates,
                    streak: habit.streak,
                    createdAt: habit.createdAt,
                  ),
                  const SizedBox(height: 24),
                  // Stats card
                  HabitStatsCard(
                    habit: habit,
                    weeklyRate: weeklyRate,
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _categoryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            _iconData,
            color: _categoryColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        // Title and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  HabitCategoryChip(
                    category: habit.category,
                    compact: true,
                  ),
                  const SizedBox(width: 8),
                  _buildFrequencyBadge(),
                ],
              ),
              if (habit.description != null &&
                  habit.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  habit.description!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            color: AppTheme.textSecondary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            habit.frequency.label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCompleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggleToday();
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: habit.isCompletedToday
              ? AppTheme.successColor.withValues(alpha: 0.1)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: habit.isCompletedToday
                ? AppTheme.successColor
                : AppTheme.primaryColor,
            width: 2,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              habit.isCompletedToday
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: habit.isCompletedToday
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              habit.isCompletedToday
                  ? 'Completed Today!'
                  : 'Mark as Complete',
              style: TextStyle(
                color: habit.isCompletedToday
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (habit.isCompletedToday) ...[
              const SizedBox(width: 8),
              Text(
                '(Tap to undo)',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    if (habit.streak == 0 && habit.bestStreak == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: AppTheme.textTertiary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No streak yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Complete this habit to start building your streak!',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isAtBest = habit.streak >= habit.bestStreak && habit.streak > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: habit.streak > 0
            ? const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              )
            : null,
        color: habit.streak == 0 ? AppTheme.cardColor : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: habit.streak > 0
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: habit.streak > 0
                  ? AppTheme.textOnPrimary.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: habit.streak > 0
                  ? AppTheme.textOnPrimary
                  : AppTheme.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      habit.streak > 0
                          ? '${habit.streak} Day Streak!'
                          : 'Streak Lost',
                      style: TextStyle(
                        color: habit.streak > 0
                            ? AppTheme.textOnPrimary
                            : AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isAtBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textOnPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: AppTheme.warningColor,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'BEST',
                              style: TextStyle(
                                color: AppTheme.textOnPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  habit.streak > 0
                      ? 'Best streak: ${habit.bestStreak} days'
                      : 'Your best was ${habit.bestStreak} days',
                  style: TextStyle(
                    color: habit.streak > 0
                        ? AppTheme.textOnPrimary.withValues(alpha: 0.8)
                        : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await _showDeleteConfirmation(context);
              if (confirm && context.mounted) {
                Navigator.pop(context);
                onDelete();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(
                color: AppTheme.errorColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Habit'),
            content: Text(
              'Are you sure you want to delete "${habit.name}"? Your streak and history will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
