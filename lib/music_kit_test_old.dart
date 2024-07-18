import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'swiper_test.dart';

class MusicKitTest extends StatefulWidget {
  const MusicKitTest({super.key});

  @override
  State<MusicKitTest> createState() => _MusicKitTestState();
}

class _MusicKitTestState extends State<MusicKitTest> {
  final _musicKitPlugin = MusicKit();
  String _developerToken = '';
  String _userToken = '';
  List<dynamic> _recentlyPlayed = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final developerToken = await _musicKitPlugin.requestDeveloperToken();
    final userToken = await _musicKitPlugin.requestUserToken(developerToken);

    if (!mounted) return;

    setState(() {
      _developerToken = developerToken;
      _userToken = userToken;
    });

    fetchRecentlyPlayed();
  }

  Future<void> fetchRecentlyPlayed() async {
    const url = 'https://api.music.apple.com/v1/me/recent/played/tracks';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_developerToken',
        'Music-User-Token': _userToken,
      },
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        _recentlyPlayed = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load recently played');
    }
  }

  Future<void> playSong(Map<String, dynamic> song) async {
    // Changed parameter type
    try {
      await _musicKitPlugin.setQueue('songs', item: song);
      await _musicKitPlugin.play();
    } catch (e) {
      // Added error handling
      Logger().d('Error playing song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Recently Played Songs'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SwiperTest(),
                      ),
                    );
                  }),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: _recentlyPlayed.isEmpty
                      ? const CircularProgressIndicator()
                      : RefreshIndicator(
                          onRefresh: fetchRecentlyPlayed,
                          child: ListView.builder(
                            itemCount: _recentlyPlayed.length,
                            itemBuilder: (context, index) {
                              final song = _recentlyPlayed[index];
                              return ListTile(
                                leading: Image.network(
                                  song['attributes']['artwork']['url']
                                      .replaceAll('{w}', '100')
                                      .replaceAll('{h}', '100'),
                                ),
                                title: Text(song['attributes']['name']),
                                subtitle:
                                    Text(song['attributes']['artistName']),
                                onTap: () {
                                  playSong(song);
                                },
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
