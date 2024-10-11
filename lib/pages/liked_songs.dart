import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/liked_songs_provider.dart';

class LikedSongsPage extends ConsumerStatefulWidget {
  const LikedSongsPage({super.key});

  @override
  LikedSongsPageState createState() => LikedSongsPageState(); // アンダースコアを削除
}

class LikedSongsPageState extends ConsumerState<LikedSongsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLikedSongs();
    });
  }

  Future<void> _fetchLikedSongs() async {
    try {
      await ref.read(likedSongsProvider.notifier).fetchLikedSongs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('いいねした曲の取得に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final likedSongs = ref.watch(likedSongsProvider);

    return RefreshIndicator(
      onRefresh: _fetchLikedSongs,
      child: likedSongs.isEmpty
          ? ListView(
              children: const [
                Center(
                  child: Text('まだ何も追加されていません'),
                ),
              ],
            )
          : ListView.builder(
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final song = likedSongs[index];
                final attributes = song['attributes'] as Map<String, dynamic>;
                final artworkUrl = attributes['artwork']['url'] as String;
                return ListTile(
                  leading: Image.network(
                    artworkUrl.replaceAll('{w}', '80').replaceAll('{h}', '80'),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.music_note, size: 60);
                    },
                  ),
                  title: Text(attributes['name'] ?? '不明な曲名'),
                  subtitle: Text(attributes['artistName'] ?? '不明なアーティスト'),
                  onTap: () {},
                );
              },
            ),
    );
  }
}
