import 'dart:convert';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class MeditationApiService {
  final AppHttpClient _client;

  MeditationApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<MeditationSessionModel>> getSessionsForDate({DateTime? date}) async {
    String url = '$_baseUrl/meditation';
    if (date != null) { url = '$url?date=${date.toIso8601String().split('T')[0]}'; }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MeditationSessionModel.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<MeditationSessionModel> getSession(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/meditation/$id'));
    if (response.statusCode == 200) { return MeditationSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<MeditationSessionModel> createSession(MeditationSessionModel session) async {
    final response = await _client.post(Uri.parse('$_baseUrl/meditation'), body: session.toCreateJson());
    if (response.statusCode == 201) { return MeditationSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<MeditationSessionModel> updateSession(MeditationSessionModel session) async {
    final response = await _client.put(Uri.parse('$_baseUrl/meditation/${session.id}'), body: session.toUpdateJson());
    if (response.statusCode == 200) { return MeditationSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<MeditationSessionModel> markComplete(String id) async {
    final response = await _client.patch(Uri.parse('$_baseUrl/meditation/$id/complete'));
    if (response.statusCode == 200) { return MeditationSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<void> deleteSession(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/meditation/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<MeditationStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/meditation/stats'));
    if (response.statusCode == 200) { return MeditationStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<MeditationDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/meditation/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MeditationDailySummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<MeditationGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/meditation/goal'));
    if (response.statusCode == 200) { return MeditationGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<MeditationGoal> updateGoal(MeditationGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/meditation/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return MeditationGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
