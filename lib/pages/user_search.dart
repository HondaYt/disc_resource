import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_search_provider.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  static const String _searchPlaceholder = 'ユーザーを検索';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(userSearchProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _buildSearchResults(searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        style: const TextStyle(color: Colors.white),
        controller: _searchController,
        onSubmitted: (query) =>
            ref.read(userSearchProvider.notifier).searchUsers(query),
        onChanged: (query) =>
            ref.read(userSearchProvider.notifier).searchUsers(query),
        placeholder: _searchPlaceholder,
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> searchResults) {
    return searchResults.isEmpty
        ? const Center(child: Text('検索結果がありません'))
        : ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) =>
                _buildUserListTile(searchResults[index]),
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
        await ref.read(userSearchProvider.notifier).toggleFollow(user['id']);
      },
    );
  }
}
