import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../utils/user_utils.dart' as user_utils;
import 'base_user_notifier.dart';
import 'follow_provider.dart';

class UserSearchNotifier extends BaseUserNotifier {
  UserSearchNotifier(super.ref);

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      await user_utils.throwIfNotAuthenticated();
      final currentUserId = user_utils.getCurrentUserId()!;
      final searchResults = await _fetchSearchResults(query, currentUserId);
      final followNotifier = ref.read(followProvider.notifier);
      final followedUserIds =
          await followNotifier.getFollowedUserIds(currentUserId);

      state = processUserList(searchResults, followedUserIds);
    } catch (error) {
      Logger().e('検索エラー: $error', error: error, stackTrace: StackTrace.current);
      state = [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(
      String query, String currentUserId) async {
    return await user_utils.supabase
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,user_id.ilike.%$query%')
        .neq('id', currentUserId)
        .limit(20);
  }
}

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, List<Map<String, dynamic>>>(
        (ref) => UserSearchNotifier(ref));
