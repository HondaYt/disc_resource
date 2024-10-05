import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final supabase = Supabase.instance.client;

class UserSearchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  UserSearchNotifier() : super([]);

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      final currentUserId = supabase.auth.currentUser!.id;
      final searchResults = await _fetchSearchResults(query, currentUserId);
      final followedUserIds = await _fetchFollowedUserIds(currentUserId);

      state = _processSearchResults(searchResults, followedUserIds);
    } catch (error) {
      // エラー処理
      Logger().e('検索エラー: $error');
      state = [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(
      String query, String currentUserId) async {
    return await supabase
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,user_id.ilike.%$query%')
        .neq('id', currentUserId)
        .limit(20);
  }

  Future<Set<String>> _fetchFollowedUserIds(String currentUserId) async {
    final followsResponse = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId);
    return Set<String>.from(
        followsResponse.map((follow) => follow['followed_id'] as String));
  }

  List<Map<String, dynamic>> _processSearchResults(
      List<Map<String, dynamic>> searchResults, Set<String> followedUserIds) {
    return searchResults.map((profile) {
      return {
        ...profile,
        'is_following': followedUserIds.contains(profile['id']),
      };
    }).toList();
  }

  Future<void> toggleFollow(String targetUserId) async {
    final currentUserId = supabase.auth.currentUser!.id;
    try {
      await _performFollowAction(currentUserId, targetUserId);
      // 検索結果を更新
      state = state.map((user) {
        if (user['id'] == targetUserId) {
          return {...user, 'is_following': !user['is_following']};
        }
        return user;
      }).toList();
    } catch (error) {
      print('フォロー/アンフォローエラー: $error');
    }
  }

  Future<void> _performFollowAction(
      String currentUserId, String targetUserId) async {
    final existingFollow = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('followed_id', targetUserId)
        .maybeSingle();

    if (existingFollow == null) {
      await supabase.from('follows').insert({
        'follower_id': currentUserId,
        'followed_id': targetUserId,
      });
    } else {
      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId);
    }
  }
}

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, List<Map<String, dynamic>>>(
        (ref) => UserSearchNotifier());
