import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class UserInfoEditController {
  final supabase = Supabase.instance.client;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  File? avatarFile;
  bool isUserIdTaken = false;

  Future<void> loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase.from('profiles').select().eq('id', user.id).single();
      userNameController.text = response['username'] ?? '';
      userIdController.text = response['user_id'] ?? '';
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'username': userNameController.text,
          'user_id': userIdController.text,
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールが更新されました')),
        );
        Navigator.of(context).pop();
      } catch (error) {
        if (!context.mounted) return;
        Logger().e('プロフィールの更新に失敗しました: $error');
        if (error is PostgrestException && error.code == '23505') {
          isUserIdTaken = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('プロフィールの更新に失敗しました: $error')),
          );
        }
      }
    }
  }

  void dispose() {
    userNameController.dispose();
    userIdController.dispose();
  }
}
