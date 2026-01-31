import 'package:assistant/presentation/pages/todos/widgets/todo_filters.dart';
import 'package:flutter/material.dart';

class TodoEmptyState extends StatelessWidget {
  final TodoFilter currentFilter;

  const TodoEmptyState({
    super.key,
    required this.currentFilter,
  });

  IconData get _icon {
    switch (currentFilter) {
      case TodoFilter.all:
        return Icons.checklist_rounded;
      case TodoFilter.active:
        return Icons.pending_actions_rounded;
      case TodoFilter.completed:
        return Icons.task_alt_rounded;
      case TodoFilter.today:
        return Icons.today_rounded;
      case TodoFilter.upcoming:
        return Icons.upcoming_rounded;
    }
  }

  String get _title {
    switch (currentFilter) {
      case TodoFilter.all:
        return 'No tasks yet';
      case TodoFilter.active:
        return 'No active tasks';
      case TodoFilter.completed:
        return 'No completed tasks';
      case TodoFilter.today:
        return 'No tasks for today';
      case TodoFilter.upcoming:
        return 'No upcoming tasks';
    }
  }

  String get _subtitle {
    switch (currentFilter) {
      case TodoFilter.all:
        return 'Tap + to add your first task';
      case TodoFilter.active:
        return 'All tasks are completed!';
      case TodoFilter.completed:
        return 'Complete a task to see it here';
      case TodoFilter.today:
        return 'No tasks due today';
      case TodoFilter.upcoming:
        return 'Set due dates to see upcoming tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
