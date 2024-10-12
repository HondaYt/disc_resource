import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class ReadItem {
  final String postId;
  final bool isRead;
  final bool isSwiped;

  ReadItem(
      {required this.postId, required this.isRead, required this.isSwiped});
}

class ReadNotifier extends StateNotifier<Map<String, ReadItem>> {
  ReadNotifier() : super({});

  Future<void> markAsRead(String postId, {required bool swiped}) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }

    try {
      final result = await supabase
          .from('read')
          .upsert(
            {
              'user_id': userId,
              'post_id': postId,
              'swiped': swiped,
            },
            onConflict: 'user_id, post_id',
          )
          .select()
          .single();

      state = {
        ...state,
        postId: ReadItem(
          postId: postId,
          isRead: true,
          isSwiped: result['swiped'],
        ),
      };
      Logger().d('投稿を既読にしました: $postId, スワイプ: $swiped');
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        // 重複キーエラーの場合、既存のレコードを更新
        await supabase
            .from('read')
            .update({'swiped': swiped})
            .eq('user_id', userId)
            .eq('post_id', postId);

        state = {
          ...state,
          postId: ReadItem(
            postId: postId,
            isRead: true,
            isSwiped: swiped,
          ),
        };
        Logger().d('既存の既読レコードを更新しました: $postId, スワイプ: $swiped');
      } else {
        Logger().e('既読の追加に失敗しました: $e');
        rethrow;
      }
    }
  }

  Future<void> fetchReadPosts() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }

    try {
      final response = await supabase
          .from('read')
          .select('post_id, swiped')
          .eq('user_id', userId);

      state = Map.fromEntries(
        response.map((item) => MapEntry(
              item['post_id'],
              ReadItem(
                postId: item['post_id'],
                isRead: true,
                isSwiped: item['swiped'] ?? false,
              ),
            )),
      );
      Logger().d('既読の投稿を取得しました: ${state.length}件');
    } catch (e) {
      Logger().e('既読の投稿の取得に失敗しました: $e');
    }
  }

  Future<void> fetchReadSongs() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }

    try {
      final response = await supabase
          .from('read')
          .select('post_id, swiped')
          .eq('user_id', userId);

      state = Map.fromEntries(
        response.map((item) => MapEntry(
              item['post_id'],
              ReadItem(
                postId: item['post_id'],
                isRead: true,
                isSwiped: item['swiped'] ?? false,
              ),
            )),
      );
      Logger().d('既読の投稿を取得しました: ${state.length}件');
    } catch (e) {
      Logger().e('既読の投稿の取得に失敗しました: $e');
    }
  }
}

final readProvider =
    StateNotifierProvider<ReadNotifier, Map<String, ReadItem>>((ref) {
  return ReadNotifier();
});
