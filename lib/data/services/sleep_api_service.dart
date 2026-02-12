import 'dart:convert';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class SleepApiService {
  final AppHttpClient _client;

  SleepApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<SleepRecordModel>> getRecordsForDate({DateTime? date}) async {
    String url = '$_baseUrl/sleep';
    if (date != null) { url = '$url?date=${date.toIso8601String().split('T')[0]}'; }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SleepRecordModel.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<SleepRecordModel> getRecord(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/sleep/$id'));
    if (response.statusCode == 200) { return SleepRecordModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<SleepRecordModel> createRecord(SleepRecordModel record) async {
    final response = await _client.post(Uri.parse('$_baseUrl/sleep'), body: record.toCreateJson());
    if (response.statusCode == 201) { return SleepRecordModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<SleepRecordModel> updateRecord(SleepRecordModel record) async {
    final response = await _client.put(Uri.parse('$_baseUrl/sleep/${record.id}'), body: record.toUpdateJson());
    if (response.statusCode == 200) { return SleepRecordModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<void> deleteRecord(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/sleep/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<SleepStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/sleep/stats'));
    if (response.statusCode == 200) { return SleepStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<SleepDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/sleep/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SleepDailySummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<SleepGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/sleep/goal'));
    if (response.statusCode == 200) { return SleepGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<SleepGoal> updateGoal(SleepGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/sleep/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return SleepGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
