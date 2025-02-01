import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/events/music_event.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/util/mixin/duration_mixin.dart';

class PlayingScreen extends StatefulWidget {
  final Song song;

  const PlayingScreen({super.key, required this.song});

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with KotlinDurationHandler {
  late PlayerController _waveController;

  bool isPlaying = false;
  Duration _position = Duration.zero;
  late Song _currentSong;

  @override
  void initState() {
    super.initState();
    _waveController = PlayerController();
    _initializePlayer();
  }

  void _initializePlayer() {
    _startPlaying();
  }

  Future<void> _startPlaying() async {
    await Future.delayed(Duration.zero);
    try {
      final currentState = mounted ? context.read<MusicBloc>().state : null;

      if (currentState is MusicPlaying && currentState.song == widget.song) {
        setState(() {
          isPlaying = true;
          _currentSong = currentState.song;
          _position = currentState.position;
        });
        await _waveController.preparePlayer(path: _currentSong.path);
      } else if (currentState is MusicPaused &&
          currentState.song == widget.song) {
        setState(() {
          isPlaying = false;
          _currentSong = currentState.song;
          _position = currentState.position;
        });
        await _waveController.preparePlayer(path: _currentSong.path);
      } else {
        if (mounted) {
          context.read<MusicBloc>().add(PlayMusic(widget.song));
        }
        setState(() {
          _currentSong = widget.song;
        });
        await _waveController.preparePlayer(path: widget.song.path);
      }
    } catch (e) {
      debugPrint("Error starting audio: $e");
    }
  }

  @override
  void dispose() {
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
      body: BlocConsumer<MusicBloc, MusicState>(
        listener: (context, state) {
          if (state is MusicPlaying) {
            setState(() {
              isPlaying = true;
              _currentSong = state.song;
              _position = state.position;
            });
            _waveController.seekTo(state.position.inMilliseconds);
          }
          if (state is MusicPaused) {
            setState(() {
              isPlaying = false;
              _currentSong = state.song;
              _position = state.position;
            });
            _waveController.seekTo(state.position.inMilliseconds);
          }
          if (state is MusicLoaded) {
            _waveController.preparePlayer(path: widget.song.path);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAlbumArt(),
                  const SizedBox(height: 30),
                  _buildSongDetails(),
                  const SizedBox(height: 30),
                  _buildWaveform(),
                  const SizedBox(height: 10),
                  _buildTimeLabels(),
                  const SizedBox(height: 24),
                  _buildPlaybackControls(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: widget.song.albumArtPath != "no_album_art" &&
                  File(widget.song.albumArtPath).existsSync()
              ? FileImage(File(widget.song.albumArtPath))
              : const AssetImage('assets/UnkownAlbum.jpg') as ImageProvider,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue,
        border: Border.all(
          color: const Color.fromARGB(41, 241, 241, 241),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            offset: Offset(5, 5),
            blurRadius: 10,
          )
        ],
      ),
    );
  }

  Widget _buildSongDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.song.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          '${widget.song.artist} - [${widget.song.album}]',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return AudioFileWaveforms(
      size: Size(MediaQuery.of(context).size.width, 30),
      playerController: _waveController,
      enableSeekGesture: true,
      waveformType: WaveformType.fitWidth,
      continuousWaveform: true,
      playerWaveStyle: const PlayerWaveStyle(
        waveThickness: 1.5,
        fixedWaveColor: Color.fromARGB(255, 69, 180, 245),
        liveWaveColor: Color.fromARGB(255, 243, 33, 215),
        scaleFactor: 30.0,
        waveCap: StrokeCap.round,
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            '${_position.inMinutes}:${_position.inSeconds.remainder(60).toString().padLeft(2, '0')}'),
        Text(formatDuration(widget.song.duration)),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 26,
          onPressed: () {
            _seek(-10);
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous_outlined),
          iconSize: 40,
          onPressed: () {
            // Handle skip previous logic here
          },
        ),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
          ),
          iconSize: 56,
          onPressed: () {
            if (isPlaying) {
              context
                  .read<MusicBloc>()
                  .add(PauseMusic(song: _currentSong, position: _position));
            } else {
              context
                  .read<MusicBloc>()
                  .add(ResumeMusic(song: _currentSong, position: _position));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_outlined),
          iconSize: 40,
          onPressed: () {
            // Handle skip next logic here
          },
        ),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 26,
          onPressed: () {
            _seek(10);
          },
        ),
      ],
    );
  }

  void _seek(int seconds) {
    final newPosition = _position + Duration(seconds: seconds);
    if (newPosition >= Duration.zero && newPosition <= widget.song.duration) {
      context.read<MusicBloc>().add(SeekMusic(position: newPosition));
    }
  }
}
