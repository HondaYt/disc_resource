import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_corner/smooth_corner.dart';

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
  });

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends State<SongCard> {
  final _controller = InteractiveSliderController(0.0);

  @override
  void initState() {
    super.initState();
    _updateSliderValue();
  }

  @override
  void didUpdateWidget(SongCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPlaybackTime != oldWidget.currentPlaybackTime) {
      _updateSliderValue();
    }
  }

  void _updateSliderValue() {
    final newValue = widget.currentPlaybackTime.inMilliseconds.toDouble();
    if (!newValue.isNaN) {
      _controller.value = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      smoothness: 0.6,
      elevation: 2.0,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(40.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmoothClipRRect(
              smoothness: 0.6,
              // smoothness: 0,
              borderRadius: BorderRadius.circular(40.0 - 16.0),
              child: SizedBox(
                width: double.infinity,
                // height: 300.0,
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
                                widget.musicPlayerStatus.toString(),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              )),
                          Container(
                              color: Colors.black87,
                              child: Text(
                                'was${widget.wasMusicPlayerStatusBeforeSeek.toString()}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              )),
                          Container(
                              color: Colors.black87,
                              child: Text(
                                'Duration:${widget.songDuration.inSeconds.toString()}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              )),
                          Container(
                              color: Colors.black87,
                              child: Text(
                                'Remaining:${widget.remainingTime.inSeconds.toString()}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              )),
                          Container(
                              color: Colors.black87,
                              child: Text(
                                'Current:${widget.currentPlaybackTime.inSeconds.toString()}',
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
            Text(
              widget.song['attributes']['name'],
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.song['attributes']['artistName'],
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[600],
              ),
            ),
            InteractiveSlider(
              // unfocusedMargin: const EdgeInsets.all(0),
              controller: _controller,
              min: 0,
              max: widget.songDuration.inMilliseconds.toDouble(),
              onChangeStart: (value) => widget.onSeekStart(),
              onChangeEnd: (value) =>
                  widget.onSeekEnd(Duration(milliseconds: value.toInt())),
              iconPosition: IconPosition.below,
              startIcon: Text(
                '${widget.currentPlaybackTime.inMinutes}:${(widget.currentPlaybackTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              endIcon: Text(
                '-${widget.remainingTime.inMinutes}:${(widget.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16.0,
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
                    //   if (widget.currentPlaybackTime.inSeconds < 3) {
                    //     widget.onSeek(const Duration(seconds: 0));
                    //   } else {
                    widget.swiperController.swipeLeft();
                    // }
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
