import 'dart:convert';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class MoodApiService {
  final AppHttpClient _client;

  MoodApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<MoodEntryModel>> getEntriesForDate({DateTime? date}) async {
    String url = '$_baseUrl/mood';
    if (date != null) {
      url = '$url?date=${date.toIso8601String().split('T')[0]}';
    }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MoodEntryModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<MoodEntryModel> getEntry(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/mood/$id'));
    if (response.statusCode == 200) {
      return MoodEntryModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<MoodEntryModel> createEntry(MoodEntryModel entry) async {
    final response = await _client.post(Uri.parse('$_baseUrl/mood'), body: entry.toCreateJson());
    if (response.statusCode == 201) {
      return MoodEntryModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<MoodEntryModel> updateEntry(MoodEntryModel entry) async {
    final response = await _client.put(Uri.parse('$_baseUrl/mood/${entry.id}'), body: entry.toUpdateJson());
    if (response.statusCode == 200) {
      return MoodEntryModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<void> deleteEntry(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/mood/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<MoodStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/mood/stats'));
    if (response.statusCode == 200) { return MoodStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<MoodDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/mood/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MoodDailySummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<MoodGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/mood/goal'));
    if (response.statusCode == 200) { return MoodGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<MoodGoal> updateGoal(MoodGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/mood/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return MoodGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
