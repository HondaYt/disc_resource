import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/follow_list_provider.dart';

class FollowListPage extends ConsumerStatefulWidget {
  final String title;
  final StateNotifierProvider<FollowListNotifier, List<Map<String, dynamic>>>
      provider;

  const FollowListPage({
    super.key,
    required this.title,
    required this.provider,
  });

  @override
  ConsumerState<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends ConsumerState<FollowListPage> {
  @override
  Widget build(BuildContext context) {
    final users = ref.watch(widget.provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('まだ誰もいないようです。'),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(widget.provider.notifier).fetchFollowList(
                          widget.provider == followersListProvider);
                    },
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserListTile(user);
              },
            ),
    );
  }

  Widget _buildUserListTile(Map<String, dynamic> user) {
    return ListTile(
      leading: _buildUserAvatar(user),
      title: Text(user['username'] ?? ''),
      subtitle: Text('@${user['user_id'] ?? ''}'),
      trailing: _buildFollowButton(user),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    return ClipOval(
      child: user['avatar_url'] != null
          ? Image.network(
              user['avatar_url'],
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            )
          : Container(
              width: 40,
              height: 40,
              color: Colors.grey,
              child: Center(
                child: Text(
                  user['username'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
    );
  }

  Widget _buildFollowButton(Map<String, dynamic> user) {
    final isFollowing = user['is_following'] ?? false;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.black : Colors.white,
        foregroundColor: isFollowing ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isFollowing
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Text(isFollowing ? 'フォロー中' : 'フォロー'),
      onPressed: () async {
        await ref.read(widget.provider.notifier).toggleFollow(user['id']);
      },
    );
  }
}
