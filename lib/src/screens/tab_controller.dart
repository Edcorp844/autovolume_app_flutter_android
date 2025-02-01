import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/events/music_event.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/extensions/build_context_extension.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/screens/tabs/music_tab.dart';
import 'package:myapp/src/screens/tabs/profile_tab.dart';
import 'package:myapp/src/screens/tabs/settings_tab.dart';

class TabController extends StatefulWidget {
  const TabController({super.key});

  @override
  State<TabController> createState() => _TabControllerState();
}

class _TabControllerState extends State<TabController> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: context.textColor?.withOpacity(0.9) ?? Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.library_music,
              color: context.isDark ? Colors.black : Colors.white,
            ),
            icon: const Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            selectedIcon: Badge(
                child: Icon(
              Icons.settings,
              color: context.isDark ? Colors.black : Colors.white,
            )),
            icon: const Badge(child: Icon(Icons.settings_outlined)),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.person_outline_rounded),
            ),
            selectedIcon: Badge(
              label: const Text('2'),
              child: Icon(
                Icons.person_rounded,
                color: context.isDark ? Colors.black : Colors.white,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          <Widget>[
            const MusicTab(),
            const SettingsTab(),
            const ProfileTab(),
          ][currentPageIndex],
          BlocBuilder<MusicBloc, MusicState>(builder: (context, state) {
            return buildPlayerController(state);
          }),
        ],
      ),
    );
  }

  Widget buildPlayerController(MusicState state) {
    if (state is! MusicStopped) {
      Song currentSong =
          (state is MusicPlaying) ? state.song : (state as MusicPaused).song;

      return Positioned(
        bottom: 0, // Adjust as necessary
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, -3))
          ]),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                color: Colors.black
                    .withOpacity(0.7), // Semi-transparent background
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentSong.title,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: Icon(
                        state is MusicPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        if (state is MusicPlaying) {
                          context.read<MusicBloc>().add(PauseMusic(
                              song: state.song, position: state.position));
                        } else if (state is MusicPaused) {
                          context.read<MusicBloc>().add(ResumeMusic(
                              song: state.song, position: state.position));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
