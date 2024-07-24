import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/liked_songs_provider.dart';

class LikedMusic extends ConsumerWidget {
  const LikedMusic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(likedSongsProvider);

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
