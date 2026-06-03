import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/chat_message_model.dart';
import 'package:assistant/data/services/jarvis_api_service.dart';
import 'package:assistant/data/services/jarvis_data_service.dart';
import 'package:assistant/data/services/http_client.dart';
import 'package:assistant/config/app_config.dart';
import 'package:assistant/services/token_storage_service.dart';
import 'package:assistant/providers/auth_provider.dart';

// Service provider
final jarvisApiServiceProvider = Provider<JarvisApiService>((ref) {
  return JarvisApiService();
});

/// Represents a parsed action from the LLM response
class JarvisAction {
  final String type; // 'water', 'todo', 'mood', 'calories', 'focus'
  final Map<String, dynamic> data;

  const JarvisAction({required this.type, required this.data});

  @override
  String toString() => 'JarvisAction($type, $data)';
}

// State
class JarvisState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? activeProvider; // 'openai' or 'anthropic'
  final List<JarvisAction> pendingActions;
  final String? briefingData; // Raw briefing data for the daily card

  const JarvisState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.activeProvider,
    this.pendingActions = const [],
    this.briefingData,
  });

  JarvisState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? activeProvider,
    List<JarvisAction>? pendingActions,
    String? briefingData,
  }) {
    return JarvisState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeProvider: activeProvider ?? this.activeProvider,
      pendingActions: pendingActions ?? this.pendingActions,
      briefingData: briefingData ?? this.briefingData,
    );
  }
}

// Action parsing regex — matches flat JSON objects in ACTION tags
final _actionPattern = RegExp(r'\[ACTION:(\w+):(\{[^[\]]*?\})\]');

/// Keywords that indicate a query needs server-side deep analysis.
const _deepAnalysisKeywords = [
  'trend', 'pattern', 'correlat', 'why', 'compare', 'recommend',
  'analyze', 'analysis', 'weekly', 'report', 'this week', 'last week',
  'this month', 'over time', 'improve', 'suggest', 'plan', 'schedule',
  'how did i', 'how have i', 'how am i doing', 'what should',
  'insights', 'progress', 'history', 'average',
];

/// Keywords that indicate a simple query handled client-side.
const _simpleKeywords = [
  'hello', 'hi', 'hey', 'thanks', 'thank you', 'bye', 'good morning',
  'good night', 'joke', 'help', 'what can you do',
];

/// Determine if a message should be routed to the server for deep analysis.
bool _needsServerRouting(String message) {
  final lower = message.toLowerCase();

  // Simple queries stay client-side
  for (final kw in _simpleKeywords) {
    if (lower == kw || lower == '$kw.' || lower == '$kw!') return false;
  }

  // Deep analysis queries go to server
  for (final kw in _deepAnalysisKeywords) {
    if (lower.contains(kw)) return true;
  }

  return false;
}

// Notifier
class JarvisNotifier extends StateNotifier<JarvisState> {
  final JarvisApiService _apiService;
  final TokenStorageService _tokenStorage;
  final JarvisDataService _dataService;
  final AppHttpClient _httpClient;

  JarvisNotifier({
    required JarvisApiService apiService,
    required TokenStorageService tokenStorage,
    required JarvisDataService dataService,
    AppHttpClient? httpClient,
  })  : _apiService = apiService,
        _tokenStorage = tokenStorage,
        _dataService = dataService,
        _httpClient = httpClient ??
            AppHttpClient(
              timeout: AppConfig.instance.requestTimeout,
              maxRetries: AppConfig.instance.maxRetries,
            ),
        super(const JarvisState()) {
    _initialize();
  }

  /// Initialize with a welcome message and detect available provider
  Future<void> _initialize() async {
    final provider = await checkApiKeyAvailability();

    // Gather briefing data in the background
    String? briefingData;
    try {
      briefingData = await _dataService.gatherDailyBriefing();
    } catch (e) {
      debugPrint('[JarvisProvider] Failed to gather briefing: $e');
    }

    state = JarvisState(
      messages: [
        ChatMessage.assistant(
          "Hello! I'm Jarvis, your personal assistant. "
          "I can help you with health tracking, productivity, and more. "
          "How can I help you today?",
        ),
      ],
      activeProvider: provider,
      briefingData: briefingData,
    );
  }

  /// Refresh the daily briefing data
  Future<void> refreshBriefing() async {
    try {
      final briefingData = await _dataService.gatherDailyBriefing();
      state = state.copyWith(briefingData: briefingData);
    } catch (e) {
      debugPrint('[JarvisProvider] Failed to refresh briefing: $e');
    }
  }

  /// Check which API key is available and return the provider name.
  Future<String?> checkApiKeyAvailability() async {
    final hasOpenAi = await _tokenStorage.hasApiKey('openai');
    if (hasOpenAi) return 'openai';

    final hasAnthropic = await _tokenStorage.hasApiKey('anthropic');
    if (hasAnthropic) return 'anthropic';

    return null;
  }

  /// Send a user message and get an AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(content.trim());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
      pendingActions: [],
    );

    try {
      // Determine provider and get API key
      final provider = await checkApiKeyAvailability();
      if (provider == null) {
        final errorMsg = ChatMessage.error(
          'No API key configured. Please add an OpenAI or Anthropic API key '
          'in Settings to use Jarvis.',
        );
        state = state.copyWith(
          messages: [...state.messages, errorMsg],
          isLoading: false,
          error: 'No API key configured',
        );
        return;
      }

      final apiKey = await _tokenStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        final errorMsg = ChatMessage.error(
          'API key for $provider is missing. Please re-add it in Settings.',
        );
        state = state.copyWith(
          messages: [...state.messages, errorMsg],
          isLoading: false,
          error: 'API key missing',
        );
        return;
      }

      String responseContent;

      // Hybrid routing: complex queries go to server, simple ones stay client-side
      if (_needsServerRouting(content.trim())) {
        // Route to server — it has the data-aware AI brain with full DB access
        responseContent = await _sendToServer(
          message: content.trim(),
          provider: provider,
        );
      } else {
        // Client-side: gather local context and call LLM directly
        final aiProvider =
            provider == 'openai' ? AiProvider.openai : AiProvider.anthropic;

        String? dataContext;
        try {
          dataContext =
              await _dataService.gatherQueryContext(content.trim());
        } catch (e) {
          debugPrint('[JarvisProvider] Failed to gather context: $e');
        }

        responseContent = await _apiService.sendMessage(
          messages: state.messages
              .where((m) => !m.isError && m.role != MessageRole.system)
              .toList(),
          apiKey: apiKey,
          provider: aiProvider,
          dataContext: dataContext,
        );
      }

      // Parse actions from response
      final actions = _parseActions(responseContent);
      final cleanedContent = _stripActionTags(responseContent);

      final assistantMessage = ChatMessage.assistant(cleanedContent);
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        activeProvider: provider,
        pendingActions: actions,
      );
    } catch (e) {
      debugPrint('[JarvisProvider] sendMessage error: $e');
      final errorMsg = ChatMessage.error(
        'Sorry, I encountered an error. Please try again.\n\n'
        '${_formatError(e)}',
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send a message to the server-side AI brain for deep analysis.
  /// The server has full DB access and builds rich data context.
  Future<String> _sendToServer({
    required String message,
    required String provider,
  }) async {
    final baseUrl = AppConfig.instance.apiBaseUrl;
    final history = state.messages
        .where((m) => !m.isError && m.role != MessageRole.system)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/jarvis/chat'),
      body: {
        'message': message,
        'history': history,
        'provider': provider,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['response'] as String? ?? '';
    } else {
      // Fall back to client-side if server fails
      debugPrint(
          '[JarvisProvider] Server routing failed (${response.statusCode}), falling back to client');
      final aiProvider =
          provider == 'openai' ? AiProvider.openai : AiProvider.anthropic;
      final apiKey = await _tokenStorage.getApiKey(provider);

      String? dataContext;
      try {
        dataContext = await _dataService.gatherQueryContext(message);
      } catch (_) {}

      return _apiService.sendMessage(
        messages: state.messages
            .where((m) => !m.isError && m.role != MessageRole.system)
            .toList(),
        apiKey: apiKey!,
        provider: aiProvider,
        dataContext: dataContext,
      );
    }
  }

  /// Parse ACTION tags from the LLM response
  List<JarvisAction> _parseActions(String response) {
    final actions = <JarvisAction>[];
    for (final match in _actionPattern.allMatches(response)) {
      try {
        final type = match.group(1)!;
        final jsonStr = match.group(2)!;
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        actions.add(JarvisAction(type: type, data: data));
      } catch (e) {
        debugPrint('[JarvisProvider] Failed to parse action: $e');
      }
    }
    return actions;
  }

  /// Remove ACTION tags from the response text for display
  String _stripActionTags(String response) {
    return response.replaceAll(_actionPattern, '').trim();
  }

  /// Mark all pending actions as processed
  void clearPendingActions() {
    state = state.copyWith(pendingActions: []);
  }

  /// Clear conversation and reset to welcome message
  void clearConversation() {
    state = JarvisState(
      messages: [
        ChatMessage.assistant(
          "Conversation cleared. How can I help you?",
        ),
      ],
      activeProvider: state.activeProvider,
      briefingData: state.briefingData,
    );
  }

  /// Format error for display
  String _formatError(Object error) {
    final msg = error.toString();
    if (msg.contains('API error')) {
      final match = RegExp(r'API error: (.+)').firstMatch(msg);
      return match?.group(1) ?? msg;
    }
    if (msg.contains('Failed to reach')) {
      return 'Could not connect to the AI service. Check your internet connection.';
    }
    return 'An unexpected error occurred.';
  }
}

// Provider
final jarvisProvider =
    StateNotifierProvider<JarvisNotifier, JarvisState>((ref) {
  return JarvisNotifier(
    apiService: ref.read(jarvisApiServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
    dataService: ref.read(jarvisDataServiceProvider),
  );
});
