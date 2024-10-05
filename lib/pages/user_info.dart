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
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchFollowCounts();
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

  Future<void> _fetchFollowCounts() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final followersData = await supabase
          .from('follows')
          .select()
          .eq('followed_id', user.id)
          .count();

      final followingData = await supabase
          .from('follows')
          .select()
          .eq('follower_id', user.id)
          .count();

      setState(() {
        followersCount = followersData.count;
        followingCount = followingData.count;
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
                    const SizedBox(height: 44),
                    Text(
                      textAlign: TextAlign.center,
                      userInfo?['username'] ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      textAlign: TextAlign.center,
                      '@${userInfo?['user_id'] ?? 'N/A'}',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    // _buildInfoCard('ユーザー名', userInfo?['username'] ?? 'N/A'),
                    // _buildInfoCard(
                    //     'Disc ID', '@${userInfo?['user_id'] ?? 'N/A'}'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFollowCount('フォロワー', followersCount),
                        const SizedBox(width: 32),
                        _buildFollowCount('フォロー中', followingCount),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard('メールアドレス', userInfo?['email'] ?? 'N/A'),
                    const SizedBox(height: 24),
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
      color: Colors.grey[900]!,
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

  Widget _buildFollowCount(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
