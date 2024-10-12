import 'package:logger/logger.dart';
import '../utils/user_utils.dart' as user_utils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowNotifier extends StateNotifier<void> {
  FollowNotifier() : super(null);

  Future<void> toggleFollow(String targetUserId) async {
    try {
      await user_utils.throwIfNotAuthenticated();
      final currentUserId = user_utils.getCurrentUserId()!;
      await _performFollowAction(currentUserId, targetUserId);
    } catch (error) {
      Logger().e('フォロー/アンフォローエラー: $error',
          error: error, stackTrace: StackTrace.current);
    }
  }

  Future<void> _performFollowAction(
      String currentUserId, String targetUserId) async {
    final existingFollow = await user_utils.supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('followed_id', targetUserId)
        .maybeSingle();

    if (existingFollow == null) {
      await user_utils.supabase.from('follows').insert({
        'follower_id': currentUserId,
        'followed_id': targetUserId,
      });
    } else {
      await user_utils.supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId);
    }
  }

  Future<Set<String>> getFollowedUserIds(String currentUserId) async {
    final followsResponse = await user_utils.supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId);
    return Set<String>.from(
        followsResponse.map((follow) => follow['followed_id'] as String));
  }
}
