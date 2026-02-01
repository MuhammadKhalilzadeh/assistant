import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_category_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HabitItem extends StatefulWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  final int index;

  const HabitItem({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late Animation<double> _scaleAnimation;

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

  IconData get _iconData => _iconOptions[widget.habit.icon] ?? Icons.check_circle;

  Color get _categoryColor => Color(widget.habit.category.colorValue);

  @override
  void initState() {
    super.initState();
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.habit.isCompletedToday) {
      _checkAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit.isCompletedToday != oldWidget.habit.isCompletedToday) {
      if (widget.habit.isCompletedToday) {
        HapticFeedback.mediumImpact();
        _checkAnimationController.forward().then((_) {
          _checkAnimationController.reverse();
        });
      } else {
        _checkAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.habit.id),
      background: _buildSwipeBackground(
        color: const Color(0xFF10B981),
        icon: Icons.check_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: const Color(0xFFEF4444),
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - toggle complete
          _handleToggle();
          return false;
        } else {
          // Swipe left - delete with confirmation
          return await _showDeleteConfirmation();
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: widget.habit.isCompletedToday ? 0.25 : 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: widget.habit.isCompletedToday ? 0.4 : 0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Category indicator bar
                Container(
                  width: 4,
                  height: 88,
                  color: _categoryColor,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconData,
                            color: _categoryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title and info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.habit.name,
                                style: TextStyle(
                                  color: widget.habit.isCompletedToday
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: widget.habit.isCompletedToday
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Streak and category
                              Row(
                                children: [
                                  if (widget.habit.streak > 0) ...[
                                    _buildStreakBadge(),
                                    const SizedBox(width: 8),
                                  ],
                                  HabitCategoryChip(
                                    category: widget.habit.category,
                                    compact: true,
                                  ),
                                ],
                              ),
                              if (widget.habit.description != null &&
                                  widget.habit.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.habit.description!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Checkbox
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _handleToggle,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.habit.isCompletedToday
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: widget.habit.isCompletedToday
                                  ? const Icon(
                                      Icons.check,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge() {
    final isAtBest = widget.habit.streak >= widget.habit.bestStreak &&
        widget.habit.streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isAtBest
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            '${widget.habit.streak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isAtBest) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 10,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Habit'),
            content: Text(
              'Are you sure you want to delete "${widget.habit.name}"? Your streak and history will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
