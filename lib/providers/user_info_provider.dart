import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final supabase = Supabase.instance.client;

class UserInfoNotifier extends StateNotifier<Map<String, dynamic>?> {
  UserInfoNotifier() : super(null) {
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data =
            await supabase.from('profiles').select().eq('id', user.id).single();
        state = data;
      } else {
        state = null;
      }
    } catch (error) {
      Logger().e('ユーザー情報の取得エラー: $error');
      state = null;
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> newInfo) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update(newInfo).eq('id', user.id);
        await fetchUserInfo();
      } else {
        throw Exception('ユーザーが認証されていません');
      }
    } catch (error) {
      Logger().e('ユーザー情報の更新エラー: $error');
    }
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, Map<String, dynamic>?>(
        (ref) => UserInfoNotifier());
