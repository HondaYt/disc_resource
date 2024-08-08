import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = supabase.auth.currentUser;
      if (user != null) {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール編集')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
