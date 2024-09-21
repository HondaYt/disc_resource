import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscMain extends StatelessWidget {
  const DiscMain({super.key, required this.child});
  final Widget child;

  static final List<(String, IconData, String)> _navItems = [
    ('/select_music', Icons.home, 'Select Music'),
    ('/liked', Icons.favorite, 'Liked'),
    ('/user_search', Icons.search, 'User Search'),
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset("assets/logo_w700.png"),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => GoRouter.of(context).push('/user_info'),
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/user_dummy.png'),
              child: Container(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.$2),
                  label: item.$3,
                ))
            .toList(),
        selectedIndex: _calculateSelectedIndex(location),
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    final index = _navItems.indexWhere((item) => item.$1 == location);
    return index < 0 ? 0 : index;
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(_navItems[index].$1);
  }
}
