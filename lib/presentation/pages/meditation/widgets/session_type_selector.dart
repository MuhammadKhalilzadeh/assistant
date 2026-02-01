import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/meditation_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Meditation session type selector with chips for different meditation types
class SessionTypeSelector extends StatelessWidget {
  final MeditationType? selectedType;
  final Function(MeditationType) onTypeSelected;
  final double padding;
  final Animation<double>? animation;

  const SessionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.padding,
    this.animation,
  });

  IconData _getTypeIcon(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return Icons.air;
      case MeditationType.guided:
        return Icons.headphones;
      case MeditationType.unguided:
        return Icons.self_improvement;
      case MeditationType.sleep:
        return Icons.bedtime;
      case MeditationType.focus:
        return Icons.center_focus_strong;
    }
  }

  String _getTypeLabel(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return 'Breathing';
      case MeditationType.guided:
        return 'Guided';
      case MeditationType.unguided:
        return 'Unguided';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.focus:
        return 'Focus';
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
                'Session Type',
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
            children: MeditationType.values.map((type) {
              final isSelected = type == selectedType;
              return _SessionTypeChip(
                type: type,
                icon: _getTypeIcon(type),
                label: _getTypeLabel(type),
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

class _SessionTypeChip extends StatelessWidget {
  final MeditationType type;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionTypeChip({
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
