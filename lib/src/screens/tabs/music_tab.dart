import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/screens/song_play_screen.dart';

class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            centerTitle: true,
            stretch: true,
            title: Text(
              'Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<MusicBloc, MusicState>(
              builder: (context, state) {
                if (state is MusicLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else if (state is MusicError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is MusicLoaded) {
                  final audioFiles = state.audioFiles;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < audioFiles.length; i++)
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlayingScreen(song: audioFiles[i]),
                                  ),
                                );
                              },
                              title:
                                  Text(audioFiles[i]["path"].split('/').last),
                              trailing: const Icon(Icons.play_circle),
                              style: ListTileStyle.list,
                            ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
