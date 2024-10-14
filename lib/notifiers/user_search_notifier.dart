import 'package:logger/logger.dart';
import '../utils/user_utils.dart';
import '../notifiers/base_user_notifier.dart';
import '../providers/follow_provider.dart';

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
      Logger().e('検索エラー: $error', error: error, stackTrace: StackTrace.current);
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
}
