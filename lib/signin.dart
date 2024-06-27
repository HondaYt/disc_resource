import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logger/logger.dart';
import 'music_kit_test.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SignInWithAppleButton(
            onPressed: () async {
              try {
                final credential = await SignInWithApple.getAppleIDCredential(
                  scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                );

                // サインイン成功時の処理
                Logger().d(credential);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MusicKitTest()));
              } catch (error) {
                // エラーハンドリング
                Logger().e(error);
              }
            },
          ),
        ),
      ),
    );
  }
}
