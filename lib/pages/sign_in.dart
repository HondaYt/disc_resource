// import '../main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/sign_in_with_apple.dart';
import 'package:go_router/go_router.dart';

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
        title: const Text('ログイン'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  _loginStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.apple),
                  label: const Text('Appleでサインイン'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    try {
                      await signInWithApple();
                      _changeLoginStatus();
                      if (!context.mounted) return;
                      context.push('/');
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
        ),
      ),
    );
  }
}
