import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentlyPlayedItem {
  final Map<String, dynamic> song;
  final Map<String, dynamic> post; // 追加
  final String userName;
  final DateTime postedAt;
  final String? avatarUrl; // 追加

  RecentlyPlayedItem({
    required this.song,
    required this.post, // 追加
    required this.userName,
    required this.postedAt,
    this.avatarUrl, // 追加
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
