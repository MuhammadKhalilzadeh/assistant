import 'package:assistant/presentation/pages/habits/widgets/habit_filters.dart';
import 'package:flutter/material.dart';

class HabitEmptyState extends StatelessWidget {
  final HabitFilter currentFilter;
  final bool hasAnyHabits;
  final String? searchQuery;

  const HabitEmptyState({
    super.key,
    required this.currentFilter,
    required this.hasAnyHabits,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final content = _getContent();

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              content.icon,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            content.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            content.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Tip
          if (content.tip != null) _buildTip(content.tip!),
        ],
      ),
    );
  }

  _EmptyStateContent _getContent() {
    // Search query case
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return _EmptyStateContent(
        icon: Icons.search_off,
        title: 'No habits found',
        description: 'No habits match "$searchQuery".\nTry a different search term.',
        tip: 'Tip: Search by habit name to find what you\'re looking for.',
      );
    }

    // First time user - no habits at all
    if (!hasAnyHabits) {
      return _EmptyStateContent(
        icon: Icons.track_changes,
        title: 'Welcome to Habits!',
        description: 'Build lasting habits and track your progress over time.',
        tip: 'Tip: Start with just one or two habits. Small steps lead to big changes!',
      );
    }

    // Filter-specific empty states
    switch (currentFilter) {
      case HabitFilter.all:
        return _EmptyStateContent(
          icon: Icons.list_alt,
          title: 'No habits yet',
          description: 'Create your first habit to start building better routines.',
          tip: 'Tip: Start with habits you want to do daily.',
        );

      case HabitFilter.completed:
        return _EmptyStateContent(
          icon: Icons.check_circle_outline,
          title: 'No completed habits today',
          description: 'You haven\'t completed any habits yet.\nStart checking them off!',
          tip: 'Tip: Try completing your easiest habit first to build momentum.',
        );

      case HabitFilter.inProgress:
        return _EmptyStateContent(
          icon: Icons.celebration,
          title: 'All done for today!',
          description: 'Amazing! You\'ve completed all your habits for today.',
          tip: 'Keep up the great work! Consistency is key to lasting change.',
        );

      case HabitFilter.streaks:
        return _EmptyStateContent(
          icon: Icons.local_fire_department,
          title: 'No active streaks',
          description: 'Complete habits consistently to build streaks.',
          tip: 'Tip: A streak begins when you complete the same habit on consecutive days.',
        );
    }
  }

  Widget _buildTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateContent {
  final IconData icon;
  final String title;
  final String description;
  final String? tip;

  const _EmptyStateContent({
    required this.icon,
    required this.title,
    required this.description,
    this.tip,
  });
}
