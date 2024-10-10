import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class LikedSongsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LikedSongsNotifier() : super([]);

  Future<void> addSong(Map<String, dynamic> song) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }

    try {
      // Supabaseにいいね情報を保存
      await supabase.from('liked').insert({
        'user_id': userId,
        'song_id': int.parse(song['id']), // 文字列から整数に変換
      });

      // ローカルの状態を更新
      state = [...state, song];
      Logger().d('いいねを追加しました: ${song['attributes']['name']}');
    } catch (e) {
      Logger().e('いいねの追加に失敗しました: $e');
    }
  }

  // いいねした曲を取得するメソッド
  Future<void> fetchLikedSongs() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }

    try {
      final response = await supabase
          .from('liked')
          .select('songs(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      state = response
          .map((item) => (item['songs'] as Map<String, dynamic>)['details']
              as Map<String, dynamic>)
          .toList();
      Logger().d('いいねした曲を取得しました: ${state.length}曲');
      Logger().d('いいねした曲: $state');
    } catch (e) {
      Logger().e('いいねした曲の取得に失敗しました: $e');
      rethrow;
    }
  }
}

final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return LikedSongsNotifier();
});
