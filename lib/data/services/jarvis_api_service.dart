import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:assistant/data/models/chat_message_model.dart';

/// The AI provider being used for chat
enum AiProvider { openai, anthropic }

/// Service that sends messages directly to LLM APIs using the user's own API keys.
/// Supports OpenAI and Anthropic. No backend proxy needed.
class JarvisApiService {
  final http.Client _client;
  final Duration timeout;

  static const String _systemPrompt = '''You are Jarvis, a friendly and capable personal assistant inside a health & productivity app.
You help the user manage their health, productivity, and daily life.
Keep your responses concise, helpful, and encouraging.

When the user asks you to perform an action, include an ACTION tag in your response using this exact format:
[ACTION:type:json_data]

Available actions and their JSON formats:
- Log water: [ACTION:water:{"amount_ml":500}]
- Add todo: [ACTION:todo:{"title":"Buy groceries","priority":"medium"}]
- Log mood: [ACTION:mood:{"score":4,"note":"Feeling good"}]
  (score: 1=awful, 2=bad, 3=okay, 4=good, 5=great)
- Log calories: [ACTION:calories:{"name":"Banana","calories":105,"meal_type":"snack"}]
  (meal_type: breakfast, lunch, dinner, snack)
- Start focus timer: [ACTION:focus:{"duration_minutes":25,"task":"Deep work"}]

Rules for actions:
- Only include an ACTION tag when the user clearly wants to perform one of these actions.
- Always confirm what you did in natural language alongside the tag.
- If details are missing, ask the user before adding the tag.
- You may include multiple ACTION tags if the user requests multiple actions.
- Place ACTION tags at the end of your response, after your natural language reply.''';

  // API endpoints
  static const String _openAiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String _anthropicUrl =
      'https://api.anthropic.com/v1/messages';

  // Models
  static const String _openAiModel = 'gpt-4o-mini';
  static const String _anthropicModel = 'claude-sonnet-4-20250514';

  JarvisApiService({
    http.Client? client,
    this.timeout = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  /// Send a message to the AI and get a response.
  /// [messages] is the full conversation history.
  /// [apiKey] is the user's API key for the selected provider.
  /// [provider] determines which API to call.
  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String apiKey,
    required AiProvider provider,
  }) async {
    switch (provider) {
      case AiProvider.openai:
        return _sendOpenAi(messages, apiKey);
      case AiProvider.anthropic:
        return _sendAnthropic(messages, apiKey);
    }
  }

  /// Send messages to OpenAI Chat Completions API
  Future<String> _sendOpenAi(List<ChatMessage> messages, String apiKey) async {
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ...messages
          .where((m) => m.role != MessageRole.system && !m.isError)
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              }),
    ];

    final body = jsonEncode({
      'model': _openAiModel,
      'messages': requestMessages,
      'max_tokens': 1024,
      'temperature': 0.7,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_openAiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          return message['content'] as String;
        }
        throw Exception('No response from OpenAI');
      } else {
        final errorBody = _parseErrorBody(response.body);
        debugPrint('[JarvisApi] OpenAI error ${response.statusCode}: $errorBody');
        throw Exception('OpenAI API error: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('OpenAI API error')) {
        rethrow;
      }
      debugPrint('[JarvisApi] OpenAI request failed: $e');
      throw Exception('Failed to reach OpenAI: $e');
    }
  }

  /// Send messages to Anthropic Messages API
  Future<String> _sendAnthropic(
      List<ChatMessage> messages, String apiKey) async {
    final requestMessages = messages
        .where((m) => m.role != MessageRole.system && !m.isError)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    final body = jsonEncode({
      'model': _anthropicModel,
      'max_tokens': 1024,
      'system': _systemPrompt,
      'messages': requestMessages,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_anthropicUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        if (content.isNotEmpty) {
          final textBlock = content[0] as Map<String, dynamic>;
          return textBlock['text'] as String;
        }
        throw Exception('No response from Anthropic');
      } else {
        final errorBody = _parseErrorBody(response.body);
        debugPrint(
            '[JarvisApi] Anthropic error ${response.statusCode}: $errorBody');
        throw Exception('Anthropic API error: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Anthropic API error')) {
        rethrow;
      }
      debugPrint('[JarvisApi] Anthropic request failed: $e');
      throw Exception('Failed to reach Anthropic: $e');
    }
  }

  /// Extract a human-readable error message from API error responses
  String _parseErrorBody(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      // OpenAI format: { "error": { "message": "..." } }
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          return error['message'] as String? ?? 'Unknown error';
        }
        return error.toString();
      }
      // Anthropic format: { "error": { "message": "..." } }
      return data['message'] as String? ?? 'Unknown error';
    } catch (_) {
      return body.length > 200 ? '${body.substring(0, 200)}...' : body;
    }
  }

  void close() {
    _client.close();
  }
}
