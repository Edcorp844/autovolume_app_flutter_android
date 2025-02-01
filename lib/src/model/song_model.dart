import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String title;
  final String artist;
  final String album;
  final String path; // Path to the audio file
  final String albumArtPath; // Path to the album art image
  final Duration duration; // Duration of the song

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.albumArtPath,
    required this.duration,
  });

  @override
  List<Object?> get props =>
      [title, artist, album, path, albumArtPath, duration];

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      path: map['path'],
      albumArtPath: map['albumArtPath'],
      duration: Duration(milliseconds: map['duration']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'albumArtPath': albumArtPath,
      'duration': duration.inMilliseconds,
    };
  }
}
