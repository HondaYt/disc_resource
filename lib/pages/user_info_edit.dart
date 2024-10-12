import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/user_info_edit_controller.dart';
import '../services/avatar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_info_provider.dart';
import '../components/smooth_button.dart';

final supabase = Supabase.instance.client;

class UserInfoEditPage extends ConsumerStatefulWidget {
  const UserInfoEditPage({super.key});

  @override
  ConsumerState<UserInfoEditPage> createState() => UserInfoEditPageState();
}

class UserInfoEditPageState extends ConsumerState<UserInfoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late UserInfoEditController _controller;
  late AvatarService _avatarService;

  @override
  void initState() {
    super.initState();
    _controller = UserInfoEditController(ref);
    _avatarService = AvatarService();
    _controller.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 64),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _controller.userNameController,
                    labelText: 'ユーザー名',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ユーザー名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _controller.userIdController,
                    labelText: 'ユーザーID',
                    prefixIcon: Icons.alternate_email,
                    onChanged: (value) {
                      setState(() {
                        _controller.isUserIdTaken = false;
                      });
                      _formKey.currentState?.validate();
                    },
                    validator: _validateUserId,
                  ),
                  const SizedBox(height: 32),
                  // _buildSaveButton(),
                  SmoothButton(
                    text: '保存して閉じる',
                    onPressed: _saveProfile,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // アバター選択部分のウィジェット
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: _getAvatarImage(),
              child: _showAddPhotoIcon()
                  ? const Icon(Icons.add_a_photo, size: 40)
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // テキストフィールドを生成するヘルパーメソッド
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onChanged: onChanged,
    );
  }

  // ユーザーIDのバリデーション
  String? _validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'ユーザーIDを入力してください';
    }
    if (value.length < 3) {
      return 'ユーザーIDは3文字以上である必要があります';
    }
    final validCharacters = RegExp(r'^[a-zA-Z0-9_\-\.]+$');
    if (!validCharacters.hasMatch(value)) {
      return 'ユーザーIDは英数字、アンダースコア、ハイフン、ドットのみ使用できます';
    }
    if (_controller.isUserIdTaken) {
      return 'このユーザーIDは既に使用されています';
    }
    return null;
  }

  // アバター画像を取得するヘルパーメソッド
  ImageProvider<Object>? _getAvatarImage() {
    final userInfo = ref.watch(userInfoProvider);
    if (_controller.avatarFile != null) {
      return FileImage(_controller.avatarFile!);
    } else if (userInfo != null && userInfo['avatar_url'] != null) {
      return NetworkImage(
          '${userInfo['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}');
    }
    return null;
  }

  // アバター追加アイコンを表示するかどうかを判断するヘルパーメソッド
  bool _showAddPhotoIcon() {
    final userInfo = ref.watch(userInfoProvider);
    return _controller.avatarFile == null &&
        (userInfo == null || userInfo['avatar_url'] == null);
  }

  Future<void> _pickImage() async {
    final file = await _avatarService.pickImage();
    if (file != null) {
      setState(() {
        _controller.avatarFile = file;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_controller.avatarFile != null) {
        await _avatarService.uploadAvatar(
          _controller.avatarFile!,
          context,
          ref,
        );
      }
      if (!mounted) return;
      await _controller.updateProfile(context);
    }
  }

  // 保存ボタンを生成するメソッド

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
