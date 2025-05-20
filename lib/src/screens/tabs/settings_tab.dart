import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/screens/widgets/knob.dart';
import 'package:myapp/src/screens/widgets/senstivity_knob.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicBloc, MusicState>(
      builder: (context, state) {
        final musicBloc = context.read<MusicBloc>();

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
                      const SizedBox(height: 20),
                      // Noise Level Visualization
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: StreamBuilder<double>(
                          stream: musicBloc.noiseStream,
                          builder: (context, snapshot) {
                            return LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: musicBloc.noiseData.length.toDouble(),
                                minY: 0,
                                maxY: 100,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots:
                                        musicBloc.noiseData.asMap().entries.map(
                                          (entry) {
                                            return FlSpot(
                                              entry.key.toDouble(),
                                              entry.value,
                                            );
                                          },
                                        ).toList(),
                                    isCurved: true,
                                    gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.green],
                                    ),
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.withOpacity(0.2),
                                          Colors.blue.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots:
                                        musicBloc.noiseData
                                            .asMap()
                                            .entries
                                            .where((entry) => entry.value >= 90)
                                            .map(
                                              (entry) => FlSpot(
                                                entry.key.toDouble(),
                                                entry.value,
                                              ),
                                            )
                                            .toList(),
                                    isCurved: true,
                                    color: Colors.red,
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
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Current Noise Level Display
                      Text(
                        'Noise Level: ${musicBloc.currentNoiseLevel.toStringAsFixed(0)} dB',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),
                      // Base Volume Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  SenetivityKnob(
                                    volume: musicBloc.currentThreshold,
                                    onVolumeChanged: (value) {
                                      musicBloc.autoVolumeThreshold = value;
                                    },
                                    size: 150, // Adjust size as needed
                                  ),
                                  const Text(
                                    'Sensitivity Level',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  VerticalVolumeKnob(
                                    volume:
                                        musicBloc
                                            .currentVolume, // Value between 0.0 and 1.0
                                    onVolumeChanged: (newVolume) {
                                      musicBloc.volume = newVolume;
                                    },
                                    size: 150, // Adjust size as needed
                                  ),
                                  const Text(
                                    'Base Volume Level',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
