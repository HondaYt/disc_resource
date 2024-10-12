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
import '../providers/read_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readProvider.notifier).fetchReadSongs();
      _markCurrentSongAsRead();
    });
  }

  void _markCurrentSongAsRead() {
    final recentlyPlayed = ref.read(recentlyPlayedProvider);
    if (recentlyPlayed.isNotEmpty) {
      final currentPost = recentlyPlayed[currentIndex].post;
      ref
          .read(readProvider.notifier)
          .markAsRead(currentPost['id'], swiped: false);
    }
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

    return AppinioSwiper(
      controller: swiperController,
      cardCount: recentlyPlayed.length,
      cardBuilder: (BuildContext context, int index) {
        final item = recentlyPlayed[index];
        return SongCard(
          item: item,
          isActive: index == currentIndex,
        );
      },
      swipeOptions: const SwipeOptions.symmetric(
        horizontal: true,
        vertical: false,
      ),
      onSwipeEnd:
          (int previousIndex, int? targetIndex, SwiperActivity activity) {
        _onSwipe(previousIndex, targetIndex, activity);
      },
      onEnd: _onEnd,
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

  Future<void> likeSong(RecentlyPlayedItem item) async {
    final ref = ProviderScope.containerOf(context);
    ref.read(likedSongsProvider.notifier).addSong(item.song);
  }

  void _onSwipe(int previousIndex, int? targetIndex, SwiperActivity activity) {
    if (targetIndex != null &&
        targetIndex >= 0 &&
        targetIndex < ref.read(recentlyPlayedProvider).length) {
      final targetPost = ref.read(recentlyPlayedProvider)[targetIndex].post;

      // 新しいtargetIndexの投稿をreadとしてマーク（swipedはfalse）
      ref
          .read(readProvider.notifier)
          .markAsRead(targetPost['id'], swiped: false);

      setState(() {
        currentIndex = targetIndex;
      });
      ref
          .read(providers.musicPlayerProvider.notifier)
          .updateCurrentSongIndex(targetIndex);
    }

    if (activity is Swipe) {
      _handleSwipe(previousIndex, activity);
    }
  }

  void _handleSwipe(int previousIndex, Swipe swipe) {
    final previousItem = ref.read(recentlyPlayedProvider)[previousIndex];

    Logger().d('The card was swiped to the : ${swipe.direction}');
    switch (swipe.direction) {
      case AxisDirection.right:
        ref.read(likedSongsProvider.notifier).addSong(previousItem.song);
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

    // スワイプされた投稿をswipedとしてマーク
    ref
        .read(readProvider.notifier)
        .markAsRead(previousItem.post['id'], swiped: true);

    ref
        .read(musicControlProvider.notifier)
        .playSong(ref.read(recentlyPlayedProvider)[currentIndex].song);
  }

  void _onEnd() {
    Logger().d('end reached!');
    ref.read(musicControlProvider.notifier).pauseSong();
  }
}
