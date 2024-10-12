import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../utils/user_utils.dart' as user_utils;
import '../notifiers/follow_notifier.dart';

final followProvider =
    StateNotifierProvider<FollowNotifier, void>((ref) => FollowNotifier());

final followCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    await user_utils.throwIfNotAuthenticated();
    final userId = user_utils.getCurrentUserId()!;
    final followersCount = await user_utils.supabase
        .from('follows')
        .select()
        .eq('followed_id', userId)
        .count();
    final followingCount = await user_utils.supabase
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .count();
    return {
      'followers': followersCount.count,
      'following': followingCount.count,
    };
  } catch (error) {
    Logger()
        .e('フォロー数の取得エラー: $error', error: error, stackTrace: StackTrace.current);
    return {'followers': 0, 'following': 0};
  }
});

final followersProvider =
    AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(_followersStreamProvider);
});

final _followersStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  try {
    await user_utils.throwIfNotAuthenticated();
    final userId = user_utils.getCurrentUserId()!;
    final stream = user_utils.supabase
        .from('follows')
        .stream(primaryKey: ['id'])
        .eq('followed_id', userId)
        .map((follows) async {
          final followerIds =
              follows.map((f) => f['follower_id'] as String).toList();
          if (followerIds.isNotEmpty) {
            return await user_utils.supabase
                .from('profiles')
                .select()
                .filter('id', 'in', followerIds);
          }
          return <Map<String, dynamic>>[];
        });
    await for (final followers in stream) {
      yield await followers;
    }
  } catch (error) {
    Logger().e('フォロワーリストの取得エラー: $error',
        error: error, stackTrace: StackTrace.current);
    yield [];
  }
});

final followingProvider =
    AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(_followingStreamProvider);
});

final _followingStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  try {
    await user_utils.throwIfNotAuthenticated();
    final userId = user_utils.getCurrentUserId()!;
    final stream = user_utils.supabase
        .from('follows')
        .stream(primaryKey: ['id'])
        .eq('follower_id', userId)
        .map((follows) async {
          final followingIds =
              follows.map((f) => f['followed_id'] as String).toList();
          if (followingIds.isNotEmpty) {
            return await user_utils.supabase
                .from('profiles')
                .select()
                .filter('id', 'in', followingIds);
          }
          return <Map<String, dynamic>>[];
        });
    await for (final following in stream) {
      yield await following;
    }
  } catch (error) {
    Logger().e('フォロー中リストの取得エラー: $error',
        error: error, stackTrace: StackTrace.current);
    yield [];
  }
});
