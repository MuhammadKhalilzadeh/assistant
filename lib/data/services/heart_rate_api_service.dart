import 'dart:convert';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class HeartRateApiService {
  final AppHttpClient _client;

  HeartRateApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<HeartRateRecordModel>> getRecordsForDate({DateTime? date}) async {
    String url = '$_baseUrl/heart-rate';
    if (date != null) {
      url = '$url?date=${date.toIso8601String().split('T')[0]}';
    }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HeartRateRecordModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateRecordModel> getRecord(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/heart-rate/$id'));
    if (response.statusCode == 200) {
      return HeartRateRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateRecordModel> createRecord(HeartRateRecordModel record) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/heart-rate'),
      body: record.toCreateJson(),
    );
    if (response.statusCode == 201) {
      return HeartRateRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateRecordModel> updateRecord(HeartRateRecordModel record) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/heart-rate/${record.id}'),
      body: record.toUpdateJson(),
    );
    if (response.statusCode == 200) {
      return HeartRateRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<void> deleteRecord(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/heart-rate/$id'));
    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/heart-rate/stats'));
    if (response.statusCode == 200) {
      return HeartRateStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<List<HeartRateDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/heart-rate/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HeartRateDailySummary.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/heart-rate/goal'));
    if (response.statusCode == 200) {
      return HeartRateGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HeartRateGoal> updateGoal(HeartRateGoal goal) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/heart-rate/goal'),
      body: goal.toUpdateJson(),
    );
    if (response.statusCode == 200) {
      return HeartRateGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
