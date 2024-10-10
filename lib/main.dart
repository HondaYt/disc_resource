import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'router.dart';
import 'color.dart';
import 'package:background_fetch/background_fetch.dart';
import 'services/recently_played_service.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    Logger().d("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  await sendRecentlyPlayed();

  BackgroundFetch.finish(taskId);
}

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

  await initBackgroundFetch();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // フォアグラウンドでの最初の実行
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

Future<void> initBackgroundFetch() async {
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15, // 15分ごとに実行
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout);

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void _onBackgroundFetch(String taskId) async {
  Logger().d("[BackgroundFetch] Event received: $taskId");

  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    Logger().d("[BackgroundFetch] App is in foreground, skipping execution");
  } else {
    final session = supabase.auth.currentSession;
    final permission = await Permission.mediaLibrary.status.isGranted;
    if (session != null && permission) {
      await sendRecentlyPlayed();
    }
  }

  BackgroundFetch.finish(taskId);
}

void _onBackgroundFetchTimeout(String taskId) {
  Logger().d("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}
