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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/user_info/edit');
            },
          ),
        ],
      ),
      body: userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('ID: ${userInfo?['id'] ?? 'N/A'}',
                  //     style: const TextStyle(fontSize: 20)),
                  Text('User Name: ${userInfo?['username'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text('Email: ${userInfo?['email'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 24)),
                ],
              ),
            ),
    );
  }
}
