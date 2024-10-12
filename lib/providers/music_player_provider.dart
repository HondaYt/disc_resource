import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/music_player_notifier.dart';
import '../models/music_player_state.dart';

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerNotifier, AppMusicPlayerState>(
        (ref) => MusicPlayerNotifier());
