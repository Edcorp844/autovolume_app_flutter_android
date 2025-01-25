import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayingScreen extends StatefulWidget {
  final Map<String, dynamic> song;

  const PlayingScreen({super.key, required this.song});

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late PlayerController _waveController;

  bool isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _waveController = PlayerController();
    _startPlaying();
  }

  Future<void> _startPlaying() async {
    try {
      // Initialize the audio file
      await _audioPlayer.setSource(UrlSource(widget.song['path']));

      // Listen to position changes to update waveform progress
      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
        _waveController
            .seekTo(position.inMilliseconds); // Update waveform position
      });

      // Listen to player state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      });

      // Listen to duration changes
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      });

      // Start playback
      await _audioPlayer.resume();
      _waveController.preparePlayer(
          path: widget.song['path']); // Initialize waveform
    } catch (e) {
      debugPrint("Error starting audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playing Now'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          'https://cdn.dribbble.com/userupload/7461898/file/original-705496ca4ffa4f7663474af28b89bf07.png')),
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.blue,
                  border: Border.all(
                      color: const Color.fromARGB(41, 241, 241, 241), width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(80, 0, 0, 0),
                        offset: Offset(5, 5),
                        blurRadius: 10)
                  ]),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.song['path'].split("/").last,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 30),
            AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width, 50),
              playerController: _waveController,
              enableSeekGesture: true,
              waveformType: WaveformType.long,
              playerWaveStyle: const PlayerWaveStyle(
                waveThickness: 2.0,
                fixedWaveColor: Color.fromARGB(255, 69, 180, 245),
                liveWaveColor: Color.fromARGB(255, 243, 33, 215),
                seekLineColor: Colors.red,
                seekLineThickness: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${_position.inMinutes}:${_position.inSeconds.remainder(60).toString().padLeft(2, '0')}'),
                Text(
                    '${_duration.inMinutes}:${_duration.inSeconds.remainder(60).toString().padLeft(2, '0')}')
              ],
            ),
            const SizedBox(height: 24),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 26,
                  onPressed: () async {
                    final currentPosition =
                        await _audioPlayer.getCurrentPosition() ??
                            Duration.zero;
                    await _audioPlayer.seek(Duration(
                        milliseconds: currentPosition.inMilliseconds - 10000));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous_outlined,
                  ),
                  iconSize: 40,
                  onPressed: () async {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                      _waveController.pausePlayer();
                    } else {
                      await _audioPlayer.resume();
                      _waveController.startPlayer();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                  iconSize: 56,
                  onPressed: () async {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                      _waveController.pausePlayer();
                    } else {
                      await _audioPlayer.resume();
                      _waveController.startPlayer();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_outlined,
                  ),
                  iconSize: 40,
                  onPressed: () async {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                      _waveController.pausePlayer();
                    } else {
                      await _audioPlayer.resume();
                      _waveController.startPlayer();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 26,
                  onPressed: () async {
                    final currentPosition =
                        await _audioPlayer.getCurrentPosition() ??
                            Duration.zero;
                    await _audioPlayer.seek(Duration(
                        milliseconds: currentPosition.inMilliseconds + 10000));
                  },
                ),
              ],
            ),
            // Position and Duration
          ],
        ),
      ),
    );
  }
}
