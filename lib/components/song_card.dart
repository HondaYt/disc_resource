import 'package:flutter/material.dart';
import 'package:music_kit/music_kit.dart' as music_kit;
import 'package:interactive_slider/interactive_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_player_provider.dart' as local_provider;
import '../providers/music_control_provider.dart' as control_provider;
import '../providers/swiper_controller_provider.dart';

class SongCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> song;
  final bool isActive;

  const SongCard({
    super.key,
    required this.song,
    required this.isActive,
  });

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends ConsumerState<SongCard> {
  @override
  void initState() {
    super.initState();
  }

  void _updateSliderValue(Duration? currentPlaybackTime) {
    if (currentPlaybackTime != null) {
      final newValue = currentPlaybackTime.inMilliseconds.toDouble();
      if (!newValue.isNaN) {
        ref
            .read(control_provider.musicControlProvider.notifier)
            .sliderController
            .value = newValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayerState = ref.watch(local_provider.musicPlayerProvider);
    final musicControl =
        ref.read(control_provider.musicControlProvider.notifier);
    final swiperController = ref.read(swiperControllerProvider.notifier);

    // ref.listenをbuildメソッド内で使用
    ref.listen<local_provider.MusicPlayerState>(
        local_provider.musicPlayerProvider, (previous, next) {
      if (widget.isActive) {
        _updateSliderValue(next.currentPlaybackTime);
      }
    });

    double cardBorderRadius = 40.0;
    double cardPadding = 8;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 16,
                backgroundImage: const AssetImage('assets/user2_dummy.png'),
                child: Container(),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HondaYt', style: TextStyle(fontSize: 16.0, height: 1)),
                Text('2時間前',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white60,
                    )),
              ],
            ),
          ],
        ),
        SmoothCard(
          color: Colors.grey[900],
          smoothness: 0.6,
          elevation: 2.0,
          shadowColor: Colors.black45,
          side: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SmoothClipRRect(
                  smoothness: 0.6,
                  borderRadius:
                      BorderRadius.circular(cardBorderRadius - cardPadding),
                  child: SizedBox(
                    width: double.infinity,
                    height: 318,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.song['attributes']['artwork']['url']
                              .replaceAll('{w}', '2')
                              .replaceAll('{h}', '2'),
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          widget.song['attributes']['artwork']['url']
                              .replaceAll('{w}', '159')
                              .replaceAll('{h}', '159'),
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          widget.song['attributes']['artwork']['url']
                              .replaceAll('{w}', '318')
                              .replaceAll('{h}', '318'),
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          widget.song['attributes']['artwork']['url']
                              .replaceAll('{w}', '636')
                              .replaceAll('{h}', '636'),
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          widget.song['attributes']['artwork']['url']
                              .replaceAll('{w}', '1272')
                              .replaceAll('{h}', '1272'),
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                  color: Colors.black87,
                                  child: Text(
                                    musicPlayerState.musicPlayerStatus
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(
                                  color: Colors.black87,
                                  child: Text(
                                    'was${musicPlayerState.wasMusicPlayerStatusBeforeSeek.toString()}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(
                                  color: Colors.black87,
                                  child: Text(
                                    'Duration:${musicPlayerState.songDuration.inSeconds.toString()}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(
                                  color: Colors.black87,
                                  child: Text(
                                    'Remaining:${musicPlayerState.remainingTime.inSeconds.toString()}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(
                                  color: Colors.black87,
                                  child: Text(
                                    'Current:${musicPlayerState.currentPlaybackTime.inSeconds.toString()}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: widget.isActive
                      ? ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.black87,
                                Colors.black,
                                Colors.black,
                                Colors.black87,
                                Colors.transparent
                              ],
                              stops: [0.0, 0.08, 0.12, 0.88, 0.92, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextScroll(
                                  paddingLeft: 24.0,
                                  widget.song['attributes']['name'],
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  intervalSpaces: 8,
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(30, 0)),
                                  delayBefore: const Duration(seconds: 3),
                                  pauseBetween: const Duration(seconds: 3),
                                ),
                                TextScroll(
                                  paddingLeft: 24.0,
                                  widget.song['attributes']['artistName'],
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.white60,
                                  ),
                                  intervalSpaces: 8,
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(30, 0)),
                                  delayBefore: const Duration(seconds: 3),
                                  pauseBetween: const Duration(seconds: 3),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.song['attributes']['name'],
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  widget.song['attributes']['artistName'],
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16.0),
                InteractiveSlider(
                  padding: const EdgeInsets.all(0),
                  unfocusedHeight: 8,
                  focusedHeight: 16,
                  unfocusedMargin: const EdgeInsets.symmetric(horizontal: 24),
                  focusedMargin: const EdgeInsets.symmetric(horizontal: 10),
                  controller: widget.isActive
                      ? ref
                          .read(control_provider.musicControlProvider.notifier)
                          .sliderController
                      : null,
                  min: 0,
                  max: musicPlayerState.songDuration.inMilliseconds.toDouble(),
                  onChangeStart: (value) => musicControl.seekStart(),
                  onChangeEnd: (value) => musicControl
                      .seekEnd(Duration(milliseconds: value.toInt())),
                  iconPosition: IconPosition.below,
                  startIcon: Text(
                    widget.isActive
                        ? '${musicPlayerState.currentPlaybackTime.inMinutes}:${(musicPlayerState.currentPlaybackTime.inSeconds % 60).toString().padLeft(2, '0')}'
                        : '0:00',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                      color: Colors.white70,
                    ),
                  ),
                  endIcon: Text(
                    widget.isActive
                        ? '-${musicPlayerState.remainingTime.inMinutes}:${(musicPlayerState.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}'
                        : '0:00',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      child: const Icon(CupertinoIcons.backward_fill),
                      onPressed: () {
                        if (ref
                                    .read(local_provider.musicPlayerProvider)
                                    .currentSongIndex ==
                                0 ||
                            musicPlayerState.currentPlaybackTime.inSeconds >
                                3) {
                          musicControl.seekTo(const Duration(seconds: 0));
                        } else {
                          swiperController.unswipe();
                        }
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                          size: 50,
                          musicPlayerState.musicPlayerStatus ==
                                  music_kit.MusicPlayerPlaybackStatus.playing
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill),
                      onPressed: () {
                        if (musicPlayerState.musicPlayerStatus ==
                            music_kit.MusicPlayerPlaybackStatus.playing) {
                          musicControl.pauseSong();
                        } else {
                          musicControl.resumeSong();
                        }
                      },
                    ),
                    CupertinoButton(
                      child: const Icon(CupertinoIcons.forward_fill),
                      onPressed: () {
                        swiperController.swipeLeft();
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
