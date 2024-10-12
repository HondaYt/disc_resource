import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:convert';
import 'package:logger/logger.dart';
import '../providers/recently_played_provider.dart';

class RecentlyPlayedUtils {
  final WidgetRef ref;

  RecentlyPlayedUtils(this.ref);

  Future<void> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final followedUsersResponse = await supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', currentUserId);

      final followedUserIds = followedUsersResponse
          .map((follow) => follow['followed_id'] as String)
          .toList();

      if (followedUserIds.isEmpty) {
        ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
        return;
      }

      final DateTime twentyFourHoursAgo =
          DateTime.now().subtract(Duration(hours: 24));

      final postsResponse = await supabase
          .from('posts')
          .select('*')
          .inFilter('user_id', followedUserIds)
          .gte('created_at', twentyFourHoursAgo.toIso8601String())
          .order('created_at', ascending: false);

      if (postsResponse.isNotEmpty) {
        List<RecentlyPlayedItem> recentlyPlayedList = [];
        for (var post in postsResponse) {
          // 曲の詳細情報を取得
          final songResponse = await supabase
              .from('songs')
              .select('details')
              .eq('id', post['song_id'])
              .single();

          // ユーザー情報を取得
          final userResponse = await supabase
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', post['user_id'])
              .single();

          recentlyPlayedList.add(RecentlyPlayedItem(
            song: songResponse['details'],
            post: post, // 投稿データを追加
            userName: userResponse['username'] ?? '不明なユーザー',
            postedAt: DateTime.parse(post['created_at']),
            avatarUrl: userResponse['avatar_url'],
          ));
        }
        ref
            .read(recentlyPlayedProvider.notifier)
            .setRecentlyPlayed(recentlyPlayedList);
      } else {
        ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
      }
    } catch (e) {
      Logger().e('最近再生した曲の取得に失敗しました: $e');
      ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
    }
  }
}
