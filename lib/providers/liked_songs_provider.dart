import 'package:flutter/material.dart';

class LikedSongsProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _likedSongs = [];

  List<Map<String, dynamic>> get likedSongs => _likedSongs;

  void addSong(Map<String, dynamic> song) {
    _likedSongs.add(song);
    notifyListeners();
  }
}
