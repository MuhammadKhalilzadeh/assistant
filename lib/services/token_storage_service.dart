import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_json';
  static const _apiKeyPrefix = 'api_key_';

  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUserJson(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<String?> getUserJson() async {
    return _storage.read(key: _userKey);
  }

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // API Key storage

  Future<void> saveApiKey(String provider, String apiKey) async {
    await _storage.write(key: '$_apiKeyPrefix$provider', value: apiKey);
  }

  Future<String?> getApiKey(String provider) async {
    return _storage.read(key: '$_apiKeyPrefix$provider');
  }

  Future<void> deleteApiKey(String provider) async {
    await _storage.delete(key: '$_apiKeyPrefix$provider');
  }

  Future<List<String>> getStoredApiKeyProviders() async {
    final all = await _storage.readAll();
    return all.keys
        .where((key) => key.startsWith(_apiKeyPrefix))
        .map((key) => key.substring(_apiKeyPrefix.length))
        .toList();
  }

  Future<bool> hasApiKey(String provider) async {
    final key = await _storage.read(key: '$_apiKeyPrefix$provider');
    return key != null && key.isNotEmpty;
  }
}
