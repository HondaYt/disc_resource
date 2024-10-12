import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/user_info_edit_controller.dart';
import '../services/avatar_service.dart';

final supabase = Supabase.instance.client;

class UserInfoEditPage extends StatefulWidget {
  const UserInfoEditPage({super.key});

  @override
  State<UserInfoEditPage> createState() => UserInfoEditPageState();
}

class UserInfoEditPageState extends State<UserInfoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late UserInfoEditController _controller;
  late AvatarService _avatarService;

  @override
  void initState() {
    super.initState();
    _controller = UserInfoEditController();
    _avatarService = AvatarService();
    _controller.loadUserProfile();
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
                onTap: () async {
                  final file = await _avatarService.pickImage();
                  if (file != null) {
                    setState(() {
                      _controller.avatarFile = file;
                    });
                  }
                },
                child: ClipOval(
                  child: _controller.avatarFile != null
                      ? Image.file(
                          _controller.avatarFile!,
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
              controller: _controller.userNameController,
              decoration: const InputDecoration(labelText: 'User Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'User Nameを入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _controller.userIdController,
              decoration: const InputDecoration(labelText: 'Disc ID'),
              onChanged: (value) {
                setState(() {
                  _controller.isUserIdTaken = false;
                });
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
                if (_controller.isUserIdTaken) {
                  return 'このユーザーIDは既に使用されています';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_controller.avatarFile != null) {
                    await _avatarService.uploadAvatar(
                        _controller.avatarFile!, context);
                  }
                  await _controller.updateProfile(context);
                }
              },
              child: const Text('保存して閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
