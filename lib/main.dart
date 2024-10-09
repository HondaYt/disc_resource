import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:music_kit/music_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'router.dart';
import 'color.dart';
import 'package:background_fetch/background_fetch.dart';

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

final _musicKitPlugin = MusicKit();

Future<void> sendRecentlyPlayed() async {
  final supabase = Supabase.instance.client;
  final developerToken = await _musicKitPlugin.requestDeveloperToken();
  final userToken = await _musicKitPlugin.requestUserToken(developerToken);

  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    Logger().e('ユーザーが認証されていません');
    return;
  }

  final recentlyPlayedData =
      await fetchRecentlyPlayedData(developerToken, userToken);
  if (recentlyPlayedData == null) return;

  final songData = recentlyPlayedData['data'][0];
  final songId = songData['id'];

  await processAndSaveSongData(supabase, userId, songId, recentlyPlayedData);
}

Future<Map<String, dynamic>?> fetchRecentlyPlayedData(
    String developerToken, String userToken) async {
  const url = 'https://api.music.apple.com/v1/me/recent/played/tracks?limit=1';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $developerToken',
      'Music-User-Token': userToken,
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    Logger().e('最近再生した曲の読み込みに失敗しました: ${response.body}');
    return null;
  }
}

Future<void> processAndSaveSongData(SupabaseClient supabase, String userId,
    String songId, Map<String, dynamic> recentlyPlayedData) async {
  final today = DateTime.now().toUtc().toString().split(' ')[0];

  try {
    final existingData = await supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .eq('song_id', songId);
    Logger().d(existingData);

    if (existingData.isEmpty) {
      await insertSongData(supabase, userId, songId, recentlyPlayedData);
      Logger().d('最近再生した曲のデータをSupabaseに送信しました');
    } else {
      final createdAt = DateTime.parse(existingData[0]['created_at']);
      Logger().d(createdAt);
      if (createdAt.toUtc().toString().split(' ')[0] != today) {
        await insertSongData(supabase, userId, songId, recentlyPlayedData);
        Logger().d('新しい日付で最近再生した曲のデータをSupabaseに送信しました');
      } else {
        Logger().d('同じ曲のデータが今日既に存在するため、挿入をスキップしました');
      }
    }
  } catch (e) {
    Logger().e('Supabaseの操作中にエラーが発生しました: $e');
  }
}

Future<void> insertSongData(SupabaseClient supabase, String userId,
    String songId, Map<String, dynamic> recentlyPlayedData) async {
  await supabase.from('posts').insert({
    'user_id': userId,
    'song_id': songId,
    'recently_played': json.encode(recentlyPlayedData),
  });
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

  // アプリがフォアグラウンドにある場合は何もしない
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
