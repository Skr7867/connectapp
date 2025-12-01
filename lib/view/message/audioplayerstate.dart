import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerDialog extends StatefulWidget {
  final String audioUrl;
  final String fileName;

  const AudioPlayerDialog({
    super.key,
    required this.audioUrl,
    required this.fileName,
  });

  @override
  _AudioPlayerDialogState createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  void _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Listen to duration changes BEFORE setting source
      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          print('Audio duration loaded: $duration');
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      });

      // Listen to position changes
      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      // Listen to player completion
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = _duration;
          });
        }
      });

      // Listen to player state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      // Set timeout for loading
      Timer(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          setState(() {
            _errorMessage = 'Audio loading timeout. Please check the file URL.';
            _isLoading = false;
          });
        }
      });

      // Set the audio source - try different methods based on URL type
      print('Loading audio from: ${widget.audioUrl}');

      if (widget.audioUrl.startsWith('http://') ||
          widget.audioUrl.startsWith('https://')) {
        // Network URL
        await _audioPlayer.setSourceUrl(widget.audioUrl);
      } else if (widget.audioUrl.startsWith('/') ||
          widget.audioUrl.contains(':\\')) {
        // Local file path
        await _audioPlayer.setSourceDeviceFile(widget.audioUrl);
      } else {
        // Asset or other
        await _audioPlayer.setSourceUrl(widget.audioUrl);
      }

      // Fallback: if duration is still not loaded after 3 seconds, try to get it manually
      Timer(const Duration(seconds: 3), () async {
        if (mounted && _isLoading) {
          try {
            // Try to get duration manually
            final duration = await _audioPlayer.getDuration();
            if (duration != null && duration.inMilliseconds > 0) {
              setState(() {
                _duration = duration;
                _isLoading = false;
              });
            } else {
              setState(() {
                _errorMessage =
                    'Unable to load audio duration. File may be corrupted.';
                _isLoading = false;
              });
            }
          } catch (e) {
            setState(() {
              _errorMessage = 'Failed to get audio duration: $e';
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load audio: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Use play() instead of resume() for first time
        if (_position == Duration.zero) {
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error playing/pausing audio: $e');
      setState(() {
        _errorMessage = 'Playback error: ${e.toString()}';
      });
    }
  }

  Future<void> _seekTo(double value) async {
    try {
      final position = Duration(seconds: value.toInt());
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.fileName,
        style: const TextStyle(fontSize: 16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.audiotrack,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Loading audio...'),
                ],
              )
            else if (_errorMessage != null)
              Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else ...[
              // Play/Pause Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _playPause,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 64,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Slider - FIXED
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _duration.inSeconds > 0
                          ? _position.inSeconds
                              .clamp(0, _duration.inSeconds)
                              .toDouble()
                          : 0.0,
                      min: 0.0,
                      max: _duration.inSeconds > 0
                          ? _duration.inSeconds.toDouble()
                          : 1.0,
                      onChanged: _duration.inSeconds > 0
                          ? (value) {
                              _seekTo(value);
                            }
                          : null,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey[300],
                    ),
                  ),

                  // Time Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
