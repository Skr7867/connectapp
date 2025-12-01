import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderDialog extends StatefulWidget {
  const AudioRecorderDialog({super.key});

  @override
  _AudioRecorderDialogState createState() => _AudioRecorderDialogState();
}

class _AudioRecorderDialogState extends State<AudioRecorderDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isInitializing = true;
  String _recordingPath = '';
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRecording();
  }

  Future<void> _initializeRecording() async {
    try {
      // Check if recording is supported
      if (await _recorder.hasPermission()) {
        await _startRecording();
      } else {
        setState(() {
          _errorMessage = 'Microphone permission not granted';
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize recording: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getTemporaryDirectory();
      _recordingPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath,
      );

      setState(() {
        _isRecording = true;
        _isInitializing = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start recording: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stop();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Audio Recording'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isInitializing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing recorder...'),
              ],
            )
          else if (_errorMessage != null)
            Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else ...[
            Icon(
              _isRecording ? Icons.mic : Icons.mic_off,
              size: 64,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? 'Recording in progress...' : 'Recording stopped',
              style: TextStyle(
                fontSize: 16,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _stopRecording();
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
        if (!_isInitializing && _errorMessage == null)
          ElevatedButton(
            onPressed: _isRecording
                ? () async {
                    await _stopRecording();
                    if (_recordingPath.isNotEmpty &&
                        File(_recordingPath).existsSync()) {
                      Navigator.pop(context, File(_recordingPath));
                    } else {
                      Navigator.pop(context, null);
                    }
                  }
                : null,
            child: const Text('Send'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
