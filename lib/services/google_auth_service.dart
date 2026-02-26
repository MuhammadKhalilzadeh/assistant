import 'package:assistant/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    final serverClientId = AppConfig.instance.googleServerClientId;
    _googleSignIn = GoogleSignIn(
      serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/gmail.readonly',
      ],
    );
  }

  /// Sign in with Google and return idToken + serverAuthCode
  Future<GoogleSignInResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        debugPrint('[GoogleAuth] idToken is null after sign-in');
        throw Exception(
            'Failed to get ID token from Google. Check your OAuth configuration.');
      }

      debugPrint('[GoogleAuth] Sign-in successful: ${account.email}');
      debugPrint(
          '[GoogleAuth] serverAuthCode present: ${account.serverAuthCode != null}');

      return GoogleSignInResult(
        idToken: idToken,
        serverAuthCode: account.serverAuthCode,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (error) {
      debugPrint('[GoogleAuth] Sign-in error: $error');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Disconnect Google account completely
  Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }

  /// Check if user is currently signed in to Google
  bool get isSignedIn => _googleSignIn.currentUser != null;
}

class GoogleSignInResult {
  final String idToken;
  final String? serverAuthCode;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleSignInResult({
    required this.idToken,
    this.serverAuthCode,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
