import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../components/recently_played_list.dart';
import 'liked_music.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/liked_songs_provider.dart';
import 'user_info.dart';
import 'package:interactive_slider/interactive_slider.dart';

class SelectMusic extends StatefulWidget {
  const SelectMusic({super.key});
  @override
  State<SelectMusic> createState() => _SelectMusicState();
}

class _SelectMusicState extends State<SelectMusic> {
  final _musicKitPlugin = MusicKit();
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  final InteractiveSliderController _sliderController =
      InteractiveSliderController(0.0);
  String _developerToken = '';
  String _userToken = '';
  List<dynamic> _recentlyPlayed = [];
  Timer? _timer;
  Duration _currentPlaybackTime = Duration.zero;
  Duration _songDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  MusicPlayerPlaybackStatus _musicPlayerStatus =
      MusicPlayerPlaybackStatus.stopped;
  MusicPlayerPlaybackStatus _wasMusicPlayerStatusBeforeSeek =
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
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sliderController.dispose();
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
      Logger().e('Failed to load recently played: ${response.body}');
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

  Future<void> seekStart() async {
    _wasMusicPlayerStatusBeforeSeek = _musicPlayerStatus;
    pauseSong();
  }

  Future<void> seekEnd(Duration position) async {
    await seekTo(position);
    if (_wasMusicPlayerStatusBeforeSeek == MusicPlayerPlaybackStatus.playing) {
      resumeSong();
    }
  }

  Future<void> likeSong(Map<String, dynamic> song) async {
    final ref = ProviderScope.containerOf(context);
    ref.read(likedSongsProvider.notifier).addSong(song);
  }

  @override
  Widget build(BuildContext context) {
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
              child: _recentlyPlayed.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RecentlyPlayedList(
                      recentlyPlayed: _recentlyPlayed,
                      swiperController: _swiperController,
                      currentPlaybackTime: _currentPlaybackTime,
                      songDuration: _songDuration,
                      remainingTime: _remainingTime,
                      musicPlayerStatus: _musicPlayerStatus,
                      wasMusicPlayerStatusBeforeSeek:
                          _wasMusicPlayerStatusBeforeSeek,
                      onSeekStart: seekStart,
                      onSeekEnd: seekEnd,
                      onSeek: seekTo,
                      onPause: pauseSong,
                      onResume: resumeSong,
                      onPlaySong: playSong,
                      onLikeSong: likeSong,
                      sliderController: _sliderController,
                    ),
            ),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.favorite, size: 20),
            //   label: const Text('Liked', style: TextStyle(fontSize: 18)),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const LikedMusic(),
            //       ),
            //     );
            //   },
            // ),

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
            // SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
