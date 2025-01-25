import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const platform = MethodChannel('com.example.myapp/audio');
  Future<List<Map<String, dynamic>>> fetchAudioFiles() async {
    List<Map<String, dynamic>> audioFiles = [];
    try {
      final String result = await platform.invokeMethod('getAudioFiles');
      final List<dynamic> parsedList = jsonDecode(result);
      audioFiles =
          parsedList.map((item) => item as Map<String, dynamic>).toList();
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        // Handle permission denied case
        print(
            "Permissions not granted. Please grant permissions to access audio files.");
      } else {
        print("Failed to get audio files: '${e.message}'.");
      }
    }
    print(audioFiles);
    return audioFiles;
  }
}
