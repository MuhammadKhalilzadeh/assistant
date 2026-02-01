import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

enum WeatherCondition { sunny, cloudy, rainy, stormy, snowy, partlyCloudy }

/// A reusable weather card widget
///
/// White background with dark text and red accents.
class CustomWeatherCard extends StatelessWidget {
  final int temperature;
  final WeatherCondition condition;
  final int high;
  final int low;
  final String location;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? accentColor;
  final double borderRadius;
  final bool enabled;

  const CustomWeatherCard({
    super.key,
    this.temperature = 24,
    this.condition = WeatherCondition.sunny,
    this.high = 28,
    this.low = 18,
    this.location = 'New York',
    this.onTap,
    this.backgroundColor,
    this.accentColor,
    this.borderRadius = 20,
    this.enabled = true,
  });

  IconData get _weatherIcon {
    switch (condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.umbrella;
      case WeatherCondition.stormy:
        return Icons.thunderstorm;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
    }
  }

  String get _conditionText {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.stormy:
        return 'Stormy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
    }
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
                    _buildWeatherIcon(accent, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildHighLowBadge(accent, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(Color accent, double maxWidth) {
    final double iconSize = (maxWidth * 0.1).clamp(28.0, 40.0);
    final double padding = iconSize * 0.25;
    final double containerRadius = (iconSize * 0.25).clamp(8.0, 12.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: Icon(_weatherIcon, color: accent, size: iconSize),
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
          '$temperature° $_conditionText',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          location,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildHighLowBadge(Color accent, double maxWidth) {
    final double badgeFontSize = (maxWidth * 0.035).clamp(12.0, 16.0);
    final double horizontalPadding = (maxWidth * 0.03).clamp(10.0, 16.0);
    final double verticalPadding = (maxWidth * 0.02).clamp(6.0, 10.0);

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
        'H:$high° L:$low°',
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
