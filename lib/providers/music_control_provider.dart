import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';
import '../notifiers/music_control_notifier.dart';

final musicControlProvider = StateNotifierProvider<MusicControlNotifier, void>(
  (ref) =>
      MusicControlNotifier(MusicKit(), ref, InteractiveSliderController(0.0)),
);
