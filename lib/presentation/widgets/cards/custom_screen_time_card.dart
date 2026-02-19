import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class CustomScreenTimeCard extends StatelessWidget {
  final int todayMinutes;
  final int yesterdayMinutes;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? accentColor;
  final double borderRadius;
  final IconData icon;
  final bool enabled;

  const CustomScreenTimeCard({
    super.key,
    this.todayMinutes = 0,
    this.yesterdayMinutes = 0,
    this.onTap,
    this.backgroundColor,
    this.accentColor,
    this.borderRadius = 20,
    this.icon = Icons.phone_android,
    this.enabled = true,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  bool get _isDown => todayMinutes < yesterdayMinutes;
  bool get _isUp => todayMinutes > yesterdayMinutes;

  int get _differenceMinutes => (todayMinutes - yesterdayMinutes).abs();

  String get _comparisonText {
    if (todayMinutes == yesterdayMinutes) return 'Same as yesterday';
    final diff = _formatTime(_differenceMinutes);
    return _isDown ? '$diff less' : '$diff more';
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIconWithBorder(accent, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildComparisonBadge(accent, constraints.maxWidth),
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
    final double titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);
    final double subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);
    final double spacing = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_formatTime(todayMinutes)} today',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          _comparisonText,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonBadge(Color accent, double maxWidth) {
    final double badgeSize = (maxWidth * 0.1).clamp(36.0, 48.0);
    final double iconSize = (maxWidth * 0.05).clamp(18.0, 24.0);

    IconData arrowIcon;
    if (_isDown) {
      arrowIcon = Icons.arrow_downward;
    } else if (_isUp) {
      arrowIcon = Icons.arrow_upward;
    } else {
      arrowIcon = Icons.remove;
    }

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
      ),
      child: Icon(arrowIcon, color: Colors.white, size: iconSize),
    );
  }
}
