import 'package:assistant/data/mock/models/weather_forecast_model.dart';
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
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Details',
            style: TextStyle(
              color: Colors.white,
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
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
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
                color: uvIndex <= 5 ? Colors.black87 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getUVLabel(uvIndex),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'UV Index',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
