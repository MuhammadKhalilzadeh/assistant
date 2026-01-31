import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class TodoItem extends StatefulWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final int index;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    this.index = 0,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late Animation<double> _scaleAnimation;

  // Priority colors
  static const Color highPriorityColor = Color(0xFFEF4444);
  static const Color mediumPriorityColor = Color(0xFFF59E0B);
  static const Color lowPriorityColor = Color(0xFF10B981);

  Color get _priorityColor {
    switch (widget.todo.priority) {
      case 1:
        return highPriorityColor;
      case 2:
        return mediumPriorityColor;
      case 3:
        return lowPriorityColor;
      default:
        return mediumPriorityColor;
    }
  }

  String get _priorityLabel {
    switch (widget.todo.priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Medium';
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.todo.isCompleted) {
      _checkAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TodoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todo.isCompleted != oldWidget.todo.isCompleted) {
      if (widget.todo.isCompleted) {
        _checkAnimationController.forward();
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

  String _getRelativeDueDate() {
    final dueDate = widget.todo.dueDate;
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDateOnly.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      return 'In $difference days';
    } else {
      return '${dueDate.day}/${dueDate.month}';
    }
  }

  bool get _isOverdue {
    final dueDate = widget.todo.dueDate;
    if (dueDate == null || widget.todo.isCompleted) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDateOnly.isBefore(today);
  }

  void _handleToggle() {
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id),
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
        onLongPress: widget.onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Priority indicator bar
                Container(
                  width: 4,
                  height: 80,
                  color: _priorityColor,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Checkbox
                        GestureDetector(
                          onTap: _handleToggle,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.todo.isCompleted
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: widget.todo.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: AppTheme.primaryColor,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title and description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.todo.title,
                                style: TextStyle(
                                  color: widget.todo.isCompleted
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: widget.todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.todo.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.todo.description!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              // Tags row
                              Row(
                                children: [
                                  // Priority tag
                                  _buildTag(
                                    icon: Icons.flag_rounded,
                                    label: _priorityLabel,
                                    color: _priorityColor,
                                  ),
                                  // Due date tag
                                  if (widget.todo.dueDate != null) ...[
                                    const SizedBox(width: 8),
                                    _buildTag(
                                      icon: Icons.calendar_today_rounded,
                                      label: _getRelativeDueDate(),
                                      color: _isOverdue
                                          ? const Color(0xFFEF4444)
                                          : Colors.white,
                                      isOverdue: _isOverdue,
                                    ),
                                  ],
                                ],
                              ),
                            ],
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

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    bool isOverdue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isOverdue ? color : Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isOverdue ? color : Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
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
            title: const Text('Delete Task'),
            content:
                const Text('Are you sure you want to delete this task?'),
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
