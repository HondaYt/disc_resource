import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
// import 'package:http/http.dart' as http;

import '../components/recently_played_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_player_provider.dart';
import '../providers/music_control_provider.dart';
import '../providers/recently_played_provider.dart';
import '../services/recently_played_fetcher_service.dart';

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

    await RecentlyPlayedFetcherService(ref).fetch();
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
                ElevatedButton.icon(
                  label: Text('再読み込み'),
                  onPressed: () {
                    RecentlyPlayedFetcherService(ref).fetch();
                  },
                  icon: Icon(Icons.refresh),
                )
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
