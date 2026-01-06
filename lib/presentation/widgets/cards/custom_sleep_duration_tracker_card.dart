import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable sleep duration tracker card widget
///
/// This widget displays sleep tracking information with customizable
/// duration, time range, and action callbacks. It features a red background
/// with white text and interactive elements, similar to Samsung Health's design.
class CustomSleepDurationTrackerCard extends StatelessWidget {
  /// The sleep duration to display (e.g., "11h 30m")
  final String duration;

  /// The sleep time range to display (e.g., "22:00 - 9:30")
  final String timeRange;

  /// Text for the record button
  final String recordButtonText;

  /// Callback when the record button is pressed
  final VoidCallback? onRecordPressed;

  /// Callback when the entire card is tapped
  final VoidCallback? onTap;

  /// Background color (defaults to primaryColor - red)
  final Color? backgroundColor;

  /// Foreground/text color (defaults to white)
  final Color? foregroundColor;

  /// Border radius for the card
  final double borderRadius;

  /// Icon to display
  final IconData icon;

  /// Padding inside the card
  final EdgeInsetsGeometry padding;

  /// Whether the card is enabled
  final bool enabled;

  const CustomSleepDurationTrackerCard({
    super.key,
    this.duration = '11h 30m',
    this.timeRange = '22:00 - 9:30',
    this.recordButtonText = 'Record this time',
    this.onRecordPressed,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.bed,
    this.padding = const EdgeInsets.all(20),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppTheme.primaryColor;
    final Color fgColor = foregroundColor ?? Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05; // 5% of screen width

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left section: Icon + Duration + Record Button
                    Flexible(
                      flex: 2,
                      child: _buildLeftSection(bgColor, fgColor, constraints.maxWidth),
                    ),

                    SizedBox(width: constraints.maxWidth * 0.03),

                    // Right section: Time range pill
                    Flexible(
                      flex: 1,
                      child: _buildTimeRangePill(bgColor, fgColor, constraints.maxWidth),
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

  Widget _buildLeftSection(Color bgColor, Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double fontSize = (maxWidth * 0.07).clamp(20.0, 32.0);
    final double spacing = (maxWidth * 0.03).clamp(8.0, 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon + Duration row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconWithBorder(fgColor, iconSize),
            SizedBox(width: spacing),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  duration,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        // Record button
        _buildRecordButton(bgColor, fgColor, maxWidth),
      ],
    );
  }

  Widget _buildIconWithBorder(Color fgColor, double iconSize) {
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: fgColor, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: fgColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildRecordButton(Color bgColor, Color fgColor, double maxWidth) {
    final double buttonFontSize = (maxWidth * 0.035).clamp(12.0, 16.0);
    final double horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);
    final double verticalPadding = (maxWidth * 0.025).clamp(8.0, 12.0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onRecordPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: fgColor,
          foregroundColor: bgColor,
          disabledBackgroundColor: fgColor.withValues(alpha: 0.5),
          disabledForegroundColor: bgColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            recordButtonText,
            style: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangePill(Color bgColor, Color fgColor, double maxWidth) {
    final double pillFontSize = (maxWidth * 0.06).clamp(16.0, 24.0);
    final double horizontalPadding = (maxWidth * 0.04).clamp(12.0, 20.0);
    final double verticalPadding = (maxWidth * 0.03).clamp(10.0, 16.0);

    return Container(
      constraints: BoxConstraints(
        minWidth: maxWidth * 0.25,
        maxWidth: maxWidth * 0.45,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          timeRange,
          style: TextStyle(
            color: bgColor,
            fontSize: pillFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
