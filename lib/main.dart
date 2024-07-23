import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'permission_page.dart';
import 'music_kit_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sign_in.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disc Resource',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthState(),
    );
  }
}

class AuthState extends StatefulWidget {
  const AuthState({super.key});

  @override
  AuthStateState createState() => AuthStateState();
}

class AuthStateState extends State<AuthState> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _checkAuthState() async {
    final session = supabase.auth.currentSession;
    final permission = await Permission.mediaLibrary.status.isGranted;
    if (!mounted) return;
    if (session == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } else if (!permission) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PermissionPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MusicKitTest()),
      );
    }
  }
}
