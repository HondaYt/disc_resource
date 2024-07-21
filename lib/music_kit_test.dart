import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'components/recently_played_list.dart';

class MusicKitTest extends StatefulWidget {
  const MusicKitTest({super.key});
  @override
  State<MusicKitTest> createState() => _MusicKitTestState();
}

class _MusicKitTestState extends State<MusicKitTest> {
  final _musicKitPlugin = MusicKit();
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  String _developerToken = '';
  String _userToken = '';
  List<dynamic> _recentlyPlayed = [];
  Timer? _timer;
  Duration _currentPlaybackTime = Duration.zero;
  Duration _songDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  // double _songProgress = 0.0;
  MusicPlayerPlaybackStatus _musicPlayerStatus =
      MusicPlayerPlaybackStatus.stopped;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    startPlaybackTimeUpdater();
    _musicKitPlugin.onMusicPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _musicPlayerStatus = state.playbackStatus;
        });
      }
    });
  }

  void startPlaybackTimeUpdater() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (_musicPlayerStatus != MusicPlayerPlaybackStatus.playing) return;
      final playbackTime = await _musicKitPlugin.playbackTime;
      if (mounted) {
        setState(() {
          _currentPlaybackTime =
              Duration(milliseconds: (playbackTime * 1000).toInt());
          _remainingTime = _songDuration - _currentPlaybackTime;
          // _songProgress = _currentPlaybackTime.inMilliseconds /
          //     _songDuration.inMilliseconds;
        });
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
    if (_recentlyPlayed.isNotEmpty) {
      playSong(_recentlyPlayed[0]);
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

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        _recentlyPlayed = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load recently played');
    }
  }

  Future<void> playSong(Map<String, dynamic> song) async {
    try {
      await _musicKitPlugin.setQueue('songs', item: song);
      await _musicKitPlugin.play();
      setState(() {
        _songDuration =
            Duration(milliseconds: song['attributes']['durationInMillis']);
      });
    } catch (e) {
      Logger().d('Error playing song: $e');
    }
  }

  Future<void> resumeSong() async {
    try {
      await _musicKitPlugin.play();
    } catch (e) {
      Logger().d('Error resuming song: $e');
    }
  }

  Future<void> pauseSong() async {
    try {
      await _musicKitPlugin.pause();
    } catch (e) {
      Logger().d('Error pausing song: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _musicKitPlugin.setPlaybackTime(position.inSeconds.toDouble());
      setState(() {
        _currentPlaybackTime = position;
      });
    } catch (e) {
      Logger().d('Error seeking to position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Recently Played Songs'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _recentlyPlayed.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RecentlyPlayedList(
                      recentlyPlayed: _recentlyPlayed,
                      swiperController: _swiperController,
                      currentPlaybackTime: _currentPlaybackTime,
                      songDuration: _songDuration,
                      remainingTime: _remainingTime,
                      // songProgress: _songProgress,
                      musicPlayerStatus: _musicPlayerStatus,
                      onSeek: seekTo,
                      onPause: pauseSong,
                      onResume: resumeSong,
                      onPlaySong: playSong,
                      // onSeekStart: () {
                      //   _wasPlayingBeforeSeek = _musicPlayerStatus ==
                      //       MusicPlayerPlaybackStatus.playing;
                      //   pauseSong();
                      // },
                      // onSeekEnd: () {
                      //   if (_wasPlayingBeforeSeek) {
                      //     resumeSong();
                      //   }
                      // },
                    ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
