import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assistant/config/app_config.dart';
import 'package:assistant/data/models/user_model.dart';

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  /// Exchange Google idToken for JWT tokens
  Future<AuthResponse> googleAuth({
    required String idToken,
    String? authCode,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        if (authCode != null) 'authCode': authCode, // ignore: use_null_aware_elements
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Auth failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      expiresIn: data['expiresIn'] as int,
    );
  }

  /// Refresh JWT tokens
  Future<TokenResponse> refreshToken(String refreshToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Token refresh failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TokenResponse(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      expiresIn: data['expiresIn'] as int,
    );
  }

  /// Logout — invalidate refresh token
  Future<void> logout(String accessToken) async {
    await _client.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  /// Get current user profile
  Future<UserModel> getMe(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get profile: ${response.statusCode}');
    }

    return UserModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Update user nickname
  Future<UserModel> updateNickname(String accessToken, String nickname) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'nickname': nickname}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update nickname: ${response.statusCode}');
    }

    return UserModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Connect Gmail with auth code
  Future<void> connectGmail(String accessToken, String authCode) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/gmail/connect'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'authCode': authCode}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gmail connect failed: ${response.statusCode}');
    }
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}
