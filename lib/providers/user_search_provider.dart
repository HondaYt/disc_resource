import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../utils/user_utils.dart';
import 'base_user_notifier.dart';
import 'follow_provider.dart';

final supabase = Supabase.instance.client;

class UserSearchNotifier extends BaseUserNotifier {
  UserSearchNotifier(super.ref);

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      await throwIfNotAuthenticated();
      final currentUserId = getCurrentUserId()!;
      final searchResults = await _fetchSearchResults(query, currentUserId);
      final followNotifier = ref.read(followProvider.notifier);
      final followedUserIds =
          await followNotifier.getFollowedUserIds(currentUserId);

      state = processUserList(searchResults, followedUserIds);
    } catch (error) {
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

  @override
  Future<void> toggleFollow(String targetUserId) async {
    final followNotifier = ref.read(followProvider.notifier);
    await followNotifier.toggleFollow(targetUserId);

    // 状態を更新
    state = state.map((user) {
      if (user['id'] == targetUserId) {
        return {...user, 'is_following': !user['is_following']};
      }
      return user;
    }).toList();
  }
}

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, List<Map<String, dynamic>>>(
        (ref) => UserSearchNotifier(ref));
