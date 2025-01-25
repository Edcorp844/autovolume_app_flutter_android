import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/events/music_event.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/services/storage_service.dart';


class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StorageService storageService;

  MusicBloc(this.storageService) : super(MusicLoading()) {
    on<FetchMusic>(_onFetchMusic);
    on<PlayMusic>(_onPlayMusic);
    on<PauseMusic>(_onPauseMusic);
    on<ResumeMusic>(_onResumeMusic);
    on<SeekMusic>(_onSeekMusic);

    _audioPlayer.onPositionChanged.listen((position) {
      if (state is MusicPlaying) {
        final currentState = state as MusicPlaying;
        emit(MusicPlaying(currentState.song, position, currentState.isPlaying));
      }
    });
  }

  Future<void> _onFetchMusic(FetchMusic event, Emitter<MusicState> emit) async {
    emit(MusicLoading());
    try {
      final audioFiles = await storageService.fetchAudioFiles();
      emit(MusicLoaded(audioFiles));
    } catch (e) {
      emit(MusicError('Failed to load audio files: $e'));
    }
  }

  Future<void> _onPlayMusic(PlayMusic event, Emitter<MusicState> emit) async {
    try {
      await _audioPlayer.setSource(DeviceFileSource(event.song.path));
      await _audioPlayer.resume();
      emit(MusicPlaying(event.song, Duration.zero, true));
    } catch (e) {
      emit(MusicError('Failed to play audio: $e'));
    }
  }

  Future<void> _onPauseMusic(PauseMusic event, Emitter<MusicState> emit) async {
    await _audioPlayer.pause();
    if (state is MusicPlaying) {
      final currentState = state as MusicPlaying;
      emit(MusicPlaying(currentState.song, currentState.position, false));
    }
  }

  Future<void> _onResumeMusic(ResumeMusic event, Emitter<MusicState> emit) async {
    if (state is MusicPlaying) {
      final currentState = state as MusicPlaying;
      await _audioPlayer.seek(currentState.position);
      await _audioPlayer.resume();
      emit(MusicPlaying(currentState.song, currentState.position, true));
    }
  }

  Future<void> _onSeekMusic(SeekMusic event, Emitter<MusicState> emit) async {
    await _audioPlayer.seek(event.position);
    if (state is MusicPlaying) {
      final currentState = state as MusicPlaying;
      emit(MusicPlaying(currentState.song, event.position, true));
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}