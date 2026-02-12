import 'dart:convert';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class FocusTimerApiService {
  final AppHttpClient _client;

  FocusTimerApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<FocusSessionModel>> getSessionsForDate({DateTime? date}) async {
    String url = '$_baseUrl/focus-timer';
    if (date != null) { url = '$url?date=${date.toIso8601String().split('T')[0]}'; }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FocusSessionModel.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<FocusSessionModel> getSession(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/focus-timer/$id'));
    if (response.statusCode == 200) { return FocusSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<FocusSessionModel> createSession(FocusSessionModel session) async {
    final response = await _client.post(Uri.parse('$_baseUrl/focus-timer'), body: session.toCreateJson());
    if (response.statusCode == 201) { return FocusSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<FocusSessionModel> updateSession(FocusSessionModel session) async {
    final response = await _client.put(Uri.parse('$_baseUrl/focus-timer/${session.id}'), body: session.toUpdateJson());
    if (response.statusCode == 200) { return FocusSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<FocusSessionModel> markComplete(String id) async {
    final response = await _client.patch(Uri.parse('$_baseUrl/focus-timer/$id/complete'));
    if (response.statusCode == 200) { return FocusSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<void> deleteSession(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/focus-timer/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<FocusTimerStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/focus-timer/stats'));
    if (response.statusCode == 200) { return FocusTimerStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<FocusTimerDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/focus-timer/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FocusTimerDailySummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<FocusTimerGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/focus-timer/goal'));
    if (response.statusCode == 200) { return FocusTimerGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<FocusTimerGoal> updateGoal(FocusTimerGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/focus-timer/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return FocusTimerGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
