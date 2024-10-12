import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/read_notifier.dart';
import '../models/read_item.dart';

final readProvider =
    StateNotifierProvider<ReadNotifier, Map<String, ReadItem>>((ref) {
  return ReadNotifier();
});
