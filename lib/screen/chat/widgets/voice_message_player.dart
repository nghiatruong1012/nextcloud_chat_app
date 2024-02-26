import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Map<String, String> header;

  AudioPlayerWidget({required this.audioUrl, required this.header});

  @override
  _AudioPlayerWidgetState createState() =>
      _AudioPlayerWidgetState(audioUrl: audioUrl, header: header);
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  final String audioUrl;
  final Map<String, String> header;

  double _currentProgress = 0.0;
  String _totalDuration = "00:00";
  String _currentDuration = "00:00";

  _AudioPlayerWidgetState({required this.audioUrl, required this.header});

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentProgress = position.inMilliseconds.toDouble() /
            _audioPlayer.duration!.inMilliseconds.toDouble();
        _currentProgress = _currentProgress.clamp(0.0, 1.0);
        _currentDuration =
            _formatDuration(Duration(milliseconds: position.inMilliseconds));
      });
    });

    _audioPlayer.durationStream.listen((event) {
      setState(() {
        _totalDuration =
            _formatDuration(Duration(milliseconds: event!.inMilliseconds));
      });
    });

    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentProgress = 0;
        _currentDuration = "00:00";
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
      _audioPlayer.setUrl(audioUrl, headers: header);
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

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayer,
            padding: EdgeInsets.all(0),
          ),
          Container(
            width: 150,
            child: Slider(
              value: _currentProgress,
              onChanged: (value) {
                _seekTo(value);
              },
            ),
          ),
          Text(_currentDuration),
        ],
      ),
    );
  }
}
