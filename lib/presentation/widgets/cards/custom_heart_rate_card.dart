import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

class CustomHeartRateCard extends StatelessWidget {
  final int currentBpm;
  final int restingBpm;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final IconData icon;
  final bool enabled;

  const CustomHeartRateCard({
    super.key,
    this.currentBpm = 72,
    this.restingBpm = 65,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.favorite,
    this.enabled = true,
  });

  String get _statusText {
    if (currentBpm < 60) return 'Low';
    if (currentBpm > 100) return 'High';
    return 'Normal';
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
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildStatusBadge(bgColor, fgColor, constraints.maxWidth),
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
          '$currentBpm BPM',
          style: TextStyle(
            color: fgColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'Resting: $restingBpm BPM',
          style: TextStyle(
            color: fgColor,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(Color bgColor, Color fgColor, double maxWidth) {
    final double badgeFontSize = (maxWidth * 0.035).clamp(12.0, 16.0);
    final double horizontalPadding = (maxWidth * 0.03).clamp(10.0, 16.0);
    final double verticalPadding = (maxWidth * 0.02).clamp(6.0, 10.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusText,
        style: TextStyle(
          color: bgColor,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
