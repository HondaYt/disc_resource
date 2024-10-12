import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_info_provider.dart';
import '../providers/follow_provider.dart';
import '../providers/user_posts_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../notifiers/user_posts_notifier.dart';
import '../components/smooth_button.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  ConsumerState<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userPostsProvider.notifier).fetchUserPosts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider);
    final followCounts = ref.watch(followCountsProvider);
    final userPosts = ref.watch(userPostsProvider);
    final userPostsNotifier = ref.watch(userPostsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ClipOval(
                      child: userInfo['avatar_url'] != null
                          ? Image.network(
                              '${userInfo['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}',
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
                    userInfo['username'] ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    textAlign: TextAlign.center,
                    '@${userInfo['user_id'] ?? 'N/A'}',
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  followCounts.when(
                    data: (counts) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/user_info/followers'),
                          child:
                              _buildFollowCount('フォロワー', counts['followers']!),
                        ),
                        const SizedBox(width: 32),
                        GestureDetector(
                          onTap: () => context.push('/user_info/following'),
                          child:
                              _buildFollowCount('フォロー中', counts['following']!),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('エラーが発生しました'),
                  ),
                  const SizedBox(height: 16),
                  // _buildInfoCard('メールアドレス', userInfo['email'] ?? 'N/A'),
                  // const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SmoothButton(
                      text: 'プロフィールを編集',
                      onPressed: () {
                        context.push('/user_info/edit');
                      },
                      isOutlined: true,
                    ),
                    // child: ElevatedButton.icon(
                    //   icon: const Icon(Icons.edit),
                    //   label: const Text('プロフィールを編集'),
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 32, vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30),
                    //     ),
                    //   ),
                    //   onPressed: () {
                    //     context.push('/user_info/edit');
                    //   },
                    // ),
                  ),
                  // const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '最近の投稿',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUserPosts(userPosts, userPostsNotifier),
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

  Widget _buildUserPosts(
      List<Map<String, dynamic>> posts, UserPostsNotifier notifier) {
    if (posts.isEmpty) {
      return const Center(child: Text('まだ投稿がありません'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length + (notifier.hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              child: const Text('さらに読み込む'),
              onPressed: () => notifier.fetchUserPosts(),
            ),
          );
        }

        final post = posts[index];
        final song = post['songs']['details'];
        final attributes = song['attributes'];

        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _deletePost(post['id'].toString()), // 文字列に変換
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '削除',
              ),
            ],
          ),
          child: ListTile(
            leading: Image.network(
              attributes['artwork']['url']
                  .replaceAll('{w}', '60')
                  .replaceAll('{h}', '60'),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(attributes['name']),
            subtitle: Text(attributes['artistName']),
            trailing: Text(
              _formatDate(DateTime.parse(post['created_at'])),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _deletePost(String postId) async {
    // String型に変更
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('投稿の削除'),
          content: const Text('この投稿を削除してもよろしいですか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(userPostsProvider.notifier).deletePost(postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('投稿を削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('投稿の削除に失敗しました: $e')),
          );
        }
      }
    }
  }
}
