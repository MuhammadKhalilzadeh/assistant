import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class WeatherDetailsCard extends StatelessWidget {
  final WeatherForecastModel weather;
  final Animation<double>? animation;

  const WeatherDetailsCard({
    super.key,
    required this.weather,
    this.animation,
  });

  Color _getUVColor(int uvIndex) {
    if (uvIndex <= 2) return AppTheme.successColor;
    if (uvIndex <= 5) return AppTheme.warningColor;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return AppTheme.errorColor;
    return Colors.purple;
  }

  String _getUVLabel(int uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    Widget card = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Details',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.water_drop,
                  '${weather.humidity}%',
                  'Humidity',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.air,
                  '${weather.windSpeed} km/h',
                  '${weather.windDirection} Wind',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.speed,
                  '${weather.pressure} hPa',
                  'Pressure',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUVItem(weather.uvIndex),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.visibility,
                  '${weather.visibility} km',
                  'Visibility',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.thermostat_auto,
                  '${weather.dewPoint}°',
                  'Dew Point',
                ),
              ),
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

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUVItem(int uvIndex) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _getUVColor(uvIndex),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$uvIndex',
              style: TextStyle(
                color: uvIndex <= 5 ? AppTheme.textPrimary : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getUVLabel(uvIndex),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'UV Index',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
