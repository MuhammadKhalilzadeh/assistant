import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/data/services/weather_api_service.dart';
import 'package:assistant/data/services/location_service.dart';
import 'package:assistant/data/cache/weather_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final weatherCacheProvider = Provider<WeatherCache>((ref) {
  return WeatherCache();
});

// API Service provider
final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

// Location Service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Weather settings provider
final weatherSettingsProvider =
    AsyncNotifierProvider<WeatherSettingsNotifier, WeatherSettings>(
        WeatherSettingsNotifier.new);

class WeatherSettingsNotifier extends AsyncNotifier<WeatherSettings> {
  @override
  Future<WeatherSettings> build() async {
    return _fetchSettings();
  }

  Future<WeatherSettings> _fetchSettings() async {
    final api = ref.read(weatherApiServiceProvider);
    final cache = ref.read(weatherCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cached = await cache.getCachedSettings();
      if (cached != null) return cached;
      throw NetworkError('No internet connection and no cached settings available');
    }

    try {
      final settings = await api.getSettings();
      await cache.cacheSettings(settings);
      return settings;
    } on NetworkError {
      final cached = await cache.getCachedSettings();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> updateSettings(WeatherSettings settings) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update settings while offline');
    }

    final api = ref.read(weatherApiServiceProvider);
    final cache = ref.read(weatherCacheProvider);
    final updated = await api.updateSettings(settings);
    state = AsyncValue.data(updated);
    await cache.cacheSettings(updated);

    // Invalidate weather data so it refreshes for the new location
    ref.invalidate(weatherProvider);
  }

  Future<void> updateLocation(double lat, double lon, String cityName) async {
    final current = state.valueOrNull;
    final unit = current?.temperatureUnit ?? 'celsius';
    await updateSettings(WeatherSettings(
      latitude: lat,
      longitude: lon,
      cityName: cityName,
      temperatureUnit: unit,
    ));
  }
}

// Main weather provider — watches settings and fetches weather for the saved location
final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherForecastModel>(
        WeatherNotifier.new);

class WeatherNotifier extends AsyncNotifier<WeatherForecastModel> {
  @override
  Future<WeatherForecastModel> build() async {
    final settings = await ref.watch(weatherSettingsProvider.future);
    return _fetchWeather(settings.latitude, settings.longitude);
  }

  Future<WeatherForecastModel> _fetchWeather(double lat, double lon) async {
    final api = ref.read(weatherApiServiceProvider);
    final cache = ref.read(weatherCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cached = await cache.getCachedWeather(lat, lon);
      if (cached != null) return cached;
      throw NetworkError('No internet connection and no cached weather available');
    }

    try {
      final weather = await api.getWeather(lat, lon);
      await cache.cacheWeather(lat, lon, weather);
      return weather;
    } on NetworkError {
      final cached = await cache.getCachedWeather(lat, lon);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> refreshWeather() async {
    final settings = await ref.read(weatherSettingsProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWeather(settings.latitude, settings.longitude));
  }

  Future<void> searchAndSetLocation(String query) async {
    final api = ref.read(weatherApiServiceProvider);
    final results = await api.searchLocation(query);
    if (results.isEmpty) return;

    final first = results.first;
    await ref.read(weatherSettingsProvider.notifier).updateLocation(
      first.latitude,
      first.longitude,
      first.displayName,
    );
  }
}

// Hourly forecast for a specific date
final weatherHourlyProvider =
    FutureProvider.family<List<HourlyForecast>, DateTime>((ref, date) async {
  final settings = await ref.watch(weatherSettingsProvider.future);
  final api = ref.read(weatherApiServiceProvider);
  final cache = ref.read(weatherCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  if (isOffline) {
    final cached = await cache.getCachedHourly(settings.latitude, settings.longitude, dateStr);
    if (cached != null) return cached;
    throw NetworkError('No internet connection and no cached hourly data available');
  }

  try {
    final hourly = await api.getHourlyForDate(settings.latitude, settings.longitude, dateStr);
    await cache.cacheHourly(settings.latitude, settings.longitude, dateStr, hourly);
    return hourly;
  } on NetworkError {
    final cached = await cache.getCachedHourly(settings.latitude, settings.longitude, dateStr);
    if (cached != null) return cached;
    rethrow;
  }
});

// Weather search provider
final weatherSearchProvider =
    FutureProvider.family<List<WeatherSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final api = ref.read(weatherApiServiceProvider);
  return api.searchLocation(query);
});

// Location permission provider
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.hasPermission();
});
