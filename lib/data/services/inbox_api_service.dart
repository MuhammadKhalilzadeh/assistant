import 'dart:convert';
import 'package:assistant/data/models/inbox_message_model.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';

class InboxApiService {
  final AppHttpClient _client;

  InboxApiService({AppHttpClient? client})
      : _client = client ?? AppHttpClient(
          timeout: AppConfig.instance.requestTimeout,
          maxRetries: AppConfig.instance.maxRetries,
        );

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// Get all messages with optional filters
  Future<List<InboxMessage>> getMessages({String? service, bool? isRead}) async {
    String url = '$_baseUrl/inbox';
    final params = <String>[];
    if (service != null) params.add('service=$service');
    if (isRead != null) params.add('isRead=$isRead');
    if (params.isNotEmpty) url = '$url?${params.join('&')}';

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InboxMessage.fromJson(json)).toList();
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get a single message by ID
  Future<InboxMessage> getMessage(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/inbox/$id'));

    if (response.statusCode == 200) {
      return InboxMessage.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Create a new message
  Future<InboxMessage> createMessage(InboxMessage message) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/inbox'),
      body: message.toCreateJson(),
    );

    if (response.statusCode == 201) {
      return InboxMessage.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Update an existing message
  Future<InboxMessage> updateMessage(InboxMessage message) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/inbox/${message.id}'),
      body: message.toUpdateJson(),
    );

    if (response.statusCode == 200) {
      return InboxMessage.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/inbox/$id'));

    if (response.statusCode != 204) {
      throw parseErrorResponse(response);
    }
  }

  /// Mark a message as read
  Future<InboxMessage> markAsRead(String id) async {
    final response = await _client.patch(Uri.parse('$_baseUrl/inbox/$id/read'));

    if (response.statusCode == 200) {
      return InboxMessage.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Toggle star on a message
  Future<InboxMessage> toggleStar(String id) async {
    final response = await _client.patch(Uri.parse('$_baseUrl/inbox/$id/star'));

    if (response.statusCode == 200) {
      return InboxMessage.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }

  /// Get inbox statistics
  Future<InboxStats> getStats() async {
    final response = await _client.get(Uri.parse('$_baseUrl/inbox/stats'));

    if (response.statusCode == 200) {
      return InboxStats.fromJson(jsonDecode(response.body));
    } else {
      throw parseErrorResponse(response);
    }
  }
}
