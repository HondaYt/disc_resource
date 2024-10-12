import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../notifiers/user_posts_notifier.dart';

// final supabase = Supabase.instance.client;

final userPostsProvider =
    StateNotifierProvider<UserPostsNotifier, List<Map<String, dynamic>>>(
        (ref) => UserPostsNotifier());
