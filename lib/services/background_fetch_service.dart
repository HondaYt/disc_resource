import 'package:background_fetch/background_fetch.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'recently_played_sender_service.dart';

final supabase = Supabase.instance.client;

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    Logger().d("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  await BackgroundFetchService.executeBackgroundTask(taskId);
}

class BackgroundFetchService {
  static Future<void> initialize() async {
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
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

  static void _onBackgroundFetch(String taskId) async {
    Logger().d("[BackgroundFetch] Event received: $taskId");
    await executeBackgroundTask(taskId);
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    Logger().d("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  static Future<void> executeBackgroundTask(String taskId) async {
    try {
      final session = supabase.auth.currentSession;
      final permission = await Permission.mediaLibrary.status;
      if (session != null && permission.isGranted) {
        await _timeoutProtectedTask(() => sendRecentlyPlayed());
      }
    } catch (e) {
      Logger().e("[BackgroundFetch] Error: $e");
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  static Future<void> _timeoutProtectedTask(
      Future<void> Function() task) async {
    try {
      await task().timeout(Duration(seconds: 25));
    } on TimeoutException {
      Logger().w("[BackgroundFetch] Task timed out after 25 seconds");
    }
  }
}
