import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowListPage extends ConsumerWidget {
  final String title;
  final AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>> provider;

  const FollowListPage(
      {super.key, required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: users.when(
        data: (userList) {
          if (userList.isEmpty) {
            return const Center(child: Text('ユーザーが見つかりません'));
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['avatar_url'] != null
                      ? NetworkImage(user['avatar_url'])
                      : null,
                  child: user['avatar_url'] == null
                      ? Text(
                          (user['username'] as String? ?? '')[0].toUpperCase())
                      : null,
                ),
                title: Text(user['username'] ?? ''),
                subtitle: Text('@${user['user_id'] ?? ''}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }
}
