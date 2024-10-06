import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

String? getCurrentUserId() {
  return supabase.auth.currentUser?.id;
}

Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds) async {
  if (userIds.isEmpty) return [];
  return await supabase.from('profiles').select('*').inFilter('id', userIds);
}

Future<void> throwIfNotAuthenticated() async {
  if (getCurrentUserId() == null) {
    throw Exception('ユーザーが認証されていません');
  }
}
