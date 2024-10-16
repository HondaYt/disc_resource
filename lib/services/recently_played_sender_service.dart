import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:music_kit/music_kit.dart';
import 'dart:convert';
import '../utils/user_utils.dart';

final _musicKitPlugin = MusicKit();

Future<void> sendRecentlyPlayed() async {
  final supabase = Supabase.instance.client;
  final developerToken = await _musicKitPlugin.requestDeveloperToken();
  final userToken = await _musicKitPlugin.requestUserToken(developerToken);

  try {
    await throwIfNotAuthenticated();
  } catch (e) {
    Logger().e('ユーザーが認証されていません: $e');
    return;
  }

  final userId = getCurrentUserId()!;

  final recentlyPlayedData =
      await recentlyPlayedUtilsData(developerToken, userToken);
  if (recentlyPlayedData == null) return;

  final songData = recentlyPlayedData['data'][0];
  final songId = songData['id'];

  await processAndSaveSongData(supabase, userId, songId, songData);
}

Future<Map<String, dynamic>?> recentlyPlayedUtilsData(
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
    String songId, Map<String, dynamic> songData) async {
  try {
    await supabase.from('songs').upsert({
      'id': songId,
      'details': songData,
    }, onConflict: 'id');

    // 既読の投稿を確認
    final readPosts = await supabase
        .from('read')
        .select('post_id, created_at')
        .eq('user_id', userId);

    final now = DateTime.now().toUtc();

    Logger().d('読み込まれた既読投稿数: ${readPosts.length}');

    for (var readPost in readPosts) {
      final readAt = DateTime.parse(readPost['created_at']);
      final timeSinceRead = now.difference(readAt);

      if (timeSinceRead.inHours < 24) {
        // 既読の投稿に含まれる曲を確認
        final existingReadSong = await supabase
            .from('posts')
            .select('song_id')
            .eq('id', readPost['post_id'])
            .single();

        final existingReadSongId = existingReadSong['song_id'];
        final currentSongId = int.parse(songId);

        if (existingReadSongId == currentSongId) {
          Logger().d('この曲は24時間以内に既読の投稿に含まれているため、投稿をスキップします: $currentSongId');
          return;
        }
      }
    }

    Logger().d('既読チェックを通過しました。投稿処理を開始します。');

    // 既存の投稿を確認
    final existingData = await supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .eq('song_id', songId);

    if (existingData.isEmpty) {
      await insertPostData(supabase, userId, songId);
      Logger().d('最近再生した曲のデータをSupabaseに送信しました');
    } else {
      final createdAt = DateTime.parse(existingData[0]['created_at']);
      final difference = now.difference(createdAt);

      if (difference.inHours >= 24) {
        await insertPostData(supabase, userId, songId);
        Logger().d('24時間以上経過したため、最近再生した曲のデータをSupabaseに送信しました');
      } else {
        Logger().d('同じ曲のデータが24時間以内に存在するため、挿入をスキップしました');
      }
    }
  } catch (e) {
    Logger().e('Supabaseの操作中にエラーが発生しました: $e');
  }
}

Future<void> insertPostData(
    SupabaseClient supabase, String userId, String songId) async {
  await supabase.from('posts').insert({
    'user_id': userId,
    'song_id': songId,
  });
}
