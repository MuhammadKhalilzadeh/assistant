import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:assistant/data/models/chat_message_model.dart';

/// The AI provider being used for chat
enum AiProvider {
  openai,
  anthropic,
  googleai,
  groq,
  deepseek,
  openrouter,
  mistral,
  cohere,
  togetherai,
  kimi,
}

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
- Log sleep: [ACTION:sleep:{"bed_time":"23:00","wake_time":"07:00","quality":"good"}]
  (quality: poor, fair, good, excellent)
- Log steps: [ACTION:steps:{"steps":5000}]
- Log workout: [ACTION:workout:{"type":"running","duration_minutes":30,"calories":300}]
  (type: running, cycling, strength, yoga, swimming, walking, hiit, other)
- Log heart rate: [ACTION:heart_rate:{"bpm":72}]
- Log meditation: [ACTION:meditation:{"type":"breathing","duration_minutes":10}]
  (type: breathing, guided, unguided, sleep, focus)
- Complete/add habit: [ACTION:habit:{"name":"Read","action":"complete"}]
  (action: "complete" toggles today's completion, "add" creates a new habit)
- Log screen time: [ACTION:screen_time:{"total_minutes":180,"pickups":45}]
- Start focus timer: [ACTION:focus:{"duration_minutes":25,"task":"Deep work"}]
- Add calendar event: [ACTION:calendar:{"title":"Meeting","start":"2026-04-25T14:00","end":"2026-04-25T15:00"}]
- Mark inbox as read: [ACTION:inbox:{"action":"mark_read","id":"message-id"}]

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
  static const String _googleAiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

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
  /// [dataContext] is optional user data injected into the system prompt.
  Future<String> sendMessage({
    required List<ChatMessage> messages,
    required String apiKey,
    required AiProvider provider,
    String? dataContext,
  }) async {
    switch (provider) {
      case AiProvider.openai:
        return _sendOpenAi(messages, apiKey, dataContext);
      case AiProvider.anthropic:
        return _sendAnthropic(messages, apiKey, dataContext);
      case AiProvider.googleai:
        return _sendGoogleAi(messages, apiKey, dataContext);
      case AiProvider.groq:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
          model: 'llama-3.3-70b-versatile', providerName: 'Groq',
        );
      case AiProvider.deepseek:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://api.deepseek.com/v1/chat/completions',
          model: 'deepseek-chat', providerName: 'DeepSeek',
        );
      case AiProvider.openrouter:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
          model: 'meta-llama/llama-3.3-70b-instruct:free', providerName: 'OpenRouter',
        );
      case AiProvider.mistral:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://api.mistral.ai/v1/chat/completions',
          model: 'mistral-small-latest', providerName: 'Mistral',
        );
      case AiProvider.cohere:
        return _sendCohere(messages, apiKey, dataContext);
      case AiProvider.togetherai:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://api.together.xyz/v1/chat/completions',
          model: 'meta-llama/Llama-3.3-70B-Instruct-Turbo', providerName: 'Together AI',
        );
      case AiProvider.kimi:
        return _sendOpenAiCompatible(
          messages: messages, apiKey: apiKey, dataContext: dataContext,
          baseUrl: 'https://api.moonshot.cn/v1/chat/completions',
          model: 'moonshot-v1-8k', providerName: 'Kimi',
        );
    }
  }

  /// Build the full system prompt with optional data context
  String _buildSystemPrompt(String? dataContext) {
    if (dataContext == null || dataContext.isEmpty) return _systemPrompt;
    return '$_systemPrompt\n\n'
        '[USER_DATA — Real-time data from the user\'s app. Use this to answer questions accurately.]\n'
        '$dataContext\n'
        '[/USER_DATA]\n\n'
        'When answering questions about the user\'s data, ALWAYS reference the real numbers from USER_DATA above. '
        'Never guess or make up values. If data for a domain is not provided, say you don\'t have that information.';
  }

  /// Send messages to OpenAI Chat Completions API
  Future<String> _sendOpenAi(List<ChatMessage> messages, String apiKey, String? dataContext) async {
    final systemPrompt = _buildSystemPrompt(dataContext);
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
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
      List<ChatMessage> messages, String apiKey, String? dataContext) async {
    final requestMessages = messages
        .where((m) => m.role != MessageRole.system && !m.isError)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    final systemPrompt = _buildSystemPrompt(dataContext);
    final body = jsonEncode({
      'model': _anthropicModel,
      'max_tokens': 1024,
      'system': systemPrompt,
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

  /// Send messages to Google AI (Gemini) API
  Future<String> _sendGoogleAi(
      List<ChatMessage> messages, String apiKey, String? dataContext) async {
    final systemPrompt = _buildSystemPrompt(dataContext);

    final contents = <Map<String, dynamic>>[];

    for (final m in messages.where((m) => m.role != MessageRole.system && !m.isError)) {
      contents.add({
        'role': m.role == MessageRole.user ? 'user' : 'model',
        'parts': [{'text': m.content}],
      });
    }

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': systemPrompt}],
      },
      'contents': contents,
      'generationConfig': {
        'maxOutputTokens': 1024,
        'temperature': 0.7,
      },
    });

    try {
      final response = await _client
          .post(
            Uri.parse('$_googleAiUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>;
          final parts = content['parts'] as List<dynamic>;
          if (parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        throw Exception('No response from Google AI');
      } else {
        final errorBody = _parseErrorBody(response.body);
        debugPrint(
            '[JarvisApi] Google AI error ${response.statusCode}: $errorBody');
        throw Exception('Google AI API error: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Google AI API error')) {
        rethrow;
      }
      debugPrint('[JarvisApi] Google AI request failed: $e');
      throw Exception('Failed to reach Google AI: $e');
    }
  }

  /// Generic sender for OpenAI-compatible APIs (Groq, DeepSeek, OpenRouter, etc.)
  Future<String> _sendOpenAiCompatible({
    required List<ChatMessage> messages,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String providerName,
    String? dataContext,
  }) async {
    final systemPrompt = _buildSystemPrompt(dataContext);
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...messages
          .where((m) => m.role != MessageRole.system && !m.isError)
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              }),
    ];

    final body = jsonEncode({
      'model': model,
      'messages': requestMessages,
      'max_tokens': 1024,
      'temperature': 0.7,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(baseUrl),
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
        throw Exception('No response from $providerName');
      } else {
        final errorBody = _parseErrorBody(response.body);
        debugPrint('[JarvisApi] $providerName error ${response.statusCode}: $errorBody');
        throw Exception('$providerName API error: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('API error')) rethrow;
      debugPrint('[JarvisApi] $providerName request failed: $e');
      throw Exception('Failed to reach $providerName: $e');
    }
  }

  /// Send messages to Cohere API (uses /v2/chat with its own format)
  Future<String> _sendCohere(
      List<ChatMessage> messages, String apiKey, String? dataContext) async {
    final systemPrompt = _buildSystemPrompt(dataContext);

    final chatHistory = messages
        .where((m) => m.role != MessageRole.system && !m.isError)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    // Cohere v2 chat format
    final body = jsonEncode({
      'model': 'command-r-plus',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...chatHistory,
      ],
      'max_tokens': 1024,
      'temperature': 0.7,
    });

    try {
      final response = await _client
          .post(
            Uri.parse('https://api.cohere.com/v2/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message'] as Map<String, dynamic>?;
        if (message != null) {
          final content = message['content'] as List<dynamic>?;
          if (content != null && content.isNotEmpty) {
            return content[0]['text'] as String;
          }
        }
        throw Exception('No response from Cohere');
      } else {
        final errorBody = _parseErrorBody(response.body);
        debugPrint('[JarvisApi] Cohere error ${response.statusCode}: $errorBody');
        throw Exception('Cohere API error: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Cohere API error')) rethrow;
      debugPrint('[JarvisApi] Cohere request failed: $e');
      throw Exception('Failed to reach Cohere: $e');
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
