import 'package:flutter/material.dart';

class LikedMusic extends StatelessWidget {
  final List<Map<String, dynamic>> likedSongs;

  const LikedMusic({super.key, required this.likedSongs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Music'),
      ),
      body: ListView.builder(
        itemCount: likedSongs.length,
        itemBuilder: (context, index) {
          final song = likedSongs[index];
          return ListTile(
            title: Text(song['attributes']['name']),
            subtitle: Text(song['attributes']['artistName']),
          );
        },
      ),
    );
  }
}
