import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:myapp/src/bloc/events/music_event.dart';

class PlayMusic extends MusicEvent {
  final FileSystemEntity song;

  const PlayMusic(this.song);

  @override
  List<Object?> get props => [song];
}

class PauseMusic extends MusicEvent {}

class ResumeMusic extends MusicEvent {}

class SeekMusic extends MusicEvent {
  final Duration position;

  const SeekMusic(this.position);

  @override
  List<Object?> get props => [position];
}

abstract class MusicState extends Equatable {
  const MusicState();

  @override
  List<Object?> get props => [];
}

class MusicLoading extends MusicState {}

class MusicLoaded extends MusicState {
  final List<Map<String, dynamic>> audioFiles;

  const MusicLoaded(this.audioFiles);

  @override
  List<Object?> get props => [audioFiles];
}

class MusicPlaying extends MusicState {
  final FileSystemEntity song;
  final Duration position;
  final bool isPlaying;

  const MusicPlaying(this.song, this.position, this.isPlaying);

  @override
  List<Object?> get props => [song, position, isPlaying];
}

class MusicError extends MusicState {
  final String message;

  const MusicError(this.message);

  @override
  List<Object?> get props => [message];
}
