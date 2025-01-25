import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:noise_meter/noise_meter.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NoiseMeter _noiseMeter = NoiseMeter();
  bool _isAutoVolumeEnabled = false;
  double _volume = 0.5;
  double _noiseLevel = 0;
  double _autoVolumeThreshold = 0.5;
  bool _isPlaying = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late PlayerController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = PlayerController();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setSource(UrlSource('https://example.com/song.mp3'));
    // Initialize the waveform with the audio source.
    _waveController
      ..preparePlayer(
        path: 'https://example.com/song.mp3', // Replace with your file path
        noOfSamples: 100,
      )
      ..setVolume(_volume);
  }

  void _startNoiseMonitoring() {
    _noiseSubscription = _noiseMeter.noise.listen((noiseReading) {
      setState(() {
        _noiseLevel = noiseReading.meanDecibel;
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
      setState(() {
        _volume = adjustedVolume.clamp(0.0, 1.0);
      });
      _audioPlayer.setVolume(_volume);
      _waveController.setVolume(_volume);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _waveController.pausePlayer();
    } else {
      await _audioPlayer.resume();
      _waveController.startPlayer();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
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
  void dispose() {
    _noiseSubscription?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
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
                  // Noise Level Visualizer
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: AudioFileWaveforms(
                      playerController: _waveController,
                      waveformType: WaveformType.fitWidth,
                      size: Size(MediaQuery.of(context).size.width, 100),
                      playerWaveStyle: const PlayerWaveStyle(
                        waveThickness: 2.0,
                        fixedWaveColor: Color.fromARGB(255, 69, 180, 245),
                        liveWaveColor: Color.fromARGB(255, 243, 33, 215),
                        seekLineColor: Colors.red,
                        seekLineThickness: 2.0,
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
                  // Play/Pause Button
                  ElevatedButton(
                    onPressed: _togglePlayPause,
                    child: Text(_isPlaying ? 'Pause' : 'Play'),
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
                          setState(() {
                            _volume = value;
                          });
                          _audioPlayer.setVolume(_volume);
                          _waveController.setVolume(_volume);
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
