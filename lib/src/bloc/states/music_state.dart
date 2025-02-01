import 'package:equatable/equatable.dart';
import 'package:myapp/src/model/song_model.dart';

//Music load state
abstract class SongLoadState extends Equatable {
  const SongLoadState();

  @override
  List<Object?> get props => [];
}

class MusicLoading extends SongLoadState {}

class MusicLoaded extends SongLoadState {
  final List<Song> audioFiles;

  const MusicLoaded(this.audioFiles);

  @override
  List<Object?> get props => [audioFiles];
}

class SongLoadError extends SongLoadState {
  final String message;

  const SongLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

//Music palying state
abstract class MusicState extends Equatable {
  const MusicState();

  @override
  List<Object?> get props => [];
}

class MusicPlaying extends MusicState {
  final Song song;
  final Duration position;
  final bool isPlaying;

  const MusicPlaying(this.song, this.position, this.isPlaying);

  @override
  List<Object?> get props => [song, position, isPlaying];
}

class MusicPaused extends MusicState {
  final Song song;
  final Duration position;
  final bool isPaused;

  const MusicPaused(this.song, this.position, this.isPaused);

  @override
  List<Object?> get props => [song, position, isPaused];
}

class MusicStopped extends MusicState {}

class MusicError extends MusicState {
  final String message;

  const MusicError(this.message);

  @override
  List<Object?> get props => [message];
}
