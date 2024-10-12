import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import '../providers/user_info_provider.dart';

class UserInfoEditController {
  final WidgetRef ref;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  File? avatarFile;
  bool isUserIdTaken = false;

  UserInfoEditController(this.ref);

  void loadUserProfile() {
    final userInfo = ref.read(userInfoProvider);
    if (userInfo != null) {
      userNameController.text = userInfo['username'] ?? '';
      userIdController.text = userInfo['user_id'] ?? '';
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    try {
      await ref.read(userInfoProvider.notifier).updateUserInfo({
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
      // エラーハンドリングの詳細は省略していますが、必要に応じて追加してください
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィールの更新に失敗しました: $error')),
      );
    }
  }

  void dispose() {
    userNameController.dispose();
    userIdController.dispose();
  }
}
