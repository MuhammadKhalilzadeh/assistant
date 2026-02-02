import 'dart:convert';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/category_model.dart';
import 'package:assistant/data/models/todo_stats.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class TodoApiService {
  final AppHttpClient _client;

  TodoApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
          timeout: AppConfig.instance.requestTimeout,
          maxRetries: AppConfig.instance.maxRetries,
        );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Future<List<TodoModel>> getTodos() async {
    final response = await _client.get(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<TodoModel> getTodo(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/todos/$id'));

    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/todos'),
      body: todo.toCreateJson(),
    );

    if (response.statusCode == 201) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<TodoModel> updateTodo(TodoModel todo) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/todos/${todo.id}'),
      body: todo.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/todos/$id'));

    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  Future<TodoModel> toggleComplete(String id) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/todos/$id/toggle'),
    );

    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<TodoStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/todos/stats'));

    if (response.statusCode == 200) {
      return TodoStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }
}
