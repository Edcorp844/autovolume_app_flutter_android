import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioController {
  static const MethodChannel _channel = MethodChannel(
    'com.example.myapp/audio',
  );

  static Future<void> increaseVolume() async {
    try {
      await _channel.invokeMethod('increaseVolume');
    } catch (e) {
      debugPrint("Error increasing volume: $e");
    }
  }

  static Future<void> decreaseVolume() async {
    try {
      await _channel.invokeMethod('decreaseVolume');
    } catch (e) {
      debugPrint("Error decreasing volume: $e");
    }
  }
}
