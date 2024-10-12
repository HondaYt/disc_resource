import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../notifiers/swiper_controller_notifier.dart';

final swiperControllerProvider =
    StateNotifierProvider<SwiperControllerNotifier, AppinioSwiperController>(
  (ref) => SwiperControllerNotifier(),
);
