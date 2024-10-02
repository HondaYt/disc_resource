import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/liked_songs_provider.dart';

class LikedMusicPage extends ConsumerWidget {
  const LikedMusicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(likedSongsProvider);

    return ListView.builder(
      itemCount: likedSongs.length,
      itemBuilder: (context, index) {
        final song = likedSongs[index];
        return ListTile(
          leading: Image.network(
            song['attributes']['artwork']['url']
                .replaceAll('{w}', '636')
                .replaceAll('{h}', '636'),
            fit: BoxFit.cover,
          ),
          title: Text(song['attributes']['name']),
          subtitle: Text(song['attributes']['artistName']),
        );
      },
    );
  }
}
