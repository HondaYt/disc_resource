import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/liked_songs_notifier.dart';

final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return LikedSongsNotifier();
});
