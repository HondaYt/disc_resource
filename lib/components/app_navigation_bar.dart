import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static final List<(String, IconData, String)> _navItems = [
    ('/', Icons.home, 'フィード'),
    ('/liked', Icons.favorite, 'お気に入り'),
    ('/user_search', Icons.search, 'ユーザー検索'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          navigationShell.currentIndex == 0
              ? ''
              : _navItems[navigationShell.currentIndex].$3,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset("assets/logo_w700.png"),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              context.push('/user_info');
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipOval(
                child: Image.asset('assets/user_dummy.png'),
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomAppBar(
            color: Colors.white10,
            height: 49,
            notchMargin: 8.0,
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _navItems
                  .asMap()
                  .entries
                  .map((entry) => IconButton(
                        icon: Icon(entry.value.$2),
                        onPressed: () => navigationShell.goBranch(
                          entry.key,
                          initialLocation:
                              entry.key == navigationShell.currentIndex,
                        ),
                        color: navigationShell.currentIndex == entry.key
                            ? Colors.white
                            : Colors.white54,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}