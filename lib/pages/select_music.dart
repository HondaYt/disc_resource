import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../components/recently_played_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_player_provider.dart';
import '../providers/music_control_provider.dart';
import '../providers/recently_played_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectMusicPage extends ConsumerStatefulWidget {
  const SelectMusicPage({super.key});
  @override
  ConsumerState<SelectMusicPage> createState() => _SelectMusicPageState();
}

class _SelectMusicPageState extends ConsumerState<SelectMusicPage> {
  final _musicKitPlugin = MusicKit();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _musicKitPlugin.onMusicPlayerStateChanged.listen((state) {
      if (mounted) {
        ref
            .read(musicPlayerProvider.notifier)
            .updateMusicPlayerStatus(state.playbackStatus);
        if (state.playbackStatus == MusicPlayerPlaybackStatus.playing) {
          startPlaybackTimeUpdater();
        } else {
          _timer?.cancel();
        }
      }
    });
  }

  void startPlaybackTimeUpdater() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) return;
      if (ref.read(musicPlayerProvider).musicPlayerStatus !=
          MusicPlayerPlaybackStatus.playing) return;
      final playbackTime = await _musicKitPlugin.playbackTime;
      if (mounted) {
        ref.read(musicPlayerProvider.notifier).updateCurrentPlaybackTime(
            Duration(milliseconds: (playbackTime * 1000).toInt()));
        ref.read(musicPlayerProvider.notifier).updateRemainingTime(
            ref.read(musicPlayerProvider).songDuration -
                ref.read(musicPlayerProvider).currentPlaybackTime);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    await _fetchTokens();
    if (!mounted) return;

    await fetchRecentlyPlayed();
    if (!mounted) return;

    if (ref.read(recentlyPlayedProvider).isNotEmpty) {
      ref
          .read(musicControlProvider.notifier)
          .playSong(ref.read(recentlyPlayedProvider)[0].song);
    }
  }

  Future<void> _fetchTokens() async {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchRecentlyPlayed() async {
    try {
      final supabase = Supabase.instance.client;

      // 現在のユーザーのIDを取得
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // フォローしているユーザーのIDを取得
      final followedUsersResponse = await supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', currentUserId);

      final followedUserIds = followedUsersResponse
          .map((follow) => follow['followed_id'] as String)
          .toList();

      if (followedUserIds.isEmpty) {
        // フォローしているユーザーがいない場合
        ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
        return;
      }

      // フォローしているユーザーの投稿を取得
      final postsResponse = await supabase
          .from('posts')
          .select('*')
          .inFilter('user_id', followedUserIds)
          .order('created_at', ascending: false)
          .limit(10);

      if (!mounted) return;

      if (postsResponse.isNotEmpty) {
        List<RecentlyPlayedItem> recentlyPlayedList = [];
        for (var post in postsResponse) {
          // ユーザー情報を別途取得
          final userResponse = await supabase
              .from('profiles')
              .select('username, avatar_url') // avatar_urlを追加
              .eq('id', post['user_id'])
              .single();

          final recentlyPlayedData = json.decode(post['recently_played']);
          for (var songData in recentlyPlayedData['data']) {
            recentlyPlayedList.add(RecentlyPlayedItem(
              song: songData,
              userName: userResponse['username'] ?? '不明なユーザー',
              postedAt: DateTime.parse(post['created_at']),
              avatarUrl: userResponse['avatar_url'], // 追加
            ));
          }
        }
        ref
            .read(recentlyPlayedProvider.notifier)
            .setRecentlyPlayed(recentlyPlayedList);
      } else {
        // フォローしているユーザーの投稿がない場合
        ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
      }
    } catch (e) {
      Logger().e('最近再生した曲の取得に失敗しました: $e');
      // エラーが発生した場合も空のリストをセット
      ref.read(recentlyPlayedProvider.notifier).setRecentlyPlayed([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    return recentlyPlayed.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'まだ曲がありません',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'フォローしているユーザーが曲を再生すると\nここに表示されます',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: RecentlyPlayedList(),
            ),
          );
  }
}
