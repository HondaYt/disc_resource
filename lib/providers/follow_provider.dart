import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final supabase = Supabase.instance.client;

class FollowNotifier extends StateNotifier<void> {
  FollowNotifier() : super(null);

  Future<void> toggleFollow(String targetUserId) async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      Logger().e('ユーザーが認証されていません');
      return;
    }
    try {
      await _performFollowAction(currentUserId, targetUserId);
    } catch (error) {
      Logger().e('フォロー/アンフォローエラー: $error');
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

  // 新しいメソッド
  Future<Set<String>> getFollowedUserIds(String currentUserId) async {
    final followsResponse = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId);
    return Set<String>.from(
        followsResponse.map((follow) => follow['followed_id'] as String));
  }
}

final followProvider =
    StateNotifierProvider<FollowNotifier, void>((ref) => FollowNotifier());

// フォロワー数とフォロー中の数を取得するプロバイダー
final followCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final followersCount = await supabase
          .from('follows')
          .select()
          .eq('followed_id', user.id)
          .count();
      final followingCount = await supabase
          .from('follows')
          .select()
          .eq('follower_id', user.id)
          .count();
      return {
        'followers': followersCount.count,
        'following': followingCount.count,
      };
    }
  } catch (error) {
    Logger().e('フォロー数の取得エラー: $error');
  }
  return {'followers': 0, 'following': 0};
});

// フォロワーリストを取得するプロバイダー
final followersProvider =
    AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(_followersStreamProvider);
});

final _followersStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final user = supabase.auth.currentUser;
  if (user != null) {
    final stream = supabase
        .from('follows')
        .stream(primaryKey: ['id'])
        .eq('followed_id', user.id)
        .map((follows) async {
          final followerIds =
              follows.map((f) => f['follower_id'] as String).toList();
          if (followerIds.isNotEmpty) {
            return await supabase
                .from('profiles')
                .select()
                .filter('id', 'in', followerIds);
          }
          return <Map<String, dynamic>>[];
        });
    await for (final followers in stream) {
      yield await followers;
    }
  } else {
    yield [];
  }
});

// フォロー中のユーザーリストを取得するプロバイダー
final followingProvider =
    AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(_followingStreamProvider);
});

final _followingStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final user = supabase.auth.currentUser;
  if (user != null) {
    final stream = supabase
        .from('follows')
        .stream(primaryKey: ['id'])
        .eq('follower_id', user.id)
        .map((follows) async {
          final followingIds =
              follows.map((f) => f['followed_id'] as String).toList();
          if (followingIds.isNotEmpty) {
            return await supabase
                .from('profiles')
                .select()
                .filter('id', 'in', followingIds);
          }
          return <Map<String, dynamic>>[];
        });
    await for (final following in stream) {
      yield await following;
    }
  } else {
    yield [];
  }
});
