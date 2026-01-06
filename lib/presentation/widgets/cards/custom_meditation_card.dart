import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class CustomMeditationCard extends StatelessWidget {
  final int minutesToday;
  final int streak;
  final VoidCallback? onTap;
  final VoidCallback? onStartPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final IconData icon;
  final bool enabled;

  const CustomMeditationCard({
    super.key,
    this.minutesToday = 0,
    this.streak = 0,
    this.onTap,
    this.onStartPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.self_improvement,
    this.enabled = true,
  });

  String get _displayText {
    if (minutesToday == 0) return 'Start meditating';
    return '$minutesToday min today';
  }

  String get _subtitleText {
    if (streak == 0) return 'Begin your journey';
    final dayText = streak == 1 ? 'day' : 'days';
    return '$streak $dayText streak';
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppTheme.primaryColor;
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
            gradient: backgroundColor == null
                ? AppTheme.secondaryGradient
                : null,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: AppTheme.cardShadow,
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
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildStartButton(bgColor, fgColor, constraints.maxWidth),
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
      child: Icon(icon, color: fgColor, size: iconSize),
    );
  }

  Widget _buildTextSection(Color fgColor, double maxWidth) {
    final double titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);
    final double subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);
    final double spacing = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _displayText,
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

  Widget _buildStartButton(Color bgColor, Color fgColor, double maxWidth) {
    final double buttonSize = (maxWidth * 0.12).clamp(40.0, 56.0);
    final double iconSize = (maxWidth * 0.06).clamp(20.0, 28.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onStartPressed : null,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: fgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow, color: bgColor, size: iconSize),
        ),
      ),
    );
  }
}
