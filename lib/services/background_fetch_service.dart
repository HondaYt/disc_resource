import 'package:background_fetch/background_fetch.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  await sendRecentlyPlayed();

  BackgroundFetch.finish(taskId);
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

    try {
      final session = supabase.auth.currentSession;
      final permission = await Permission.mediaLibrary.status.isGranted;
      if (session != null && permission) {
        await sendRecentlyPlayed();
      }
    } catch (e) {
      Logger().e("[BackgroundFetch] Error: $e");
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    Logger().d("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }
}
