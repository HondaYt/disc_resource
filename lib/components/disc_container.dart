import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscContainer extends StatelessWidget {
  const DiscContainer({super.key, required this.child});
  final Widget child;

  static final List<(String, dynamic, String)> _navItems = [
    ('/', const Icon(Icons.home), 'Select Music'),
    ('/liked', const Icon(Icons.favorite), 'Liked'),
    ('/user_search', const Icon(Icons.search), 'User Search'),
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
      body: child,
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
                  .map((item) => IconButton(
                        icon: item.$2,
                        onPressed: () => GoRouter.of(context).go(item.$1),
                        color:
                            location == item.$1 ? Colors.white : Colors.white54,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
