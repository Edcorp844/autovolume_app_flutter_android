import 'package:equatable/equatable.dart';
import 'package:myapp/src/model/song_model.dart';

abstract class StrorageEvent extends Equatable {
  const StrorageEvent();

  @override
  List<Object?> get props => [];
}

abstract class MusicEvent extends Equatable {
  const MusicEvent();

  @override
  List<Object?> get props => [];
}

class FetchMusic extends StrorageEvent {}

class PlayMusic extends MusicEvent {
  final Song song;
  const PlayMusic(this.song);

  @override
  List<Object?> get props => [song];
}

class PauseMusic extends MusicEvent {
  final Song song;
  final Duration position;

  const PauseMusic({required this.song, required this.position});

  @override
  List<Object?> get props => [song, position];
}

class ResumeMusic extends MusicEvent {
  final Song song;
  final Duration position;

  const ResumeMusic({required this.song, required this.position});

  @override
  List<Object?> get props => [song, position];
}

class StopMusic extends MusicEvent {}

class SeekMusic extends MusicEvent {
  final Duration position;
  const SeekMusic({required this.position});

  @override
  List<Object?> get props => [position];
}
