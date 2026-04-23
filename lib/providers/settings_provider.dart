import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/services/token_storage_service.dart';
import 'package:assistant/providers/auth_provider.dart';

/// Supported AI API key providers
const List<String> aiProviders = ['openai', 'anthropic', 'google_ai'];

/// Display names for each provider
const Map<String, String> aiProviderNames = {
  'openai': 'OpenAI',
  'anthropic': 'Anthropic',
  'google_ai': 'Google AI',
};

/// Provider to manage API keys state
final apiKeysProvider =
    StateNotifierProvider<ApiKeysNotifier, Map<String, String>>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return ApiKeysNotifier(tokenStorage);
});

class ApiKeysNotifier extends StateNotifier<Map<String, String>> {
  final TokenStorageService _tokenStorage;

  ApiKeysNotifier(this._tokenStorage) : super({}) {
    loadKeys();
  }

  /// Load all stored API keys and build masked map
  Future<void> loadKeys() async {
    final Map<String, String> masked = {};
    for (final provider in aiProviders) {
      final key = await _tokenStorage.getApiKey(provider);
      if (key != null && key.isNotEmpty) {
        masked[provider] = _maskKey(key);
      }
    }
    state = masked;
  }

  /// Save a new API key for a provider
  Future<void> saveKey(String provider, String apiKey) async {
    await _tokenStorage.saveApiKey(provider, apiKey);
    state = {...state, provider: _maskKey(apiKey)};
  }

  /// Delete an API key for a provider
  Future<void> deleteKey(String provider) async {
    await _tokenStorage.deleteApiKey(provider);
    final updated = Map<String, String>.from(state);
    updated.remove(provider);
    state = updated;
  }

  /// Mask a key showing only the last 4 characters
  String _maskKey(String key) {
    if (key.length <= 4) return key;
    final last4 = key.substring(key.length - 4);
    return '••••$last4';
  }
}
