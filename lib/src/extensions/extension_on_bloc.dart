import 'dart:async';
import 'dart:isolate';

import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/services/storage_service.dart';

extension FetchSongs on MusicBloc {
 void _isolateEntryPoint(SendPort sendPort) async {
  final List<Song> songs = await StorageService().fetchAudioFiles();
  sendPort.send(songs);
}

Future<List<Song>> fetchAudioFilesInIsolate() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);
  return await receivePort.first as List<Song>;
}
}
