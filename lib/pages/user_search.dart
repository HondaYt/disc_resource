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
    return CircleAvatar(
      backgroundImage:
          user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
      child: user['avatar_url'] == null
          ? Text(user['username'][0].toUpperCase())
          : null,
    );
  }

  Widget _buildFollowButton(Map<String, dynamic> user) {
    return ElevatedButton(
      child: Text(user['is_following'] ? 'フォロー解除' : 'フォロー'),
      onPressed: () async {
        await ref.read(userSearchProvider.notifier).toggleFollow(user['id']);
      },
    );
  }
}
