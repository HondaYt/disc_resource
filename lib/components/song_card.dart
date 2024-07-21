import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:music_kit/music_kit.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:flutter/cupertino.dart';

class SongCard extends StatefulWidget {
  final Map<String, dynamic> song;
  final Duration currentPlaybackTime;
  final Duration songDuration;
  final Duration remainingTime;
  final MusicPlayerPlaybackStatus musicPlayerStatus;
  final Function(Duration) onSeek;
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
    required this.onSeek,
    required this.onPause,
    required this.onResume,
    required this.swiperController,
  });

  @override
  SongCardState createState() => SongCardState();
}

class SongCardState extends State<SongCard> {
  late MusicPlayerPlaybackStatus wasMusicPlayerStatusBeforeSeek;
  final _controller = InteractiveSliderController(0.0);

  @override
  void initState() {
    super.initState();
    _controller.value = widget.currentPlaybackTime.inMilliseconds.toDouble();
  }

  @override
  void didUpdateWidget(SongCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPlaybackTime != oldWidget.currentPlaybackTime) {
      _controller.value = widget.currentPlaybackTime.inMilliseconds.toDouble();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 300.0,
                child: Image.network(
                  widget.song['attributes']['artwork']['url']
                      .replaceAll('{w}', '700')
                      .replaceAll('{h}', '700'),
                  fit: BoxFit.cover,
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
            const SizedBox(height: 8.0),
            // Slider(
            //   value: widget.currentPlaybackTime.inMilliseconds.toDouble(),
            //   max: widget.songDuration.inMilliseconds.toDouble(),
            //   onChangeStart: (value) {
            //     wasMusicPlayerStatusBeforeSeek = widget.musicPlayerStatus;
            //     widget.onPause();
            //   },
            //   onChangeEnd: (value) {
            //     widget.onSeek(Duration(milliseconds: value.toInt()));
            //     if (wasMusicPlayerStatusBeforeSeek ==
            //         MusicPlayerPlaybackStatus.playing) {
            //       widget.onResume();
            //     }
            //   },
            //   onChanged: (value) {
            //     widget.onSeek(Duration(milliseconds: value.toInt()));
            //   },
            //   divisions: 2000, // Optional: to make the slider smoother
            // ),
            InteractiveSlider(
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
              controller: _controller,
              min: 0,
              max: widget.songDuration.inMilliseconds.toDouble(),
              onChangeStart: (value) {
                wasMusicPlayerStatusBeforeSeek = widget.musicPlayerStatus;
                widget.onPause();
              },
              onChangeEnd: (value) {
                widget.onSeek(Duration(milliseconds: value.toInt()));
                if (wasMusicPlayerStatusBeforeSeek ==
                    MusicPlayerPlaybackStatus.playing) {
                  widget.onResume();
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
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
                  child: Icon(widget.musicPlayerStatus ==
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
                    widget.swiperController.swipeRight();
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
