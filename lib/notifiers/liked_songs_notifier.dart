import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/user_utils.dart';

class LikedSongsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LikedSongsNotifier() : super([]);

  Future<void> addSong(Map<String, dynamic> song) async {
    try {
      await throwIfNotAuthenticated();
      final userId = getCurrentUserId()!;

      // Supabaseにいいね情報を保存
      await supabase.from('liked').insert({
        'user_id': userId,
        'song_id': int.parse(song['id']),
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
    try {
      await throwIfNotAuthenticated();
      final userId = getCurrentUserId()!;

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

  Future<void> removeSong(Map<String, dynamic> song) async {
    try {
      await throwIfNotAuthenticated();
      final userId = getCurrentUserId()!;

      // Supabaseからいいね情報を削除
      await supabase
          .from('liked')
          .delete()
          .eq('user_id', userId)
          .eq('song_id', int.parse(song['id']));

      // ローカルの状態を更新
      state = state.where((s) => s['id'] != song['id']).toList();
      Logger().d('いいねを削除しました: ${song['attributes']['name']}');
    } catch (e) {
      Logger().e('いいねの削除に失敗しました: $e');
      rethrow;
    }
  }
}
