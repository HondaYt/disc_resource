import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

class SwiperControllerNotifier extends StateNotifier<AppinioSwiperController> {
  SwiperControllerNotifier() : super(AppinioSwiperController());

  void swipeRight() {
    state.swipeRight();
  }

  void swipeLeft() {
    state.swipeLeft();
  }

  void unswipe() {
    state.unswipe();
  }
}

final swiperControllerProvider =
    StateNotifierProvider<SwiperControllerNotifier, AppinioSwiperController>(
  (ref) => SwiperControllerNotifier(),
);
