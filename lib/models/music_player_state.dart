import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';

class AppMusicPlayerState {
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final MusicPlayerPlaybackStatus wasMusicPlayerStatusBeforeSeek;
  final InteractiveSliderController sliderController;
  final int currentSongIndex;

  AppMusicPlayerState({
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.remainingTime,
    required this.musicPlayerStatus,
    required this.wasMusicPlayerStatusBeforeSeek,
    required this.sliderController,
    required this.currentSongIndex,
  });

  AppMusicPlayerState copyWith({
    Duration? currentPlaybackTime,
    Duration? songDuration,
    Duration? remainingTime,
    MusicPlayerPlaybackStatus? musicPlayerStatus,
    MusicPlayerPlaybackStatus? wasMusicPlayerStatusBeforeSeek,
    InteractiveSliderController? sliderController,
    int? currentSongIndex,
  }) {
    return AppMusicPlayerState(
      currentPlaybackTime: currentPlaybackTime ?? this.currentPlaybackTime,
      songDuration: songDuration ?? this.songDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      musicPlayerStatus: musicPlayerStatus ?? this.musicPlayerStatus,
      wasMusicPlayerStatusBeforeSeek:
          wasMusicPlayerStatusBeforeSeek ?? this.wasMusicPlayerStatusBeforeSeek,
      sliderController: sliderController ?? this.sliderController,
      currentSongIndex: currentSongIndex ?? this.currentSongIndex,
    );
  }
}
