import 'main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in_with_apple.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});
  @override
  SignInPageState createState() => SignInPageState();
  final supabase = Supabase.instance.client;
}

class SignInPageState extends State<SignInPage> {
  String _loginStatus = 'ログインしていません';

  void _changeLoginStatus() {
    setState(() {
      _loginStatus = 'ログインしました';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('signInPage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _loginStatus,
            ),
            ElevatedButton(
              child: const Text('Sign in with Apple'),
              onPressed: () async {
                try {
                  // ③Sign in with Appleを呼び出す関数
                  await signInWithApple();
                  // ④サインインできた場合Stateを更新
                  _changeLoginStatus();
                  if (!context.mounted) return; // mountedチェックを追加
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MyApp()));
                } on AuthException catch (error) {
                  debugPrint(error.toString());
                } catch (error) {
                  debugPrint(error.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
