import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final supabase = Supabase.instance.client;

  static const int _searchLimit = 20;
  static const String _searchPlaceholder = 'ユーザーを検索';

  Future<void> _performSearch(String query) async {
    setState(() {});

    try {
      final currentUserId = supabase.auth.currentUser!.id;
      final searchResults = await _fetchSearchResults(query, currentUserId);
      final followedUserIds = await _fetchFollowedUserIds(currentUserId);

      setState(() {
        _searchResults = _processSearchResults(searchResults, followedUserIds);
      });
    } catch (error) {
      _handleSearchError(error);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(
      String query, String currentUserId) async {
    return await supabase
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,user_id.ilike.%$query%')
        .neq('id', currentUserId)
        .limit(_searchLimit);
  }

  Future<Set<String>> _fetchFollowedUserIds(String currentUserId) async {
    final followsResponse = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId);
    return Set<String>.from(
        followsResponse.map((follow) => follow['followed_id'] as String));
  }

  List<Map<String, dynamic>> _processSearchResults(
      List<Map<String, dynamic>> searchResults, Set<String> followedUserIds) {
    return searchResults.map((profile) {
      return {
        ...profile,
        'is_following': followedUserIds.contains(profile['id']),
      };
    }).toList();
  }

  void _handleSearchError(dynamic error) {
    Logger().e('検索エラー: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('検索中にエラーが発生しました。もう一度お試しください。')),
    );
    setState(() {});
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final currentUserId = supabase.auth.currentUser!.id;
    try {
      await _performFollowAction(currentUserId, targetUserId);
      await _performSearch(_searchController.text);
    } catch (error) {
      _handleFollowError(error);
    }
  }

  Future<void> _performFollowAction(
      String currentUserId, String targetUserId) async {
    final existingFollow =
        await _checkExistingFollow(currentUserId, targetUserId);
    if (existingFollow == null) {
      await _followUser(currentUserId, targetUserId);
    } else {
      await _unfollowUser(currentUserId, targetUserId);
    }
  }

  Future<Map<String, dynamic>?> _checkExistingFollow(
      String currentUserId, String targetUserId) async {
    return await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('followed_id', targetUserId)
        .maybeSingle();
  }

  Future<void> _followUser(String currentUserId, String targetUserId) async {
    await supabase.from('follows').insert({
      'follower_id': currentUserId,
      'followed_id': targetUserId,
    });
  }

  Future<void> _unfollowUser(String currentUserId, String targetUserId) async {
    await supabase
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('followed_id', targetUserId);
  }

  void _handleFollowError(dynamic error) {
    Logger().e('フォロー/アンフォローエラー: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('操作中にエラーが発生しました。もう一度お試しください。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _buildSearchResults(),
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
        onSubmitted: _performSearch,
        onChanged: _performSearch,
        placeholder: _searchPlaceholder,
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? const Center(child: Text('検索結果がありません'))
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) =>
                _buildUserListTile(_searchResults[index]),
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
        await _toggleFollow(user['id']);
        setState(() {});
      },
    );
  }
}
