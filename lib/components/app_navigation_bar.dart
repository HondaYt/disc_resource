import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_info_provider.dart';

class AppNavigationBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
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
                child: userInfo?['avatar_url'] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image:
                            '${userInfo!['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fadeInDuration: const Duration(milliseconds: 20),
                        fadeOutDuration: const Duration(milliseconds: 20),
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/placeholder.png'),
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
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
