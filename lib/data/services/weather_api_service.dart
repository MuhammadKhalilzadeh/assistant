import 'dart:convert';
import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class WeatherApiService {
  final AppHttpClient _client;

  WeatherApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<WeatherForecastModel> getWeather(double lat, double lon) async {
    final url = '$_baseUrl/weather?lat=${lat.toStringAsFixed(4)}&lon=${lon.toStringAsFixed(4)}';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return WeatherForecastModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<List<HourlyForecast>> getHourlyForDate(double lat, double lon, String date) async {
    final url = '$_baseUrl/weather/hourly?lat=${lat.toStringAsFixed(4)}&lon=${lon.toStringAsFixed(4)}&date=$date';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HourlyForecast.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<List<WeatherSearchResult>> searchLocation(String query) async {
    final url = '$_baseUrl/weather/search?q=${Uri.encodeComponent(query)}';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WeatherSearchResult.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<WeatherSettings> getSettings() async {
    final response = await _client.get(Uri.parse('$_baseUrl/weather/settings'));
    if (response.statusCode == 200) {
      return WeatherSettings.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<WeatherSettings> updateSettings(WeatherSettings settings) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/weather/settings'),
      body: settings.toJson(),
    );
    if (response.statusCode == 200) {
      return WeatherSettings.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
