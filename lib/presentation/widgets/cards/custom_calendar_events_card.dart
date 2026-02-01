import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable calendar events card widget
///
/// White background with dark text and red accents.
class CustomCalendarEventsCard extends StatelessWidget {
  final String nextEventTitle;
  final String nextEventTime;
  final int eventsToday;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final Color? backgroundColor;
  final Color? accentColor;
  final double borderRadius;
  final IconData icon;
  final bool enabled;

  const CustomCalendarEventsCard({
    super.key,
    this.nextEventTitle = 'No events',
    this.nextEventTime = '',
    this.eventsToday = 0,
    this.onTap,
    this.onAddPressed,
    this.backgroundColor,
    this.accentColor,
    this.borderRadius = 20,
    this.icon = Icons.calendar_today,
    this.enabled = true,
  });

  String get _subtitleText {
    if (eventsToday == 0) return 'No events today';
    if (nextEventTime.isEmpty) return '$eventsToday events today';
    return nextEventTime;
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? AppTheme.primaryColor;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
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
                    _buildIconWithBorder(accent, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    if (eventsToday > 1)
                      _buildEventsBadge(accent, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    _buildAddButton(accent, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBorder(Color accent, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: accent, size: iconSize),
    );
  }

  Widget _buildTextSection(double maxWidth) {
    final double titleFontSize = (maxWidth * 0.05).clamp(14.0, 20.0);
    final double subtitleFontSize = (maxWidth * 0.035).clamp(11.0, 15.0);
    final double spacing = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          nextEventTitle,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: spacing),
        Text(
          _subtitleText,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEventsBadge(Color accent, double maxWidth) {
    final double badgeFontSize = (maxWidth * 0.03).clamp(10.0, 14.0);
    final double horizontalPadding = (maxWidth * 0.02).clamp(6.0, 10.0);
    final double verticalPadding = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+${eventsToday - 1}',
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddButton(Color accent, double maxWidth) {
    final double buttonSize = (maxWidth * 0.1).clamp(36.0, 48.0);
    final double iconSize = (maxWidth * 0.05).clamp(18.0, 24.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onAddPressed : null,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: accent, size: iconSize),
        ),
      ),
    );
  }
}
