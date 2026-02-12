import 'dart:convert';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class CaloriesApiService {
  final AppHttpClient _client;

  CaloriesApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
            timeout: AppConfig.instance.requestTimeout,
            maxRetries: AppConfig.instance.maxRetries,
          );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<CalorieEntryModel>> getEntriesForDate({DateTime? date}) async {
    String url = '$_baseUrl/calories';
    if (date != null) { url = '$url?date=${date.toIso8601String().split('T')[0]}'; }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CalorieEntryModel.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<CalorieEntryModel> getEntry(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/calories/$id'));
    if (response.statusCode == 200) { return CalorieEntryModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<CalorieEntryModel> createEntry(CalorieEntryModel entry) async {
    final response = await _client.post(Uri.parse('$_baseUrl/calories'), body: entry.toCreateJson());
    if (response.statusCode == 201) { return CalorieEntryModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<CalorieEntryModel> updateEntry(CalorieEntryModel entry) async {
    final response = await _client.put(Uri.parse('$_baseUrl/calories/${entry.id}'), body: entry.toUpdateJson());
    if (response.statusCode == 200) { return CalorieEntryModel.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<void> deleteEntry(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/calories/$id'));
    if (response.statusCode != 204) { throw parseErrorResponse(response); }
  }

  Future<NutritionStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/calories/stats'));
    if (response.statusCode == 200) { return NutritionStats.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<List<DailyNutritionSummary>> getHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/calories/history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DailyNutritionSummary.fromJson(json)).toList();
    } else { throw parseErrorResponse(response); }
  }

  Future<NutritionGoal> getGoal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/calories/goal'));
    if (response.statusCode == 200) { return NutritionGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }

  Future<NutritionGoal> updateGoal(NutritionGoal goal) async {
    final response = await _client.put(Uri.parse('$_baseUrl/calories/goal'), body: goal.toUpdateJson());
    if (response.statusCode == 200) { return NutritionGoal.fromJson(jsonDecode(response.body)); }
    else { throw parseErrorResponse(response); }
  }
}
