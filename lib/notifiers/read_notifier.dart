import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/read_item.dart';
import '../utils/user_utils.dart';

class ReadNotifier extends StateNotifier<Map<String, ReadItem>> {
  ReadNotifier() : super({});

  Future<void> markAsRead(String postId, {required bool swiped}) async {
    final supabase = Supabase.instance.client;

    try {
      await throwIfNotAuthenticated();
      final userId = getCurrentUserId()!;

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
        await _updateExistingReadRecord(postId, swiped);
      } else {
        Logger().e('既読の追加に失敗しました: $e');
        rethrow;
      }
    }
  }

  Future<void> _updateExistingReadRecord(String postId, bool swiped) async {
    final supabase = Supabase.instance.client;
    final userId = getCurrentUserId()!;

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
  }

  Future<void> fetchReadItems() async {
    try {
      await throwIfNotAuthenticated();
      final userId = getCurrentUserId()!;

      final response = await Supabase.instance.client
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
      Logger().d('既読のアイテムを取得しました: ${state.length}件');
    } catch (e) {
      Logger().e('既読のアイテムの取得に失敗しました: $e');
    }
  }
}
