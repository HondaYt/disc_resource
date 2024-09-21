import 'package:flutter/material.dart';
import 'liked_music.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_info.dart';
import 'select_music.dart';
import 'user_search.dart';

class DiscMain extends ConsumerStatefulWidget {
  const DiscMain({super.key});
  @override
  ConsumerState<DiscMain> createState() => _DiscMainState();
}

class _DiscMainState extends ConsumerState<DiscMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // 影を削除
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            "assets/logo_w700.png",
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserInfoPage(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/user_dummy.png'),
              child: Container(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildSelectedWidget(),
          ),
          NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0, // 影を削除
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: 'Liked',
              ),
              NavigationDestination(
                // New search icon added
                icon: Icon(Icons.search),
                label: 'User Search',
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return const SelectMusic();
      case 1:
        return const LikedMusic();
      case 2:
        return const UserSearch();
      default:
        return const SizedBox.shrink();
    }
  }
}
