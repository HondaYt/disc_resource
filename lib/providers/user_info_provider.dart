import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final supabase = Supabase.instance.client;

class UserInfoNotifier extends StateNotifier<Map<String, dynamic>?> {
  UserInfoNotifier() : super(null) {
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data =
            await supabase.from('profiles').select().eq('id', user.id).single();
        state = data;
      } else {
        state = null;
      }
    } catch (error) {
      Logger().e('ユーザー情報の取得エラー: $error');
      state = null;
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> newInfo) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update(newInfo).eq('id', user.id);
        await fetchUserInfo();
      } else {
        throw Exception('ユーザーが認証されていません');
      }
    } catch (error) {
      Logger().e('ユーザー情報の更新エラー: $error');
    }
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, Map<String, dynamic>?>(
        (ref) => UserInfoNotifier());

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
