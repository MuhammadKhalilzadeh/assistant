import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Workout history list with swipe-to-delete functionality
class WorkoutHistoryList extends StatelessWidget {
  final List<WorkoutSessionModel> workouts;
  final Function(String id) onDelete;
  final double padding;
  final Animation<double>? animation;

  const WorkoutHistoryList({
    super.key,
    required this.workouts,
    required this.onDelete,
    required this.padding,
    this.animation,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) {
      return 'Today';
    } else if (workoutDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.swimming:
        return Icons.pool;
      case WorkoutType.walking:
        return Icons.directions_walk;
      case WorkoutType.hiit:
        return Icons.flash_on;
      case WorkoutType.other:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentWorkouts = workouts.take(10).toList();

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Workouts',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (recentWorkouts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recentWorkouts.length} sessions',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentWorkouts.isEmpty)
          _buildEmptyState()
        else
          ...recentWorkouts.asMap().entries.map((entry) {
            final index = entry.key;
            final workout = entry.value;
            return _WorkoutHistoryItem(
              workout: workout,
              dateString: _formatDate(workout.startTime),
              timeString: _formatTime(workout.startTime),
              workoutIcon: _getWorkoutIcon(workout.type),
              onDelete: () => onDelete(workout.id),
              padding: padding,
              delay: index * 80,
            );
          }),
      ],
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No workouts yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start your first workout to track progress',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryItem extends StatefulWidget {
  final WorkoutSessionModel workout;
  final String dateString;
  final String timeString;
  final IconData workoutIcon;
  final VoidCallback onDelete;
  final double padding;
  final int delay;

  const _WorkoutHistoryItem({
    required this.workout,
    required this.dateString,
    required this.timeString,
    required this.workoutIcon,
    required this.onDelete,
    required this.padding,
    required this.delay,
  });

  @override
  State<_WorkoutHistoryItem> createState() => _WorkoutHistoryItemState();
}

class _WorkoutHistoryItemState extends State<_WorkoutHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(widget.workout.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onDelete();
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline,
              color: AppTheme.errorColor,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(widget.padding),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                // Icon with type
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.workoutIcon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.workout.type.name[0].toUpperCase() +
                                widget.workout.type.name.substring(1),
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.workout.durationMinutes} min',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.dateString,
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.timeString,
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.workout.caloriesBurned}',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'cal',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
