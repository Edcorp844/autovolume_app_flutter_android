import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/events/music_event.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/services/storage_service.dart';
import 'package:rxdart/rxdart.dart';

class StorageBloc extends Bloc<StrorageEvent, SongLoadState> {
  final StorageService storageService;
  StorageBloc(this.storageService) : super(MusicLoading()) {
    on<FetchMusic>(_onFetchMusic);
  }

  Future<void> _onFetchMusic(
      FetchMusic event, Emitter<SongLoadState> emit) async {
    emit(MusicLoading());
    try {
      final audioFiles = await storageService.fetchAudioFiles();
      debugPrint('Music fetched successfully.');
      emit(MusicLoaded(audioFiles));
    } catch (e) {
      emit(SongLoadError('Failed to load audio files: $e'));
    }
  }
}

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  MusicBloc() : super(MusicStopped()) {
    on<PlayMusic>(_onPlayMusic);
    on<PauseMusic>(_onPauseMusic);
    on<ResumeMusic>(_onResumeMusic);
    on<StopMusic>(_onStopMusic);
    on<SeekMusic>(_onSeekMusic);

    // Listen to position changes (debounced)
    _audioPlayer.onPositionChanged
        .debounceTime(const Duration(milliseconds: 500))
        .listen((position) {
      if (state is MusicPlaying) {
        final currentState = state as MusicPlaying;
        _emitStateIfChanged(MusicPlaying(
          currentState.song,
          position,
          currentState.isPlaying,
        ));
      }
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.completed) {
        _audioPlayer.seek(Duration.zero);
        _emitStateIfChanged(MusicStopped());
      }
    });
  }

  Future<void> _onPlayMusic(PlayMusic event, Emitter<MusicState> emit) async {
    try {
      // Stop current playback if a song is already playing
      if (state is MusicPlaying || state is MusicPaused) {
        await _audioPlayer.stop();
      }

      // Set the source and play the new song
      await _audioPlayer.setSource(DeviceFileSource(event.song.path));
      await _audioPlayer.resume();

      _emitStateIfChanged(MusicPlaying(event.song, Duration.zero, true));
    } catch (e) {
      emit(MusicError('Failed to play the selected song: $e'));
    }
  }

  Future<void> _onPauseMusic(PauseMusic event, Emitter<MusicState> emit) async {
    if (state is MusicPlaying) {
      await _audioPlayer.pause();
      final currentState = state as MusicPlaying;
      emit(MusicPaused(currentState.song, currentState.position, true));
    }
  }

  Future<void> _onResumeMusic(
      ResumeMusic event, Emitter<MusicState> emit) async {
    if (state is MusicPaused) {
      final currentState = state as MusicPaused;
      await _audioPlayer.seek(currentState.position);
      await _audioPlayer.resume();
      emit(MusicPlaying(currentState.song, currentState.position, true));
    }
  }

  Future<void> _onStopMusic(StopMusic event, Emitter<MusicState> emit) async {
    await _audioPlayer.stop();
    _emitStateIfChanged(MusicStopped());
    debugPrint('Playback stopped.');
  }

  Future<void> _onSeekMusic(SeekMusic event, Emitter<MusicState> emit) async {
    if (state is MusicPlaying) {
      await _audioPlayer.seek(event.position);
      final currentState = state as MusicPlaying;
      _emitStateIfChanged(MusicPlaying(
        currentState.song,
        event.position,
        currentState.isPlaying,
      ));
    }
  }

  /// Ensures state is only emitted if it has changed
  void _emitStateIfChanged(MusicState newState) {
    emit(newState);
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
