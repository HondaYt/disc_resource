class RecentlyPlayedItem {
  final Map<String, dynamic> song;
  final Map<String, dynamic> post; // 追加
  final String userName;
  final DateTime postedAt;
  final String? avatarUrl; // 追加

  RecentlyPlayedItem({
    required this.song,
    required this.post, // 追加
    required this.userName,
    required this.postedAt,
    this.avatarUrl, // 追加
  });
}
