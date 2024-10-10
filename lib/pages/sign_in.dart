import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/apple_sign_in_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_corner/smooth_corner.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});
  @override
  SignInPageState createState() => SignInPageState();
  final supabase = Supabase.instance.client;
}

class SignInPageState extends State<SignInPage> {
  void _changeLoginStatus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(64),
                    child: Image.asset(
                      'assets/full_logo.png',
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildAppleSignInButton(),
                  const SizedBox(height: 30),
                  _buildTermsAndPrivacyText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: SmoothRectangleBorder(
            smoothness: 0.6,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            elevation: 2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          onPressed: () async {
            try {
              await appleSignInUtils();
              _changeLoginStatus();
              if (!mounted) return;
              context.push('/');
            } on AuthException catch (error) {
              debugPrint(error.toString());
            } catch (error) {
              debugPrint(error.toString());
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple, size: 28),
              SizedBox(width: 10),
              Text('Appleでサインイン'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacyText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 13),
        children: [
          TextSpan(
            text: '利用規約',
            style: const TextStyle(
                color: Colors.white70, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text('利用規約'),
                    content: Text('利用規約の内容を表示'),
                  ),
                );
              },
          ),
          const TextSpan(
            text: 'と',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'プライバシーポリシー',
            style: const TextStyle(
                color: Colors.white70, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text('プライバシーポリシー'),
                    content: Text('プライバシーポリシーの内容を表示'),
                  ),
                );
              },
          ),
          const TextSpan(
            text: 'に\n同意の上、本サービスをご利用ください。',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
