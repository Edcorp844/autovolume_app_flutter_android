import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:fl_chart/fl_chart.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const MethodChannel _channel =
      MethodChannel('com.example.myapp/audio');

  final AudioPlayer _audioPlayer = AudioPlayer();
  final NoiseMeter _noiseMeter = NoiseMeter();
  bool _isAutoVolumeEnabled = false;
  double _volume = 0.5;
  double _noiseLevel = 0;
  double _autoVolumeThreshold = 0.5;
  List<double> _noiseData = [];
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late PlayerController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = PlayerController();
    _fetchSystemVolume();
    _startNoiseMonitoring();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Fetch system volume from native platform
  Future<void> _fetchSystemVolume() async {
    try {
      final double volume = await _channel.invokeMethod('getCurrentVolume');
      setState(() {
        _volume = volume;
      });
    } catch (e) {
      print("Error fetching system volume: $e");
    }
  }

  /// Set system volume
  Future<void> _setSystemVolume(double value) async {
    try {
      await _channel.invokeMethod('setVolume', value);
      setState(() {
        _volume = value;
      });
    } catch (e) {
      print("Error setting system volume: $e");
    }
  }

  void _startNoiseMonitoring() {
    _noiseSubscription = _noiseMeter.noise.listen((noiseReading) {
      setState(() {
        _noiseLevel = noiseReading.meanDecibel;
        _noiseData.add(_noiseLevel);
        if (_noiseData.length > 50) {
          _noiseData.removeAt(0);
        }
      });
      _adjustVolume();
    });
  }

  void _stopNoiseMonitoring() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  void _adjustVolume() {
    if (_isAutoVolumeEnabled) {
      final adjustedVolume = (_noiseLevel / 100) * _autoVolumeThreshold;
      _setSystemVolume(adjustedVolume.clamp(0.0, 1.0));
    }
  }

  void _toggleAutoVolume(bool isEnabled) {
    setState(() {
      _isAutoVolumeEnabled = isEnabled;
    });
    if (isEnabled) {
      _startNoiseMonitoring();
    } else {
      _stopNoiseMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            centerTitle: true,
            stretch: true,
            title: Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto Volume Toggle
                  Row(
                    children: [
                      const Text(
                        'Auto Volume',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAutoVolumeEnabled,
                        onChanged: _toggleAutoVolume,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: _noiseData.length.toDouble(),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _noiseData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value);
                            }).toList(),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.green
                              ], // Gradient from blue to green
                            ),
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.1)
                                ],
                              ),
                            ),
                          ),
                          // High Noise Level Curve (Red)
                          LineChartBarData(
                            spots: _noiseData
                                .asMap()
                                .entries
                                .where((entry) =>
                                    entry.value >=
                                    90) // Only plot if >= 90% of max
                                .map((entry) =>
                                    FlSpot(entry.key.toDouble(), entry.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.red, // High noise level curve
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Noise Level Display
                  Text(
                    'Noise Level: ${_noiseLevel.toStringAsFixed(0)} dB',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  // Sensitivity Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensitivity',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Slider(
                        value: _autoVolumeThreshold,
                        min: 0,
                        max: 1,
                        onChanged: _isAutoVolumeEnabled
                            ? (value) {
                                setState(() {
                                  _autoVolumeThreshold = value;
                                });
                              }
                            : null,
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Volume Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media Volume',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Slider(
                        value: _volume,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          _setSystemVolume(value);
                        },
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
