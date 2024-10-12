import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../notifiers/user_info_notifier.dart';

// final supabase = Supabase.instance.client;

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, Map<String, dynamic>?>(
        (ref) => UserInfoNotifier());
