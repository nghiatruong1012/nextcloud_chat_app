import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  AudioPlayerWidget({required this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() =>
      _AudioPlayerWidgetState(audioUrl: audioUrl);
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  final String audioUrl;

  double _currentProgress = 0.0;

  _AudioPlayerWidgetState({required this.audioUrl});

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentProgress = position.inMilliseconds.toDouble() /
            _audioPlayer.duration!.inMilliseconds.toDouble();
        _currentProgress = _currentProgress.clamp(0.0, 1.0);
      });
    });

    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentProgress = 0;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayer() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seekTo(double progress) {
    int positionInMillis =
        (progress * _audioPlayer.duration!.inMilliseconds).round();
    _audioPlayer.seek(Duration(milliseconds: positionInMillis));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayer,
        ),
        Slider(
          value: _currentProgress,
          onChanged: (value) {
            _seekTo(value);
          },
        ),
      ],
    );
  }
}
