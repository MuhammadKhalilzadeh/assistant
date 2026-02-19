import 'dart:convert';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class ScreenTimeApiService {
  final AppHttpClient _client;

  ScreenTimeApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
          timeout: AppConfig.instance.requestTimeout,
          maxRetries: AppConfig.instance.maxRetries,
        );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// Get screen time record for a specific date (defaults to today)
  Future<ScreenTimeRecord?> getByDate({DateTime? date}) async {
    String url = '$_baseUrl/screen-time';
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      url = '$url?date=$dateStr';
    }

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null) return null;
      return ScreenTimeRecord.fromJson(data);
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get a single record by ID
  Future<ScreenTimeRecord> getById(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/screen-time/$id'));

    if (response.statusCode == 200) {
      return ScreenTimeRecord.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Create or upsert a screen time record
  Future<ScreenTimeRecord> createRecord(ScreenTimeRecord record) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/screen-time'),
      body: record.toCreateJson(),
    );

    if (response.statusCode == 201) {
      return ScreenTimeRecord.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Update an existing record
  Future<ScreenTimeRecord> updateRecord(ScreenTimeRecord record) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/screen-time/${record.id}'),
      body: {
        'totalMinutes': record.totalMinutes,
        'pickups': record.pickups,
        'note': record.note,
        'appUsage': record.appUsage.map((a) => a.toCreateJson()).toList(),
      },
    );

    if (response.statusCode == 200) {
      return ScreenTimeRecord.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Delete a record
  Future<void> deleteRecord(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/screen-time/$id'));

    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  /// Get screen time statistics
  Future<ScreenTimeStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/screen-time/stats'));

    if (response.statusCode == 200) {
      return ScreenTimeStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get last 7 days history
  Future<List<ScreenTimeDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/screen-time/history'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ScreenTimeDailySummary.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get screen time goal
  Future<ScreenTimeGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/screen-time/goal'));

    if (response.statusCode == 200) {
      return ScreenTimeGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Update screen time goal
  Future<ScreenTimeGoal> updateGoal(ScreenTimeGoal goal) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/screen-time/goal'),
      body: goal.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return ScreenTimeGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
