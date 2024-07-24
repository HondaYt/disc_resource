import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/liked_songs_provider.dart';

class LikedMusic extends StatelessWidget {
  const LikedMusic({super.key});

  @override
  Widget build(BuildContext context) {
    final likedSongs = Provider.of<LikedSongsProvider>(context).likedSongs;

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
