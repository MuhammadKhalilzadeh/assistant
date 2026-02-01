import 'package:assistant/data/mock/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_condition_icon.dart';
import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherForecastModel weather;
  final Animation<double>? animation;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.animation,
  });

  String _getConditionText(WeatherConditionType condition) {
    switch (condition) {
      case WeatherConditionType.sunny:
        return 'Sunny';
      case WeatherConditionType.cloudy:
        return 'Cloudy';
      case WeatherConditionType.rainy:
        return 'Rainy';
      case WeatherConditionType.stormy:
        return 'Stormy';
      case WeatherConditionType.snowy:
        return 'Snowy';
      case WeatherConditionType.partlyCloudy:
        return 'Partly Cloudy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    Widget card = Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeatherConditionIcon(
                condition: weather.currentCondition,
                size: 80,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: weather.currentTemperature.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.round()}°',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      );
                    },
                  ),
                  Text(
                    _getConditionText(weather.currentCondition),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeelsLike(),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.shade300,
              ),
              _buildHighLow(),
            ],
          ),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation!),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildFeelsLike() {
    return Row(
      children: [
        Icon(
          Icons.thermostat,
          color: AppTheme.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          'Feels like ${weather.feelsLike}°',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildHighLow() {
    return Row(
      children: [
        Text(
          'H: ${weather.high}°',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'L: ${weather.low}°',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
