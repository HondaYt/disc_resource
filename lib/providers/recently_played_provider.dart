import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recently_played_item.dart';
import '../notifiers/recently_played_notifier.dart';

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<RecentlyPlayedItem>>(
        (ref) => RecentlyPlayedNotifier());
