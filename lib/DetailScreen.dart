import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'Common/CustomAppBar.dart';

class DetailScreen extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;

  DetailScreen({required this.mediaPath, required this.isVideo});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = VideoPlayerController.file(File(widget.mediaPath));
      _initializeVideoPlayerFuture = _controller!.initialize();
      _controller!.addListener(_videoListener);
    }
  }

  void _videoListener() {
    final bool isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  void _rewindVideo() {
    final Duration position = _controller!.value.position;
    _controller!.seekTo(position - Duration(seconds: 10));
  }

  void _forwardVideo() {
    final Duration position = _controller!.value.position;
    _controller!.seekTo(position + Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Media Detail',
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Hero(
              tag: widget.mediaPath,
              child: widget.isVideo
                  ? FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                              _buildControls(),
                            ],
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    )
                  : InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: EdgeInsets.all(8),
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.file(
                        File(widget.mediaPath),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          );
        },
      ),
      floatingActionButton: widget.isVideo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }

  Widget _buildControls() {
    String positionText = _formatDuration(_controller!.value.position);
    String durationText = _formatDuration(_controller!.value.duration);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _rewindVideo,
              icon: Icon(Icons.fast_rewind),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              color: Colors.white,
            ),
            IconButton(
              onPressed: _forwardVideo,
              icon: Icon(Icons.fast_forward),
              color: Colors.white,
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                positionText,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                durationText,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
