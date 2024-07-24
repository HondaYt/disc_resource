import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikedSongsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LikedSongsNotifier() : super([]);

  void addSong(Map<String, dynamic> song) {
    state = [...state, song];
  }
}

final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return LikedSongsNotifier();
});
