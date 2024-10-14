import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/user_search_notifier.dart';

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, List<Map<String, dynamic>>>(
        (ref) => UserSearchNotifier(ref));
