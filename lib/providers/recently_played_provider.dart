import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentlyPlayedNotifier extends StateNotifier<List<dynamic>> {
  RecentlyPlayedNotifier() : super([]);

  void setRecentlyPlayed(List<dynamic> recentlyPlayed) {
    state = recentlyPlayed;
  }
}

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<dynamic>>(
        (ref) => RecentlyPlayedNotifier());
