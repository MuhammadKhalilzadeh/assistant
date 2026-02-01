import 'package:assistant/data/mock/models/weather_forecast_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/weather/widgets/current_weather_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/daily_forecast_widget.dart';
import 'package:assistant/presentation/pages/weather/widgets/hourly_forecast_widget.dart';
import 'package:assistant/presentation/pages/weather/widgets/sun_times_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_alerts_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_app_bar.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_details_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_stats_card.dart';
import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  bool _isSearching = false;
  String _searchQuery = '';

  late AnimationController _listAnimationController;
  late List<Animation<double>> _itemAnimations;

  WeatherForecastModel? _weather;

  @override
  void initState() {
    super.initState();
    _weather = _repository.weather;

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _initializeAnimations();
    _listAnimationController.forward();
  }

  void _initializeAnimations() {
    const itemCount = 7; // Number of animated sections
    _itemAnimations = List.generate(
      itemCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(
            index * 0.08,
            (index * 0.08 + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSearchSubmit() {
    if (_searchQuery.trim().isNotEmpty) {
      _repository.updateWeatherLocation(_searchQuery.trim());
      setState(() {
        _weather = _repository.weather;
        _isSearching = false;
        _searchQuery = '';
      });
      // Replay animations
      _listAnimationController.reset();
      _listAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    if (_weather == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.secondaryGradient,
          ),
          child: Column(
            children: [
              WeatherAppBar(
                location: _weather!.location,
                isSearching: _isSearching,
                searchQuery: _searchQuery,
                onBackPressed: () => Navigator.pop(context),
                onSearchToggle: _toggleSearch,
                onSearchChanged: _onSearchChanged,
                onSearchSubmit: _onSearchSubmit,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        CurrentWeatherCard(
                          weather: _weather!,
                          animation: _itemAnimations[0],
                        ),
                        SizedBox(height: padding),
                        WeatherDetailsCard(
                          weather: _weather!,
                          animation: _itemAnimations[1],
                        ),
                        SizedBox(height: padding),
                        HourlyForecastWidget(
                          hourlyForecast: _weather!.hourlyForecast,
                          animation: _itemAnimations[2],
                        ),
                        SizedBox(height: padding),
                        SunTimesCard(
                          sunrise: _weather!.sunrise,
                          sunset: _weather!.sunset,
                          animation: _itemAnimations[3],
                        ),
                        if (_weather!.alerts.isNotEmpty) ...[
                          SizedBox(height: padding),
                          WeatherAlertsCard(
                            alerts: _weather!.alerts,
                            animation: _itemAnimations[4],
                          ),
                        ],
                        SizedBox(height: padding),
                        DailyForecastWidget(
                          dailyForecast: _weather!.dailyForecast,
                          weather: _weather!,
                          animation: _itemAnimations[5],
                        ),
                        SizedBox(height: padding),
                        WeatherStatsCard(
                          dailyForecast: _weather!.dailyForecast,
                          animation: _itemAnimations[6],
                        ),
                        SizedBox(height: padding * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
