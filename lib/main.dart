import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'router.dart';
import 'color.dart';
import 'services/recently_played_sender_service.dart';
import 'services/background_fetch_service.dart';

final supabase = Supabase.instance.client;
Future<void> main() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final session = supabase.auth.currentSession;
  final permission = await Permission.mediaLibrary.status.isGranted;
  if (session != null && permission) {
    await sendRecentlyPlayed();
  }

  await BackgroundFetchService.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: discTheme,
      title: 'Disc',
      routerConfig: router,
    );
  }
}
