import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../utils/user_utils.dart';
import 'follow_provider.dart';

abstract class BaseUserNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  BaseUserNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> toggleFollow(String targetUserId) async {
    final followNotifier = ref.read(followProvider.notifier);
    await followNotifier.toggleFollow(targetUserId);

    state = state.map((user) {
      if (user['id'] == targetUserId) {
        return {...user, 'is_following': !user['is_following']};
      }
      return user;
    }).toList();
  }

  List<Map<String, dynamic>> processUserList(
      List<Map<String, dynamic>> userList, Set<String> followedUserIds) {
    return userList.map((profile) {
      return {
        ...profile,
        'is_following': followedUserIds.contains(profile['id']),
      };
    }).toList();
  }
}
