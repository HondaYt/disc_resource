import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_kit/music_kit.dart';
import 'package:logger/logger.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'music_player_provider.dart';

class MusicControlNotifier extends StateNotifier<void> {
  final MusicKit _musicKitPlugin;
  final Ref ref;
  final InteractiveSliderController sliderController;

  MusicControlNotifier(this._musicKitPlugin, this.ref, this.sliderController)
      : super(null);

  Future<void> playSong(Map<String, dynamic> song) async {
    try {
      await _musicKitPlugin.setQueue('songs', item: song);
      await _musicKitPlugin.play();
      ref.read(musicPlayerProvider.notifier).updateSongDuration(
          Duration(milliseconds: song['attributes']['durationInMillis']));
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
      ref
          .read(musicPlayerProvider.notifier)
          .updateCurrentPlaybackTime(position);
      sliderController.value = position.inSeconds.toDouble();
    } catch (e) {
      Logger().d('Error seeking to position: $e');
    }
  }

  Future<void> seekStart() async {
    ref.read(musicPlayerProvider.notifier).updateWasMusicPlayerStatusBeforeSeek(
        ref.read(musicPlayerProvider).musicPlayerStatus);
    pauseSong();
  }

  Future<void> seekEnd(Duration position) async {
    await seekTo(position);
    ref.read(musicPlayerProvider.notifier).updateCurrentPlaybackTime(position);
    if (ref.read(musicPlayerProvider).wasMusicPlayerStatusBeforeSeek ==
        MusicPlayerPlaybackStatus.playing) {
      resumeSong();
    }
  }
}

final musicControlProvider = StateNotifierProvider<MusicControlNotifier, void>(
  (ref) =>
      MusicControlNotifier(MusicKit(), ref, InteractiveSliderController(0.0)),
);
