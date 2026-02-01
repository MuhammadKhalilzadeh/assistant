import 'package:assistant/data/mock/models/weather_forecast_model.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_condition_icon.dart';
import 'package:flutter/material.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;
  final Animation<double>? animation;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyForecast,
    this.animation,
  });

  String _formatHour(DateTime time) {
    final now = DateTime.now();
    if (time.hour == now.hour &&
        time.day == now.day &&
        time.month == now.month) {
      return 'Now';
    }
    final hour = time.hour;
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour > 12) return '${hour - 12} PM';
    return '$hour AM';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: const Text(
            'Hourly Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding),
            itemCount: hourlyForecast.length.clamp(0, 24),
            itemBuilder: (context, index) {
              final hourly = hourlyForecast[index];
              return _buildHourlyItem(hourly, padding, index);
            },
          ),
        ),
      ],
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation!),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildHourlyItem(HourlyForecast hourly, double padding, int index) {
    final isNow = _formatHour(hourly.time) == 'Now';

    return Container(
      width: 72,
      margin: EdgeInsets.only(right: padding / 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isNow
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatHour(hourly.time),
            style: TextStyle(
              color: Colors.white.withValues(alpha: isNow ? 1.0 : 0.7),
              fontSize: 12,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          WeatherConditionIcon(
            condition: hourly.condition,
            size: 32,
            animate: index < 3,
          ),
          Text(
            '${hourly.temperature}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hourly.precipChance > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 10,
                  color: Colors.lightBlue.shade200,
                ),
                const SizedBox(width: 2),
                Text(
                  '${hourly.precipChance}%',
                  style: TextStyle(
                    color: Colors.lightBlue.shade200,
                    fontSize: 10,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
