import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart';
import 'song_card.dart';
import 'package:logger/logger.dart';

class RecentlyPlayedList extends StatelessWidget {
  final List<dynamic> recentlyPlayed;
  final AppinioSwiperController swiperController;
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  // final double songProgress;
  // final bool isPlaying;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final Function(Duration) onSeek;
  final Function() onPause;
  final Function() onResume;
  final Function(Map<String, dynamic>) onPlaySong;
  // final Function() onSeekStart;
  // final Function() onSeekEnd;

  const RecentlyPlayedList({
    super.key,
    required this.recentlyPlayed,
    required this.swiperController,
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.remainingTime,
    // required this.songProgress,
    // required this.isPlaying,
    required this.musicPlayerStatus,
    required this.onSeek,
    required this.onPause,
    required this.onResume,
    required this.onPlaySong,
    // required this.onSeekStart,
    // required this.onSeekEnd,
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
                return SongCard(
                  song: song,
                  currentPlaybackTime: currentPlaybackTime,
                  songDuration: songDuration,
                  remainingTime: remainingTime,
                  // songProgress: songProgress,
                  // isPlaying: isPlaying,
                  musicPlayerStatus: musicPlayerStatus,
                  onSeek: onSeek,
                  // onSeekStart: onSeekStart,
                  // onSeekEnd: onSeekEnd,
                  onPause: onPause,
                  onResume: onResume,
                  swiperController: swiperController,
                );
              },
              onSwipeEnd: (int previousIndex, int targetIndex,
                  SwiperActivity activity) {
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
