import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  void _performSearch(String query) {
    // ここで実際の検索ロジックを実装します
    setState(() {
      _searchResults = ['ユーザー1', 'ユーザー2', 'ユーザー3'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            onSubmitted: _performSearch,
            placeholder: 'ユーザーを検索',
          ),
          // TextField(
          //   controller: _searchController,
          //   decoration: InputDecoration(
          //     hintText: 'ユーザーを検索',
          //     suffixIcon: IconButton(
          //       icon: const Icon(Icons.search),
          //       onPressed: () => _performSearch(_searchController.text),
          //     ),
          //   ),
          //   onSubmitted: _performSearch,
          // ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_searchResults[index]),
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
    );
  }
}
