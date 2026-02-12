import 'dart:convert';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class WorkoutApiService {
  final AppHttpClient _client;

  WorkoutApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<WorkoutSessionModel>> getSessionsForDate({DateTime? date}) async {
    String url = '$_baseUrl/workouts';
    if (date != null) { url = '$url?date=${date.toIso8601String().split('T')[0]}'; }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkoutSessionModel.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<WorkoutSessionModel> getSession(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/workouts/$id'));
    if (response.statusCode == 200) { return WorkoutSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<WorkoutSessionModel> createSession(WorkoutSessionModel session) async {
    final response = await _client.post(Uri.parse('$_baseUrl/workouts'), body: session.toCreateJson());
    if (response.statusCode == 201) { return WorkoutSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<WorkoutSessionModel> updateSession(WorkoutSessionModel session) async {
    final response = await _client.put(Uri.parse('$_baseUrl/workouts/${session.id}'), body: session.toUpdateJson());
    if (response.statusCode == 200) { return WorkoutSessionModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<void> deleteSession(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/workouts/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<WorkoutStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/workouts/stats'));
    if (response.statusCode == 200) { return WorkoutStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<WorkoutDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/workouts/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkoutDailySummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<WorkoutGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/workouts/goal'));
    if (response.statusCode == 200) { return WorkoutGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<WorkoutGoal> updateGoal(WorkoutGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/workouts/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return WorkoutGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
