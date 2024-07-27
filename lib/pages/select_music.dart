import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../components/recently_played_list.dart';
import 'liked_music.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_info.dart';
import '../providers/music_player_provider.dart';
import '../providers/music_control_provider.dart';
import '../providers/recently_played_provider.dart';

class SelectMusic extends ConsumerStatefulWidget {
  const SelectMusic({super.key});
  @override
  ConsumerState<SelectMusic> createState() => _SelectMusicState();
}

class _SelectMusicState extends ConsumerState<SelectMusic> {
  final _musicKitPlugin = MusicKit();
  String _developerToken = '';
  String _userToken = '';
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
    _timer?.cancel(); // 既存のタイマーをキャンセル
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) return; // ウィジェットがマウントされているか確認
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
    await _fetchTokens();
    if (!mounted) return;
    await fetchRecentlyPlayed();
    if (mounted && ref.read(recentlyPlayedProvider).isNotEmpty) {
      ref
          .read(musicControlProvider.notifier)
          .playSong(ref.read(recentlyPlayedProvider)[0]);
    }
  }

  Future<void> _fetchTokens() async {
    final developerToken = await _musicKitPlugin.requestDeveloperToken();
    final userToken = await _musicKitPlugin.requestUserToken(developerToken);
    if (mounted) {
      setState(() {
        _developerToken = developerToken;
        _userToken = userToken;
      });
    }
  }

  Future<void> fetchRecentlyPlayed() async {
    const url = 'https://api.music.apple.com/v1/me/recent/played/tracks';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_developerToken',
        'Music-User-Token': _userToken,
      },
    );

    if (!mounted) return; // ウィジェットがマウントされているか確認
    if (response.statusCode == 200) {
      ref
          .read(recentlyPlayedProvider.notifier)
          .setRecentlyPlayed(json.decode(response.body)['data']);
    } else {
      Logger().e('Failed to load recently played: ${response.body}');
      throw Exception('Failed to load recently played');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Recently Played Songs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserInfoPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: recentlyPlayed.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : const RecentlyPlayedList(),
            ),
            NavigationBar(
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Liked',
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectMusic(),
                    ),
                  );
                }
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedMusic(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
