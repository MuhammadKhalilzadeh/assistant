import 'dart:convert';
import 'package:assistant/data/models/step_record_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class StepsApiService {
  final AppHttpClient _client;

  StepsApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<StepRecordModel?> getRecordForDate({DateTime? date}) async {
    String url = '$_baseUrl/steps';
    if (date != null) {
      url = '$url?date=${date.toIso8601String().split('T')[0]}';
    }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['id'] == null) return null;
      return StepRecordModel.fromJson(data);
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepRecordModel> getRecord(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/steps/$id'));
    if (response.statusCode == 200) {
      return StepRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepRecordModel> createRecord(StepRecordModel record) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/steps'),
      body: record.toCreateJson(),
    );
    if (response.statusCode == 201) {
      return StepRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepRecordModel> addSteps(int steps) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/steps/add'),
      body: {'steps': steps},
    );
    if (response.statusCode == 201) {
      return StepRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepRecordModel> updateRecord(StepRecordModel record) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/steps/${record.id}'),
      body: record.toUpdateJson(),
    );
    if (response.statusCode == 200) {
      return StepRecordModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<void> deleteRecord(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/steps/$id'));
    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  Future<StepsStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/steps/stats'));
    if (response.statusCode == 200) {
      return StepsStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<List<StepsDailySummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/steps/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StepsDailySummary.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepsGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/steps/goal'));
    if (response.statusCode == 200) {
      return StepsGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<StepsGoal> updateGoal(StepsGoal goal) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/steps/goal'),
      body: goal.toUpdateJson(),
    );
    if (response.statusCode == 200) {
      return StepsGoal.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
