import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart' as music_kit;
import 'song_card.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/liked_songs_provider.dart';
import '../providers/music_player_provider.dart' as providers;
import '../providers/music_control_provider.dart';
import '../providers/swiper_controller_provider.dart';
import '../providers/recently_played_provider.dart';

class RecentlyPlayedList extends ConsumerStatefulWidget {
  const RecentlyPlayedList({super.key});

  @override
  RecentlyPlayedListState createState() => RecentlyPlayedListState();
}

class RecentlyPlayedListState extends ConsumerState<RecentlyPlayedList> {
  bool _hasSwiped = false;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final swiperController = ref.watch(swiperControllerProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);

    ref.listen(providers.musicPlayerProvider, (previous, next) {
      final swiperController = ref.read(swiperControllerProvider.notifier);

      if (next.remainingTime.inSeconds == 0 &&
          !_hasSwiped &&
          next.currentPlaybackTime.inSeconds != 0 &&
          shouldSwipeRight(next)) {
        swiperController.swipeRight();
        _hasSwiped = true;
      }

      if (next.currentPlaybackTime.inSeconds == 0) {
        _hasSwiped = false;
      }
    });

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
                  isActive: index == currentIndex,
                );
              },
              onSwipeEnd: (previousIndex, targetIndex, activity) {
                _swipeEnd(previousIndex, targetIndex, activity);
                setState(() {
                  currentIndex = targetIndex;
                });
                ref
                    .read(providers.musicPlayerProvider.notifier)
                    .updateCurrentSongIndex(targetIndex);
              },
              onEnd: _onEnd,
            ),
          ),
        ),
      ],
    );
  }

  bool shouldSwipeRight(providers.MusicPlayerState musicPlayerState) {
    return (musicPlayerState.musicPlayerStatus ==
                music_kit.MusicPlayerPlaybackStatus.paused &&
            musicPlayerState.wasMusicPlayerStatusBeforeSeek ==
                music_kit.MusicPlayerPlaybackStatus.playing) ||
        (musicPlayerState.musicPlayerStatus ==
                music_kit.MusicPlayerPlaybackStatus.playing &&
            musicPlayerState.wasMusicPlayerStatusBeforeSeek ==
                music_kit.MusicPlayerPlaybackStatus.paused) ||
        (musicPlayerState.musicPlayerStatus !=
                music_kit.MusicPlayerPlaybackStatus.stopped &&
            musicPlayerState.wasMusicPlayerStatusBeforeSeek ==
                music_kit.MusicPlayerPlaybackStatus.stopped);
  }

  Future<void> likeSong(Map<String, dynamic> song) async {
    final ref = ProviderScope.containerOf(context);
    ref.read(likedSongsProvider.notifier).addSong(song);
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    if (targetIndex < 0 ||
        targetIndex >= ref.read(recentlyPlayedProvider).length) {
      Logger().d('Invalid target index: $targetIndex');
      return;
    }

    switch (activity) {
      case Swipe():
        Logger().d('The card was swiped to the : ${activity.direction}');
        switch (activity.direction) {
          case AxisDirection.right:
            final ref = ProviderScope.containerOf(context);
            ref
                .read(likedSongsProvider.notifier)
                .addSong(ref.read(recentlyPlayedProvider)[previousIndex]);
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
        ref
            .read(musicControlProvider.notifier)
            .playSong(ref.read(recentlyPlayedProvider)[targetIndex]);
        break;
      case Unswipe():
        ref
            .read(musicControlProvider.notifier)
            .playSong(ref.read(recentlyPlayedProvider)[targetIndex]);
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
    ref.read(musicControlProvider.notifier).pauseSong();
  }
}
