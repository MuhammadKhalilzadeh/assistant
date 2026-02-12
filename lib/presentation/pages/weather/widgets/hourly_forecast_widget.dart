import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
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
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              color: AppTheme.textPrimary,
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
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: isNow
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatHour(hourly.time),
            style: TextStyle(
              color: isNow ? AppTheme.primaryColor : AppTheme.textSecondary,
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
            style: TextStyle(
              color: AppTheme.textPrimary,
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
                  color: AppTheme.infoColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${hourly.precipChance}%',
                  style: TextStyle(
                    color: AppTheme.infoColor,
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
