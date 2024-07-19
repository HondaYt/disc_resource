import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
// import 'swiper_test.dart';

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

  bool _isPlaying = false;
  Timer? _timer;
  Duration _currentPlaybackTime = Duration.zero;
  Duration _songDuration = Duration.zero; // 曲の長さを保持する変数
  bool _wasPlayingBeforeSeek = false; // シーク前の再生状態を保持する変数

  @override
  void initState() {
    super.initState();
    initPlatformState();
    startPlaybackTimeUpdater();
  }

  void startPlaybackTimeUpdater() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isPlaying) return;
      final playbackTime = await _musicKitPlugin.playbackTime;
      // Logger().d('Current playback time: $playbackTime');
      if (mounted) {
        setState(() {
          _currentPlaybackTime =
              Duration(milliseconds: (playbackTime * 1000).toInt());
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
    setState(() {
      _developerToken = developerToken;
      _userToken = userToken;
    });
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
        _isPlaying = true;
        _songDuration = Duration(
            milliseconds: song['attributes']['durationInMillis']); // 曲の長さを設定
      });
    } catch (e) {
      Logger().d('Error playing song: $e');
    }
  }

  Future<void> resumeSong() async {
    try {
      await _musicKitPlugin.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      Logger().d('Error resuming song: $e');
    }
  }

  Future<void> pauseSong() async {
    try {
      await _musicKitPlugin.pause();
      setState(() {
        _isPlaying = false;
      });
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
          // actions: [
          //   IconButton(
          //       icon: const Icon(Icons.arrow_forward_ios),
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => const SwiperTest(),
          //           ),
          //         );
          //       }),
          // ],
        ),
        body: _recentlyPlayed.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RecentlyPlayedList(
                recentlyPlayed: _recentlyPlayed,
                swiperController: _swiperController,
                currentPlaybackTime: _currentPlaybackTime,
                songDuration: _songDuration,
                isPlaying: _isPlaying,
                onSeek: seekTo,
                onPause: pauseSong,
                onResume: resumeSong,
                onPlaySong: playSong,
                onSeekStart: () {
                  _wasPlayingBeforeSeek = _isPlaying; // シーク前の再生状態を保存
                  pauseSong();
                },
                onSeekEnd: () {
                  if (_wasPlayingBeforeSeek) {
                    resumeSong();
                  }
                },
              ),
      ),
    );
  }
}

class RecentlyPlayedList extends StatelessWidget {
  final List<dynamic> recentlyPlayed;
  final AppinioSwiperController swiperController;
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final bool isPlaying;
  final Function(Duration) onSeek;
  final Function() onPause;
  final Function() onResume;
  final Function(Map<String, dynamic>) onPlaySong;
  final Function() onSeekStart;
  final Function() onSeekEnd;

  const RecentlyPlayedList({
    super.key,
    required this.recentlyPlayed,
    required this.swiperController,
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.isPlaying,
    required this.onSeek,
    required this.onPause,
    required this.onResume,
    required this.onPlaySong,
    required this.onSeekStart,
    required this.onSeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppinioSwiper(
              controller: swiperController,
              cardCount: recentlyPlayed.length,
              cardBuilder: (BuildContext context, int index) {
                final song = recentlyPlayed[index];
                final durationMs = song['attributes']['durationInMillis'];
                final durationMin = (durationMs / 60000).floor();
                final durationSec = ((durationMs % 60000) / 1000).floor();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 318.0,
                            child: Image.network(
                              song['attributes']['artwork']['url']
                                  .replaceAll('{w}', '700')
                                  .replaceAll('{h}', '700'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(song['attributes']['name']),
                        Text(song['attributes']['artistName']),
                        Text(
                            'Duration: $durationMin:${durationSec.toString().padLeft(2, '0')}'),
                        Text(
                            'Current Playback Time: ${currentPlaybackTime.inMinutes}:${(currentPlaybackTime.inSeconds % 60).toString().padLeft(2, '0')}'),
                        Slider(
                          value: currentPlaybackTime.inSeconds.toDouble(),
                          max: songDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            onSeek(Duration(seconds: value.toInt()));
                          },
                          onChangeStart: (value) {
                            onSeekStart(); // シーク開始時に呼び出し
                          },
                          onChangeEnd: (value) {
                            onSeekEnd(); // シーク終了時に呼び出し
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.keyboard_double_arrow_left),
                              onPressed: () {
                                swiperController.unswipe();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow),
                              onPressed: () {
                                if (isPlaying) {
                                  onPause();
                                } else {
                                  onResume();
                                }
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.keyboard_double_arrow_right),
                              onPressed: () {
                                swiperController.swipeRight();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              onSwipeEnd: (int previousIndex, int targetIndex,
                  SwiperActivity activity) {
                // if (targetIndex >= 0 && targetIndex < recentlyPlayed.length) {
                if (targetIndex == previousIndex) return;
                if (targetIndex >= 0) {
                  onPlaySong(recentlyPlayed[targetIndex]);
                }
                Logger().d('targetIndex: $targetIndex to $previousIndex');
              },
              onEnd: () {
                Logger().d('End of swipe');
                onPause();
              },
            ),
          ),
        ),
      ],
    );
  }
}
