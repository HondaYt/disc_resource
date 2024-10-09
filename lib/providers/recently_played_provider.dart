import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentlyPlayedItem {
  final Map<String, dynamic> song;
  final String userName;
  final DateTime postedAt;

  RecentlyPlayedItem({
    required this.song,
    required this.userName,
    required this.postedAt,
  });
}

class RecentlyPlayedNotifier extends StateNotifier<List<RecentlyPlayedItem>> {
  RecentlyPlayedNotifier() : super([]);

  void setRecentlyPlayed(List<RecentlyPlayedItem> recentlyPlayed) {
    state = recentlyPlayed;
  }
}

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<RecentlyPlayedItem>>(
        (ref) => RecentlyPlayedNotifier());
