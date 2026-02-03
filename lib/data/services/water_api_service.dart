import 'dart:convert';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class WaterApiService {
  final AppHttpClient _client;

  WaterApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
          timeout: AppConfig.instance.requestTimeout,
          maxRetries: AppConfig.instance.maxRetries,
        );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// Get water logs for a specific date (defaults to today)
  Future<List<WaterLogModel>> getLogsForDate({DateTime? date}) async {
    String url = '$_baseUrl/water';
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      url = '$url?date=$dateStr';
    }

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WaterLogModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get a single water log by ID
  Future<WaterLogModel> getLog(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/water/$id'));

    if (response.statusCode == 200) {
      return WaterLogModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Create a new water log
  Future<WaterLogModel> createLog(WaterLogModel log) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/water'),
      body: log.toCreateJson(),
    );

    if (response.statusCode == 201) {
      return WaterLogModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Update an existing water log
  Future<WaterLogModel> updateLog(WaterLogModel log) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/water/${log.id}'),
      body: log.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return WaterLogModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Delete a water log
  Future<void> deleteLog(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/water/$id'));

    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  /// Get water statistics
  Future<WaterStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/water/stats'));

    if (response.statusCode == 200) {
      return WaterStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get last 7 days history
  Future<List<DailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/water/history'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DailySummary.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get hydration goal
  Future<HydrationGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/water/goal'));

    if (response.statusCode == 200) {
      return HydrationGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Update hydration goal
  Future<HydrationGoal> updateGoal(HydrationGoal goal) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/water/goal'),
      body: goal.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return HydrationGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
