import 'package:flutter/material.dart';
import 'dart:async';
import 'package:music_kit/music_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'swiper_test.dart';
import 'music_kit_test_old.dart';

void main() {
  runApp(const MusicKitTest());
}

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
  String _selectedSong = ''; // Added this line

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
    final url = 'https://api.music.apple.com/v1/me/recent/played/tracks';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_developerToken',
        'Music-User-Token': _userToken,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _recentlyPlayed = json.decode(response.body)['data'];
      });
      // Logger().d(response.body);
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
      print(song);
      print('Error playing song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                      builder: (context) => SwiperTest(),
                    ),
                  );
                }),
            // IconButton(
            //     icon: const Icon(Icons.music_note),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => MusicKitTestOld(),
            //         ),
            //       );
            //     }),
          ],
        ),
        body: Column(
          children: [
            // if (_selectedSong.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Text('Selected Song ID: $_selectedSong'),
            //   ),
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
                              subtitle: Text(song['attributes']['artistName']),
                              onTap: () {
                                setState(() {
                                  _selectedSong =
                                      song.toString(); // Added this line
                                });
                                playSong(song); // Changed argument type
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
    );
  }
}
