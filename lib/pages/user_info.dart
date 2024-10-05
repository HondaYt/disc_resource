import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final supabase = Supabase.instance.client;

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data =
          await supabase.from('profiles').select().eq('id', user.id).single();
      setState(() {
        userInfo = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
        elevation: 0,
      ),
      body: userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: ClipOval(
                        child: userInfo?['avatar_url'] != null
                            ? Image.network(
                                userInfo!['avatar_url'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                color: Colors.blue.shade200,
                                child: const Icon(Icons.person,
                                    size: 60, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard('ユーザー名', userInfo?['username'] ?? 'N/A'),
                    _buildInfoCard(
                        'Disc ID', '@${userInfo?['user_id'] ?? 'N/A'}'),
                    _buildInfoCard('メールアドレス', userInfo?['email'] ?? 'N/A'),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('プロフィールを編集'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        context.push('/user_info/edit');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
