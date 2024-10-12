import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/follow_list_notifier.dart';

final followersListProvider =
    StateNotifierProvider<FollowListNotifier, List<Map<String, dynamic>>>(
  (ref) => FollowListNotifier(ref)..fetchFollowList(true),
);

final followingListProvider =
    StateNotifierProvider<FollowListNotifier, List<Map<String, dynamic>>>(
  (ref) => FollowListNotifier(ref)..fetchFollowList(false),
);
