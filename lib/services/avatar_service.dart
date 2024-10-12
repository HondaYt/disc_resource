import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AvatarService {
  final supabase = Supabase.instance.client;

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像を切り抜く',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '画像を切り抜く',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    }
    return null;
  }

  Future<void> uploadAvatar(File avatarFile, BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fileExt = avatarFile.path.split('.').last;
    final fileName = '${user.id}/avatar.$fileExt';

    try {
      await supabase.storage.from('avatars').upload(
            fileName,
            avatarFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase.from('profiles').upsert({
        'id': user.id,
        'avatar_url': avatarUrl,
      });
    } catch (error) {
      if (!context.mounted) return;
      String errorMessage = 'アバターのアップロードに失敗しました';
      if (error is StorageException) {
        errorMessage += ': ${error.message} (ステータスコード: ${error.statusCode})';
      } else {
        errorMessage += ': $error';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      rethrow;
    }
  }
}
