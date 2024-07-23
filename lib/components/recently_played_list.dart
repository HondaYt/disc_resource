import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart';
import 'song_card.dart';
import 'package:logger/logger.dart';

class RecentlyPlayedList extends StatefulWidget {
  final List<dynamic> recentlyPlayed;
  final AppinioSwiperController swiperController;
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final MusicPlayerPlaybackStatus wasMusicPlayerStatusBeforeSeek;
  final Function(Duration) onSeek;
  final Function() onSeekStart;
  final Function(Duration) onSeekEnd;
  final Function() onPause;
  final Function() onResume;
  final Function(Map<String, dynamic>) onPlaySong;

  const RecentlyPlayedList({
    super.key,
    required this.recentlyPlayed,
    required this.swiperController,
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.remainingTime,
    required this.musicPlayerStatus,
    required this.wasMusicPlayerStatusBeforeSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.onSeek,
    required this.onPause,
    required this.onResume,
    required this.onPlaySong,
  });

  @override
  State<RecentlyPlayedList> createState() => _RecentlyPlayedListState();
}

class _RecentlyPlayedListState extends State<RecentlyPlayedList> {
  bool _hasSwiped = false;

  @override
  void didUpdateWidget(RecentlyPlayedList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.remainingTime.inSeconds == 0 && !_hasSwiped) {
      if ((widget.musicPlayerStatus == MusicPlayerPlaybackStatus.paused &&
              widget.wasMusicPlayerStatusBeforeSeek ==
                  MusicPlayerPlaybackStatus.playing) ||
          (widget.musicPlayerStatus == MusicPlayerPlaybackStatus.playing &&
              widget.wasMusicPlayerStatusBeforeSeek ==
                  MusicPlayerPlaybackStatus.paused)) {
        widget.swiperController.swipeRight();
        _hasSwiped = true;
      }
    }

    if (widget.currentPlaybackTime.inSeconds == 0) {
      _hasSwiped = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppinioSwiper(
              controller: widget.swiperController,
              cardCount: widget.recentlyPlayed.length,
              cardBuilder: (BuildContext context, int index) {
                final song = widget.recentlyPlayed[index];
                return SongCard(
                  song: song,
                  currentPlaybackTime: widget.currentPlaybackTime,
                  songDuration: widget.songDuration,
                  remainingTime: widget.remainingTime,
                  musicPlayerStatus: widget.musicPlayerStatus,
                  wasMusicPlayerStatusBeforeSeek:
                      widget.wasMusicPlayerStatusBeforeSeek,
                  onSeek: widget.onSeek,
                  onSeekStart: widget.onSeekStart,
                  onSeekEnd: widget.onSeekEnd,
                  onPause: widget.onPause,
                  onResume: widget.onResume,
                  swiperController: widget.swiperController,
                );
              },
              onSwipeEnd: _swipeEnd,
              onEnd: _onEnd,
            ),
          ),
        ),
      ],
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        Logger().d('The card was swiped to the : ${activity.direction}');
        switch (activity.direction) {
          case AxisDirection.right:
            break;
          case AxisDirection.left:
            break;
          case AxisDirection.up:
            Logger().d('Swiped up');
            break;
          case AxisDirection.down:
            Logger().d('Swiped down');
            break;
        }
        Logger()
            .d('previous index: $previousIndex, target index: $targetIndex');
        widget.onPlaySong(widget.recentlyPlayed[targetIndex]);
        break;
      case Unswipe():
        widget.onPlaySong(widget.recentlyPlayed[targetIndex]);
        Logger().d('A ${activity.direction.name} swipe was undone.');
        Logger()
            .d('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        Logger().d('A swipe was cancelled');
        break;
      case DrivenActivity():
        Logger().d('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    Logger().d('end reached!');
    widget.onPause();
  }
}
