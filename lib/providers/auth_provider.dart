import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/user_model.dart';
import 'package:assistant/data/services/auth_api_service.dart';
import 'package:assistant/services/google_auth_service.dart';
import 'package:assistant/services/token_storage_service.dart';

// Service providers
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

// Auth state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isSignedIn => status == AuthStatus.authenticated && user != null;
  bool get isGmailConnected => user?.gmailConnected ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final TokenStorageService _tokenStorage;
  final GoogleAuthService _googleAuth;
  final AuthApiService _authApi;

  AuthNotifier({
    required TokenStorageService tokenStorage,
    required GoogleAuthService googleAuth,
    required AuthApiService authApi,
  })  : _tokenStorage = tokenStorage,
        _googleAuth = googleAuth,
        _authApi = authApi,
        super(const AuthState());

  /// Check stored tokens and restore session
  Future<void> checkAuthState() async {
    try {
      final hasTokens = await _tokenStorage.hasTokens();
      if (!hasTokens) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // Try to load cached user
      final userJson = await _tokenStorage.getUserJson();
      if (userJson != null) {
        final user = UserModel.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>);
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }

      // Refresh token to validate session
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final tokenResponse = await _authApi.refreshToken(refreshToken);
          await _tokenStorage.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
          );

          // Fetch fresh user data
          final user = await _authApi.getMe(tokenResponse.accessToken);
          await _tokenStorage.saveUserJson(jsonEncode(user.toJson()));
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } catch (_) {
          // Refresh failed — session expired
          await _tokenStorage.clearAll();
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _googleAuth.signIn();
      if (result == null) {
        state = state.copyWith(isLoading: false);
        return false; // User cancelled
      }

      final authResponse = await _authApi.googleAuth(
        idToken: result.idToken,
        authCode: result.serverAuthCode,
      );

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await _tokenStorage.saveUserJson(
          jsonEncode(authResponse.user.toJson()));

      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
      return true;
    } catch (e) {
      debugPrint('[Auth] signInWithGoogle error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update user nickname
  Future<bool> updateNickname(String nickname) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) return false;

      final user = await _authApi.updateNickname(accessToken, nickname);
      await _tokenStorage.saveUserJson(jsonEncode(user.toJson()));
      state = state.copyWith(user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Connect Gmail
  Future<bool> connectGmail() async {
    try {
      final result = await _googleAuth.signIn();
      if (result == null || result.serverAuthCode == null) return false;

      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) return false;

      await _authApi.connectGmail(accessToken, result.serverAuthCode!);

      // Refresh user to get updated gmailConnected status
      final user = await _authApi.getMe(accessToken);
      await _tokenStorage.saveUserJson(jsonEncode(user.toJson()));
      state = state.copyWith(user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        await _authApi.logout(accessToken);
      }
    } catch (_) {
      // Ignore logout API errors
    }
    await _googleAuth.signOut();
    await _tokenStorage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Skip authentication (dev mode only)
  Future<void> skipAuth() async {
    const devUser = UserModel(
      id: 'dev-bypass-user',
      email: 'dev@jarvis.local',
      displayName: 'Dev User',
      nickname: 'Developer',
    );
    await _tokenStorage.saveUserJson(jsonEncode(devUser.toJson()));
    state = const AuthState(
      status: AuthStatus.authenticated,
      user: devUser,
    );
  }

  /// Get current access token (for HTTP client)
  Future<String?> getAccessToken() => _tokenStorage.getAccessToken();

  /// Refresh tokens (for HTTP client interceptor)
  Future<String?> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _authApi.refreshToken(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response.accessToken;
    } catch (_) {
      await signOut();
      return null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    tokenStorage: ref.read(tokenStorageProvider),
    googleAuth: ref.read(googleAuthServiceProvider),
    authApi: ref.read(authApiServiceProvider),
  );
});
