import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UserPostsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  UserPostsNotifier() : super([]);

  int _currentPage = 1;
  static const int _postsPerPage = 10;
  bool _hasMorePosts = true;

  Future<void> fetchUserPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      state = [];
    }

    if (!_hasMorePosts) return;

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('posts')
            .select('*, songs(*)')
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .range((_currentPage - 1) * _postsPerPage,
                _currentPage * _postsPerPage - 1);

        if (response.isEmpty) {
          _hasMorePosts = false;
        } else {
          state = [...state, ...response];
          _currentPage++;
        }
      }
    } catch (error) {
      Logger().e('ユーザー投稿の取得エラー: $error');
    }
  }

  bool get hasMorePosts => _hasMorePosts;

  Future<void> deletePost(String postId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('posts')
            .delete()
            .eq('id', postId)
            .eq('user_id', user.id);

        state = state.where((post) => post['id'].toString() != postId).toList();
        Logger().d('投稿を削除しました: $postId');
      }
    } catch (error) {
      Logger().e('投稿の削除エラー: $error');
      rethrow;
    }
  }
}
