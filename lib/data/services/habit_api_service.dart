import 'dart:convert';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/models/habit_stats.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class HabitApiService {
  final AppHttpClient _client;

  HabitApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
          timeout: AppConfig.instance.requestTimeout,
          maxRetries: AppConfig.instance.maxRetries,
        );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<HabitModel>> getHabits() async {
    final response = await _client.get(Uri.parse('$_baseUrl/habits'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HabitModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HabitModel> getHabit(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/habits/$id'));

    if (response.statusCode == 200) {
      return HabitModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HabitModel> createHabit(HabitModel habit) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/habits'),
      body: habit.toCreateJson(),
    );

    if (response.statusCode == 201) {
      return HabitModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HabitModel> updateHabit(HabitModel habit) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/habits/${habit.id}'),
      body: habit.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return HabitModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<void> deleteHabit(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/habits/$id'));

    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  Future<HabitModel> toggleComplete(String id) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/habits/$id/toggle'),
    );

    if (response.statusCode == 200) {
      return HabitModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<HabitStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/habits/stats'));

    if (response.statusCode == 200) {
      return HabitStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
