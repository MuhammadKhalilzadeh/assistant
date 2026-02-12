import 'package:flutter/material.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Workout type selector with chips for different exercise types
class WorkoutTypeSelector extends StatelessWidget {
  final WorkoutType? selectedType;
  final Function(WorkoutType) onTypeSelected;
  final double padding;
  final Animation<double>? animation;

  const WorkoutTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.padding,
    this.animation,
  });

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

  String _getWorkoutLabel(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return 'Run';
      case WorkoutType.cycling:
        return 'Cycle';
      case WorkoutType.strength:
        return 'Strength';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.swimming:
        return 'Swim';
      case WorkoutType.walking:
        return 'Walk';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.other:
        return 'Other';
    }
  }

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
                Icons.category_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Workout Type',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WorkoutType.values.map((type) {
              final isSelected = type == selectedType;
              return _WorkoutTypeChip(
                type: type,
                icon: _getWorkoutIcon(type),
                label: _getWorkoutLabel(type),
                isSelected: isSelected,
                onTap: () => onTypeSelected(type),
              );
            }).toList(),
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

class _WorkoutTypeChip extends StatelessWidget {
  final WorkoutType type;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkoutTypeChip({
    required this.type,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.textTertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
