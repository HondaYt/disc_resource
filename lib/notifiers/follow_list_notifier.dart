import 'package:logger/logger.dart';
import '../utils/user_utils.dart';
import '../notifiers/base_user_notifier.dart';

class FollowListNotifier extends BaseUserNotifier {
  FollowListNotifier(super.ref);

  Future<void> fetchFollowList(bool isFollowers) async {
    try {
      await throwIfNotAuthenticated();
      final currentUserId = getCurrentUserId()!;

      final List<Map<String, dynamic>> followList =
          await _fetchFollowData(currentUserId, isFollowers);

      Logger().d('取得したフォローリスト: $followList');

      state = followList;
    } catch (error) {
      Logger().e('フォローリスト取得エラー: $error');
      state = [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFollowData(
      String currentUserId, bool isFollowers) async {
    final String column = isFollowers ? 'followed_id' : 'follower_id';
    final String oppositeColumn = isFollowers ? 'follower_id' : 'followed_id';

    final followResult = await supabase
        .from('follows')
        .select(oppositeColumn)
        .eq(column, currentUserId);

    final userIds = (followResult as List<dynamic>)
        .map((row) => row[oppositeColumn] as String)
        .toList();

    if (userIds.isEmpty) {
      return [];
    }

    final profilesResult =
        await supabase.from('profiles').select('*').inFilter('id', userIds);

    return (profilesResult as List<dynamic>).map((profile) {
      return {
        ...Map<String, dynamic>.from(profile),
        'is_following': !isFollowers,
      };
    }).toList();
  }
}
