import 'package:flutter/material.dart';
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
        indicatorColor: const Color.fromARGB(104, 187, 222, 251),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.library_music),
            icon: Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            selectedIcon: Badge(child: Icon(Icons.settings)),
            icon: Badge(child: Icon(Icons.settings_outlined)),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.person_outline_rounded),
            ),
            selectedIcon: Badge(
              label: Text('2'),
              child: Icon(Icons.person_rounded),
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        const MusicTab(),
        const SettingsTab(),
        const ProfileTab(),
      ][currentPageIndex],
    );
  }
}
