import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class WeatherStatsCard extends StatelessWidget {
  final List<DailyForecast> dailyForecast;
  final Animation<double>? animation;

  const WeatherStatsCard({
    super.key,
    required this.dailyForecast,
    this.animation,
  });

  Map<String, dynamic> _calculateStats() {
    if (dailyForecast.isEmpty) {
      return {
        'avgHigh': 0,
        'avgLow': 0,
        'rainiestDay': null,
        'rainiestChance': 0,
        'bestDay': null,
      };
    }

    final avgHigh = dailyForecast.map((d) => d.high).reduce((a, b) => a + b) ~/
        dailyForecast.length;
    final avgLow = dailyForecast.map((d) => d.low).reduce((a, b) => a + b) ~/
        dailyForecast.length;

    DailyForecast? rainiestDay;
    int maxPrecip = 0;
    DailyForecast? bestDay;
    int bestScore = -1;

    for (final day in dailyForecast) {
      if (day.precipChance > maxPrecip) {
        maxPrecip = day.precipChance;
        rainiestDay = day;
      }

      // Best day = sunny/partly cloudy with low precip and moderate UV
      int score = 0;
      if (day.condition == WeatherConditionType.sunny) score += 3;
      if (day.condition == WeatherConditionType.partlyCloudy) score += 2;
      if (day.precipChance < 20) score += 2;
      if (day.uvIndex >= 4 && day.uvIndex <= 7) score += 1;

      if (score > bestScore) {
        bestScore = score;
        bestDay = day;
      }
    }

    return {
      'avgHigh': avgHigh,
      'avgLow': avgLow,
      'rainiestDay': rainiestDay,
      'rainiestChance': maxPrecip,
      'bestDay': bestDay,
    };
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final stats = _calculateStats();

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
            'Weekly Summary',
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
                child: _buildStatItem(
                  Icons.thermostat,
                  'Avg High',
                  '${stats['avgHigh']}°',
                  AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.thermostat_outlined,
                  'Avg Low',
                  '${stats['avgLow']}°',
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDayStatItem(
                  Icons.water_drop,
                  'Rainiest',
                  stats['rainiestDay'] != null
                      ? _formatDay((stats['rainiestDay'] as DailyForecast).date)
                      : '-',
                  '${stats['rainiestChance']}%',
                  AppTheme.infoColor,
                ),
              ),
              Expanded(
                child: _buildDayStatItem(
                  Icons.wb_sunny,
                  'Best Weather',
                  stats['bestDay'] != null
                      ? _formatDay((stats['bestDay'] as DailyForecast).date)
                      : '-',
                  null,
                  AppTheme.warningColor,
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

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: double.tryParse(value.replaceAll('°', '')) ?? 0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Text(
                    '${animValue.round()}°',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayStatItem(
    IconData icon,
    String label,
    String day,
    String? subValue,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subValue != null)
                  Text(
                    subValue,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
