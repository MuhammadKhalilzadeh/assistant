import 'package:flutter/material.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Mood selector with 5 mood levels and emojis
class MoodSelector extends StatelessWidget {
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;
  final double padding;
  final Animation<double>? animation;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.padding,
    this.animation,
  });

  String _getMoodEmoji(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return '😄';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.awful:
        return '😢';
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.bad:
        return 'Bad';
      case MoodLevel.awful:
        return 'Awful';
    }
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return AppTheme.successColor;
      case MoodLevel.good:
        return AppTheme.infoColor;
      case MoodLevel.okay:
        return AppTheme.warningColor;
      case MoodLevel.bad:
        return const Color(0xFFFF9800);
      case MoodLevel.awful:
        return AppTheme.errorColor;
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
                Icons.mood,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.map((mood) {
              final isSelected = mood == selectedMood;
              final moodColor = _getMoodColor(mood);
              return _MoodChip(
                mood: mood,
                emoji: _getMoodEmoji(mood),
                label: _getMoodLabel(mood),
                color: moodColor,
                isSelected: isSelected,
                onTap: () => onMoodSelected(mood),
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

class _MoodChip extends StatelessWidget {
  final MoodLevel mood;
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : AppTheme.textTertiary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
