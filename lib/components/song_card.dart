import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:text_scroll/text_scroll.dart';

class SongCard extends StatefulWidget {
  final Map<String, dynamic> song;
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final MusicPlayerPlaybackStatus wasMusicPlayerStatusBeforeSeek;
  final Function(Duration) onSeek;
  final Function() onSeekStart;
  final Function(Duration) onSeekEnd;
  final Function() onPause;
  final Function() onResume;
  final AppinioSwiperController swiperController;
  final InteractiveSliderController sliderController;
  final bool isActive;

  const SongCard({
    super.key,
    required this.song,
    required this.currentPlaybackTime,
    required this.songDuration,
    required this.remainingTime,
    required this.musicPlayerStatus,
    required this.wasMusicPlayerStatusBeforeSeek,
    required this.onSeekStart,
    required this.onSeek,
    required this.onSeekEnd,
    required this.onPause,
    required this.onResume,
    required this.swiperController,
    required this.sliderController,
    required this.isActive,
  });

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends State<SongCard> {
  @override
  void initState() {
    super.initState();
    _updateSliderValue();
  }

  @override
  void didUpdateWidget(SongCard oldWidget) {
    if (!widget.isActive) return;
    super.didUpdateWidget(oldWidget);
    if (widget.currentPlaybackTime != oldWidget.currentPlaybackTime) {
      _updateSliderValue();
    }
  }

  void _updateSliderValue() {
    if (!widget.isActive) return;

    final newValue = widget.currentPlaybackTime.inMilliseconds.toDouble();
    if (!newValue.isNaN) {
      widget.sliderController.value = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardBorderRadius = 40.0;
    double cardPadding = 8;
    return SmoothCard(
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
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.grey[600],
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
              controller: widget.isActive ? widget.sliderController : null,
              min: 0,
              max: widget.songDuration.inMilliseconds.toDouble(),
              onChangeStart: (value) => widget.onSeekStart(),
              onChangeEnd: (value) =>
                  widget.onSeekEnd(Duration(milliseconds: value.toInt())),
              iconPosition: IconPosition.below,
              startIcon: Text(
                widget.isActive
                    ? '${widget.currentPlaybackTime.inMinutes}:${(widget.currentPlaybackTime.inSeconds % 60).toString().padLeft(2, '0')}'
                    : '0:00',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
              endIcon: Text(
                widget.isActive
                    ? '-${widget.remainingTime.inMinutes}:${(widget.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}'
                    : '0:00',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton(
                  child: const Icon(CupertinoIcons.backward_fill),
                  onPressed: () {
                    widget.swiperController.unswipe();
                  },
                ),
                CupertinoButton(
                  child: Icon(
                      size: 50,
                      widget.musicPlayerStatus ==
                              MusicPlayerPlaybackStatus.playing
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill),
                  onPressed: () {
                    if (widget.musicPlayerStatus ==
                        MusicPlayerPlaybackStatus.playing) {
                      widget.onPause();
                    } else {
                      widget.onResume();
                    }
                  },
                ),
                CupertinoButton(
                  child: const Icon(CupertinoIcons.forward_fill),
                  onPressed: () {
                    widget.swiperController.swipeLeft();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
