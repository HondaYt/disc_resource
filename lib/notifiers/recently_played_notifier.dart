import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recently_played_item.dart';

class RecentlyPlayedNotifier extends StateNotifier<List<RecentlyPlayedItem>> {
  RecentlyPlayedNotifier() : super([]);

  void setRecentlyPlayed(List<RecentlyPlayedItem> recentlyPlayed) {
    state = recentlyPlayed;
  }
}
