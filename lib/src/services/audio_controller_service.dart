import 'package:flutter/services.dart';

class AudioController {
  static const MethodChannel _channel = MethodChannel('com.example.myapp/audio');

  static Future<void> increaseVolume() async {
    try {
      await _channel.invokeMethod('increaseVolume');
    } catch (e) {
      print("Error increasing volume: $e");
    }
  }

  static Future<void> decreaseVolume() async {
    try {
      await _channel.invokeMethod('decreaseVolume');
    } catch (e) {
      print("Error decreasing volume: $e");
    }
  }
}
