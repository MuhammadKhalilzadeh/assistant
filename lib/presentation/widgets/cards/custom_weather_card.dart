import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

enum WeatherCondition { sunny, cloudy, rainy, stormy, snowy, partlyCloudy }

class CustomWeatherCard extends StatelessWidget {
  final int temperature;
  final WeatherCondition condition;
  final int high;
  final int low;
  final String location;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
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
    this.foregroundColor,
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
                    _buildWeatherIcon(fgColor, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(fgColor, constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildHighLowBadge(bgColor, fgColor, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.1).clamp(28.0, 40.0);
    final double padding = iconSize * 0.25;
    final double containerRadius = (iconSize * 0.25).clamp(8.0, 12.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: fgColor,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: Icon(_weatherIcon, color: backgroundColor ?? primaryColor, size: iconSize),
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
          '$temperature° $_conditionText',
          style: TextStyle(
            color: fgColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          location,
          style: TextStyle(
            color: fgColor,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildHighLowBadge(Color bgColor, Color fgColor, double maxWidth) {
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
        'H:$high° L:$low°',
        style: TextStyle(
          color: bgColor,
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
