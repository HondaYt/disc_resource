import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final supabase = Supabase.instance.client;

/// Performs Apple sign in on iOS or macOS
Future<AuthResponse> appleSignInService() async {
  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw const AuthException(
        'Could not find ID Token from generated credential.');
  }

  // フルネームを取得
  final fullName = credential.givenName != null && credential.familyName != null
      ? '${credential.givenName} ${credential.familyName}'
      : null;

  final email = credential.email;

  final response = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );

  // ユーザーメタデータにフルネームを追加
  if (fullName != null) {
    await supabase
        .from('profiles')
        .update({'username': fullName}).eq('id', response.user?.id as Object);
  }
  if (email != null) {
    await supabase
        .from('profiles')
        .update({'email': email}).eq('id', response.user?.id as Object);
  }

  return response;
}
