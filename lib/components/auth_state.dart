import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final supabase = Supabase.instance.client;

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
      context.go('/sign_in');
    } else if (!permission) {
      context.go('/request_permission');
    } else {
      context.go('/main_page');
    }
  }
}
