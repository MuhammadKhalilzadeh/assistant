import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable steps tracker card widget
///
/// This widget displays step tracking information with customizable
/// current steps, goal, and progress visualization. It features a white background
/// with dark text and red accents.
class CustomStepsTrackerCard extends StatelessWidget {
  /// Current number of steps
  final int currentSteps;

  /// Goal number of steps
  final int goalSteps;

  /// Label for steps (e.g., "Steps")
  final String stepsLabel;

  /// Prefix for goal text (e.g., "Out of")
  final String goalPrefix;

  /// Suffix for goal text (e.g., "steps")
  final String goalSuffix;

  /// Callback when the entire card is tapped
  final VoidCallback? onTap;

  /// Background color (defaults to white)
  final Color? backgroundColor;

  /// Accent color for icons and highlights (defaults to primaryColor - red)
  final Color? accentColor;

  /// Color for the progress bar fill
  final Color? progressColor;

  /// Border radius for the card
  final double borderRadius;

  /// Icon to display
  final IconData icon;

  /// Whether the card is enabled
  final bool enabled;

  const CustomStepsTrackerCard({
    super.key,
    this.currentSteps = 1000,
    this.goalSteps = 6000,
    this.stepsLabel = 'Steps',
    this.goalPrefix = 'Out of',
    this.goalSuffix = 'steps',
    this.onTap,
    this.backgroundColor,
    this.accentColor,
    this.progressColor,
    this.borderRadius = 20,
    this.icon = Icons.directions_walk,
    this.enabled = true,
  });

  /// Calculate progress as a value between 0.0 and 1.0
  double get progress => goalSteps > 0
      ? (currentSteps / goalSteps).clamp(0.0, 1.0)
      : 0.0;

  /// Calculate percentage as an integer
  int get percentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? AppTheme.primaryColor;
    // Accent with 50% opacity for progress fill
    final Color progColor = progressColor ??
        accent.withValues(alpha: 0.5);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.cardBorderColor, width: 1),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left section: Icon + Steps count + Goal
                    _buildLeftSection(accent, constraints.maxWidth),

                    // Spacer to push progress bar to the far right
                    const Spacer(),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Right section: Progress bar + Percentage
                    Expanded(
                      flex: 4,
                      child: _buildRightSection(accent, progColor, constraints.maxWidth),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSection(Color accent, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double fontSize = (maxWidth * 0.07).clamp(20.0, 32.0);
    final double smallFontSize = (maxWidth * 0.04).clamp(12.0, 18.0);
    final double spacing = (maxWidth * 0.03).clamp(8.0, 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon + Steps count row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconWithBorder(accent, iconSize),
            SizedBox(width: spacing),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$currentSteps $stepsLabel',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.5),
        // Goal text
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '$goalPrefix $goalSteps $goalSuffix',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: smallFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconWithBorder(Color accent, double iconSize) {
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: accent,
        size: iconSize,
      ),
    );
  }

  Widget _buildRightSection(Color accent, Color progColor, double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar - fills available width
        _buildProgressBar(accent, progColor),
        SizedBox(height: (maxWidth * 0.02).clamp(6.0, 10.0)),
        // Percentage badge
        _buildPercentageBadge(accent, maxWidth),
      ],
    );
  }

  Widget _buildProgressBar(Color accent, Color progColor) {
    final double barHeight = 20.0.clamp(16.0, 28.0);
    final double barBorderRadius = barHeight / 2;
    final double borderWidth = 2.5;

    return SizedBox(
      width: double.infinity,
      height: barHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: accent,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(barBorderRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            return Stack(
              children: [
                // Progress fill
                Positioned(
                  left: borderWidth,
                  top: borderWidth,
                  bottom: borderWidth,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (barWidth - (borderWidth * 2)) * progress,
                    decoration: BoxDecoration(
                      color: progColor,
                      borderRadius: BorderRadius.circular(barBorderRadius - borderWidth),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPercentageBadge(Color accent, double maxWidth) {
    final double badgeFontSize = (maxWidth * 0.035).clamp(12.0, 16.0);
    final double horizontalPadding = (maxWidth * 0.025).clamp(8.0, 12.0);
    final double verticalPadding = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
