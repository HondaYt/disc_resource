import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';

class MusicPlayerState {
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final MusicPlayerPlaybackStatus wasMusicPlayerStatusBeforeSeek;
  final InteractiveSliderController sliderController;
  final int currentSongIndex;

  MusicPlayerState({
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.remainingTime,
    required this.musicPlayerStatus,
    required this.wasMusicPlayerStatusBeforeSeek,
    required this.sliderController,
    required this.currentSongIndex,
  });

  MusicPlayerState copyWith({
    Duration? currentPlaybackTime,
    Duration? songDuration,
    Duration? remainingTime,
    MusicPlayerPlaybackStatus? musicPlayerStatus,
    MusicPlayerPlaybackStatus? wasMusicPlayerStatusBeforeSeek,
    InteractiveSliderController? sliderController,
    int? currentSongIndex,
  }) {
    return MusicPlayerState(
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

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  MusicPlayerNotifier()
      : super(MusicPlayerState(
          currentPlaybackTime: Duration.zero,
          songDuration: Duration.zero,
          remainingTime: Duration.zero,
          musicPlayerStatus: MusicPlayerPlaybackStatus.stopped,
          wasMusicPlayerStatusBeforeSeek: MusicPlayerPlaybackStatus.stopped,
          sliderController: InteractiveSliderController(0.0),
          currentSongIndex: 0,
        ));

  void updateCurrentPlaybackTime(Duration time) {
    state = state.copyWith(currentPlaybackTime: time);
  }

  void updateSongDuration(Duration duration) {
    state = state.copyWith(songDuration: duration);
  }

  void updateRemainingTime(Duration time) {
    state = state.copyWith(remainingTime: time);
  }

  void updateMusicPlayerStatus(MusicPlayerPlaybackStatus status) {
    state = state.copyWith(musicPlayerStatus: status);
  }

  void updateWasMusicPlayerStatusBeforeSeek(MusicPlayerPlaybackStatus status) {
    state = state.copyWith(wasMusicPlayerStatusBeforeSeek: status);
  }

  void updateSliderControllerValue(double value) {
    state.sliderController.value = value;
  }

  void updateCurrentSongIndex(int index) {
    state = state.copyWith(currentSongIndex: index);
  }
}

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>(
        (ref) => MusicPlayerNotifier());
