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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,user_id.ilike.%$query%')
          .limit(20);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      Logger().e('検索エラー: $error');
      // エラーメッセージをユーザーに表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('検索中にエラーが発生しました。もう一度お試しください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TextField以外の場所をタップした時にフォーカスを外す
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              onChanged: _performSearch,
              placeholder: 'ユーザーを検索',
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('検索結果がありません'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['avatar_url'] != null
                              ? NetworkImage(user['avatar_url'])
                              : null,
                          child: user['avatar_url'] == null
                              ? Text(user['username'][0].toUpperCase())
                              : null,
                        ),
                        title: Text(user['username'] ?? ''),
                        subtitle: Text('@${user['user_id'] ?? ''}'),
                        trailing: ElevatedButton(
                          child: const Text('フォロー'),
                          onPressed: () {
                            // フォロー機能を実装
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
