import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/model/song_model.dart';

class StorageService {
  static const platform = MethodChannel('com.example.myapp/audio');
  Future<List<Song>> fetchAudioFiles() async {
    List<Map<String, dynamic>> audioFiles = [];
    try {
      final String result = await platform.invokeMethod('getAudioFiles');
      final List<dynamic> parsedList = jsonDecode(result);
      audioFiles =
          parsedList.map((item) => item as Map<String, dynamic>).toList();
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        debugPrint(
            "Permissions not granted. Please grant permissions to access audio files.");
      } else {
        debugPrint("Failed to get audio files: '${e.message}'.");
      }
      rethrow;
    } catch (e) {
      debugPrint("Failed to get audio files: '${e.toString()}'.");
      rethrow;
    }

    return audioFiles.map((map) => Song.fromMap(map)).toList();
  }
}
