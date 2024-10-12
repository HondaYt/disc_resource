import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';
import '../models/music_player_state.dart';

class MusicPlayerNotifier extends StateNotifier<AppMusicPlayerState> {
  MusicPlayerNotifier()
      : super(AppMusicPlayerState(
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
