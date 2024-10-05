import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';

final supabase = Supabase.instance.client;

class EditUserInfoPage extends StatefulWidget {
  const EditUserInfoPage({super.key});

  @override
  State<EditUserInfoPage> createState() => EditUserInfoPageState();
}

class EditUserInfoPageState extends State<EditUserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _userIdController;
  File? _avatarFile;
  bool _isUserIdTaken = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _userIdController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase.from('profiles').select().eq('id', user.id).single();
      setState(() {
        _userNameController.text = response['username'] ?? '';
        _userIdController.text = response['user_id'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
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
        setState(() {
          _avatarFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (_avatarFile == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fileExt = _avatarFile!.path.split('.').last;
    final fileName = '${user.id}/avatar.$fileExt';

    try {
      await supabase.storage.from('avatars').upload(
            fileName,
            _avatarFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase.from('profiles').upsert({
        'id': user.id,
        'avatar_url': avatarUrl,
      });
    } catch (error) {
      if (!mounted) return;
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          await _uploadAvatar();
          await supabase.from('profiles').upsert({
            'id': user.id,
            'username': _userNameController.text,
            'user_id': _userIdController.text,
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィールが更新されました')),
          );
          Navigator.of(context).pop();
        } catch (error) {
          if (!mounted) return;
          Logger().e('プロフィールの更新に失敗しました: $error');
          if (error is PostgrestException && error.code == '23505') {
            setState(() {
              _isUserIdTaken = true;
            });
            _formKey.currentState!.validate();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('プロフィールの更新に失敗しました: $error')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール編集')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: ClipOval(
                  child: _avatarFile != null
                      ? Image.file(
                          _avatarFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo, size: 50),
                        ),
                ),
              ),
            ),
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'User Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'User Nameを入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'Disc ID'),
              onChanged: (value) {
                setState(() {
                  _isUserIdTaken = false;
                });
                // フォームの状態をリセット
                _formKey.currentState?.validate();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ユーザーネームを入力してください';
                }
                if (value.length < 3) {
                  return 'ユーザーネームは3文字以上である必要があります';
                }
                // 英数字、アンダースコア、ハイフン、ドットのみを許可する正規表現
                final validCharacters = RegExp(r'^[a-zA-Z0-9_\-\.]+$');
                if (!validCharacters.hasMatch(value)) {
                  return 'ユーザーネームは英数字、アンダースコア、ハイフン、ドットのみ使用できます';
                }
                if (_isUserIdTaken) {
                  return 'このユーザーIDは既に使用されています';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('保存して閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
}
