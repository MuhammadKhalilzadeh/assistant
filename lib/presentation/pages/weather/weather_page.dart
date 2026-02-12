import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/weather/widgets/current_weather_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/daily_forecast_widget.dart';
import 'package:assistant/presentation/pages/weather/widgets/hourly_forecast_widget.dart';
import 'package:assistant/presentation/pages/weather/widgets/sun_times_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_alerts_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_app_bar.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_details_card.dart';
import 'package:assistant/presentation/pages/weather/widgets/weather_stats_card.dart';
import 'package:assistant/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage>
    with TickerProviderStateMixin {
  bool _isSearching = false;
  String _searchQuery = '';

  late AnimationController _listAnimationController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _initializeAnimations();
    _listAnimationController.forward();
  }

  void _initializeAnimations() {
    const itemCount = 7;
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
      ref.read(weatherProvider.notifier).searchAndSetLocation(_searchQuery.trim());
      setState(() {
        _isSearching = false;
        _searchQuery = '';
      });
      _listAnimationController.reset();
      _listAnimationController.forward();
    }
  }

  Future<void> _useMyLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      // Reverse geocode: use search API to get a city name, or just use coords
      await ref.read(weatherSettingsProvider.notifier).updateLocation(
        position.latitude,
        position.longitude,
        'Current Location',
      );
      _listAnimationController.reset();
      _listAnimationController.forward();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location. Please check your location settings.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            WeatherAppBar(
              location: weatherAsync.valueOrNull?.location ?? 'Loading...',
              isSearching: _isSearching,
              searchQuery: _searchQuery,
              onBackPressed: () => Navigator.pop(context),
              onSearchToggle: _toggleSearch,
              onSearchChanged: _onSearchChanged,
              onSearchSubmit: _onSearchSubmit,
            ),
            Expanded(
              child: weatherAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: AppTheme.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load weather data',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(weatherProvider.notifier).refreshWeather(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (weather) => _buildWeatherContent(weather, padding),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherForecastModel weather, double padding) {
    return RefreshIndicator(
      onRefresh: () => ref.read(weatherProvider.notifier).refreshWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // "Use my location" button
              GestureDetector(
                onTap: _useMyLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Use my location',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: padding),
              CurrentWeatherCard(
                weather: weather,
                animation: _itemAnimations[0],
              ),
              SizedBox(height: padding),
              WeatherDetailsCard(
                weather: weather,
                animation: _itemAnimations[1],
              ),
              SizedBox(height: padding),
              HourlyForecastWidget(
                hourlyForecast: weather.hourlyForecast,
                animation: _itemAnimations[2],
              ),
              SizedBox(height: padding),
              SunTimesCard(
                sunrise: weather.sunrise,
                sunset: weather.sunset,
                animation: _itemAnimations[3],
              ),
              if (weather.alerts.isNotEmpty) ...[
                SizedBox(height: padding),
                WeatherAlertsCard(
                  alerts: weather.alerts,
                  animation: _itemAnimations[4],
                ),
              ],
              SizedBox(height: padding),
              DailyForecastWidget(
                dailyForecast: weather.dailyForecast,
                weather: weather,
                animation: _itemAnimations[5],
              ),
              SizedBox(height: padding),
              WeatherStatsCard(
                dailyForecast: weather.dailyForecast,
                animation: _itemAnimations[6],
              ),
              SizedBox(height: padding * 2),
            ],
          ),
        ),
      ),
    );
  }
}
