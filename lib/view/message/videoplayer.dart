import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String fileName;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.fileName,
  });

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();

      setState(() {
        _isInitialized = true;
      });

      _controller.play();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double getResponsiveHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.65; // WhatsApp style size
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: _hasError
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text('Failed to load video',
                          style: TextStyle(color: Colors.white)),
                    ],
                  )
                : _isInitialized
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final videoAspect = _controller.value.aspectRatio;
                          final boxWidth = constraints.maxWidth;
                          final boxHeight = getResponsiveHeight(context);

                          /// Auto adjust height/width according to video
                          double finalWidth = boxWidth;
                          double finalHeight = finalWidth / videoAspect;

                          if (finalHeight > boxHeight) {
                            finalHeight = boxHeight;
                            finalWidth = finalHeight * videoAspect;
                          }

                          return SizedBox(
                            width: finalWidth,
                            height: finalHeight,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller),

                                // Tap to Play/Pause
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),

                                // Play/Pause Icon
                                if (!_controller.value.isPlaying)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      )
                    : const CircularProgressIndicator(color: Colors.white),
          ),

          // Close Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Progress Bar
          if (_isInitialized)
            Positioned(
              bottom: 12,
              left: 15,
              right: 15,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
