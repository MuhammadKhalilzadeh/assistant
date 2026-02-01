import 'package:assistant/data/mock/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_condition_icon.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_detail_sheet.dart';
import 'package:flutter/material.dart';

class DailyForecastWidget extends StatefulWidget {
  final List<DailyForecast> dailyForecast;
  final WeatherForecastModel weather;
  final Animation<double>? animation;

  const DailyForecastWidget({
    super.key,
    required this.dailyForecast,
    required this.weather,
    this.animation,
  });

  @override
  State<DailyForecastWidget> createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemAnimations = List.generate(
      widget.dailyForecast.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            index * 0.1,
            (index * 0.1 + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Forecast',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.dailyForecast.length, (index) {
          final daily = widget.dailyForecast[index];
          return AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _itemAnimations[index].value)),
                child: Opacity(
                  opacity: _itemAnimations[index].value,
                  child: _buildDailyItem(daily, padding, index),
                ),
              );
            },
          );
        }),
      ],
    );

    if (widget.animation != null) {
      return FadeTransition(
        opacity: widget.animation!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildDailyItem(DailyForecast daily, double padding, int index) {
    final maxHigh = widget.dailyForecast.map((d) => d.high).reduce((a, b) => a > b ? a : b);
    final minLow = widget.dailyForecast.map((d) => d.low).reduce((a, b) => a < b ? a : b);
    final tempRange = maxHigh - minLow;

    return GestureDetector(
      onTap: () => WeatherDetailSheet.show(context, daily, widget.weather),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                _formatDay(daily.date),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            WeatherConditionIcon(
              condition: daily.condition,
              size: 28,
              animate: false,
            ),
            const SizedBox(width: 8),
            if (daily.precipChance > 0) ...[
              Icon(
                Icons.water_drop,
                size: 12,
                color: AppTheme.infoColor,
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: 32,
                child: Text(
                  '${daily.precipChance}%',
                  style: TextStyle(
                    color: AppTheme.infoColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else
              const SizedBox(width: 46),
            const SizedBox(width: 8),
            Text(
              '${daily.low}°',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTemperatureBar(daily, minLow, tempRange),
            ),
            const SizedBox(width: 8),
            Text(
              '${daily.high}°',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureBar(DailyForecast daily, int minLow, int tempRange) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final lowOffset = (daily.low - minLow) / tempRange;
        final highOffset = (daily.high - minLow) / tempRange;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: barWidth * lowOffset * value,
                    right: barWidth * (1 - highOffset) * value,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.infoColor,
                            AppTheme.primaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
