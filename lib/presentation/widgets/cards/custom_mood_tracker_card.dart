import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

enum MoodType { great, good, okay, bad, awful }

class CustomMoodTrackerCard extends StatelessWidget {
  final MoodType? currentMood;
  final int streak;
  final VoidCallback? onTap;
  final Function(MoodType)? onMoodSelected;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool enabled;

  const CustomMoodTrackerCard({
    super.key,
    this.currentMood,
    this.streak = 0,
    this.onTap,
    this.onMoodSelected,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.enabled = true,
  });

  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.great:
        return Icons.sentiment_very_satisfied;
      case MoodType.good:
        return Icons.sentiment_satisfied;
      case MoodType.okay:
        return Icons.sentiment_neutral;
      case MoodType.bad:
        return Icons.sentiment_dissatisfied;
      case MoodType.awful:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String get _titleText => currentMood == null ? 'How are you feeling?' : 'Feeling ${currentMood!.name}';

  String get _subtitleText {
    if (streak == 0) return 'Log your mood';
    final dayText = streak == 1 ? 'day' : 'days';
    return '$streak $dayText streak';
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? primaryColor;
    final Color fgColor = foregroundColor ?? Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIconWithBorder(fgColor, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(fgColor, constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    _buildMoodButtons(bgColor, fgColor, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBorder(Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: fgColor, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        currentMood != null ? _getMoodIcon(currentMood!) : Icons.emoji_emotions_outlined,
        color: fgColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildTextSection(Color fgColor, double maxWidth) {
    final double titleFontSize = (maxWidth * 0.045).clamp(14.0, 18.0);
    final double subtitleFontSize = (maxWidth * 0.035).clamp(11.0, 14.0);
    final double spacing = (maxWidth * 0.01).clamp(2.0, 6.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _titleText,
          style: TextStyle(
            color: fgColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          _subtitleText,
          style: TextStyle(
            color: fgColor,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodButtons(Color bgColor, Color fgColor, double maxWidth) {
    final double buttonSize = (maxWidth * 0.08).clamp(28.0, 36.0);
    final double iconSize = (maxWidth * 0.045).clamp(16.0, 22.0);
    final double spacing = (maxWidth * 0.01).clamp(2.0, 4.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: MoodType.values.map((mood) {
        final bool isSelected = currentMood == mood;
        return Padding(
          padding: EdgeInsets.only(left: spacing),
          child: GestureDetector(
            onTap: enabled && onMoodSelected != null ? () => onMoodSelected!(mood) : null,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: isSelected ? fgColor : fgColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getMoodIcon(mood),
                color: isSelected ? bgColor : fgColor,
                size: iconSize,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
