import 'package:hive_flutter/hive_flutter.dart';
import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/config/app_config.dart';

class WeatherCache {
  static const _weatherBoxName = 'weather_cache';
  static const _hourlyBoxName = 'weather_hourly_cache';
  static const _settingsBoxName = 'weather_settings_cache';

  Box? _weatherBox;
  Box? _hourlyBox;
  Box? _settingsBox;

  Future<void> init() async {
    _weatherBox = await Hive.openBox(_weatherBoxName);
    _hourlyBox = await Hive.openBox(_hourlyBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  String _weatherKey(double lat, double lon) =>
      '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  String _hourlyKey(double lat, double lon, String date) =>
      '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)},$date';

  // ---- Weather forecast ----

  Future<WeatherForecastModel?> getCachedWeather(double lat, double lon) async {
    final box = _weatherBox ?? await Hive.openBox(_weatherBoxName);
    final key = _weatherKey(lat, lon);

    final timestampMs = box.get('${key}_ts') as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;
    if (DateTime.now().difference(timestamp) > ttl) return null;

    final data = box.get(key);
    if (data == null) return null;

    try {
      return WeatherForecastModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      await box.delete(key);
      await box.delete('${key}_ts');
      return null;
    }
  }

  Future<void> cacheWeather(double lat, double lon, WeatherForecastModel weather) async {
    final box = _weatherBox ?? await Hive.openBox(_weatherBoxName);
    final key = _weatherKey(lat, lon);
    await box.put(key, weather.toJson());
    await box.put('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ---- Hourly by date ----

  Future<List<HourlyForecast>?> getCachedHourly(double lat, double lon, String date) async {
    final box = _hourlyBox ?? await Hive.openBox(_hourlyBoxName);
    final key = _hourlyKey(lat, lon, date);

    final timestampMs = box.get('${key}_ts') as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;
    if (DateTime.now().difference(timestamp) > ttl) return null;

    final data = box.get(key) as List<dynamic>?;
    if (data == null) return null;

    try {
      return data
          .map((e) => HourlyForecast.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      await box.delete(key);
      await box.delete('${key}_ts');
      return null;
    }
  }

  Future<void> cacheHourly(double lat, double lon, String date, List<HourlyForecast> hourly) async {
    final box = _hourlyBox ?? await Hive.openBox(_hourlyBoxName);
    final key = _hourlyKey(lat, lon, date);
    await box.put(key, hourly.map((h) => h.toJson()).toList());
    await box.put('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ---- Settings ----

  Future<WeatherSettings?> getCachedSettings() async {
    final box = _settingsBox ?? await Hive.openBox(_settingsBoxName);

    final timestampMs = box.get('settings_ts') as int?;
    if (timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final ttl = AppConfig.instance.cacheTtl;
    if (DateTime.now().difference(timestamp) > ttl) return null;

    final data = box.get('settings');
    if (data == null) return null;

    try {
      return WeatherSettings.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      await box.delete('settings');
      await box.delete('settings_ts');
      return null;
    }
  }

  Future<void> cacheSettings(WeatherSettings settings) async {
    final box = _settingsBox ?? await Hive.openBox(_settingsBoxName);
    await box.put('settings', settings.toJson());
    await box.put('settings_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ---- Utilities ----

  Future<void> clearAll() async {
    final weatherBox = _weatherBox ?? await Hive.openBox(_weatherBoxName);
    final hourlyBox = _hourlyBox ?? await Hive.openBox(_hourlyBoxName);
    final settingsBox = _settingsBox ?? await Hive.openBox(_settingsBoxName);
    await weatherBox.clear();
    await hourlyBox.clear();
    await settingsBox.clear();
  }

  Future<bool> hasCachedData() async {
    final box = _weatherBox ?? await Hive.openBox(_weatherBoxName);
    return box.isNotEmpty;
  }
}
