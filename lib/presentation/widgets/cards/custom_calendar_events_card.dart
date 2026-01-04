import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

class CustomCalendarEventsCard extends StatelessWidget {
  final String nextEventTitle;
  final String nextEventTime;
  final int eventsToday;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
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
    this.foregroundColor,
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
                    if (eventsToday > 1) _buildEventsBadge(bgColor, fgColor, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    _buildAddButton(fgColor, constraints.maxWidth),
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
            color: fgColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
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

  Widget _buildEventsBadge(Color bgColor, Color fgColor, double maxWidth) {
    final double badgeFontSize = (maxWidth * 0.03).clamp(10.0, 14.0);
    final double horizontalPadding = (maxWidth * 0.02).clamp(6.0, 10.0);
    final double verticalPadding = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+${eventsToday - 1}',
        style: TextStyle(
          color: bgColor,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddButton(Color fgColor, double maxWidth) {
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
            color: fgColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: fgColor, size: iconSize),
        ),
      ),
    );
  }
}
