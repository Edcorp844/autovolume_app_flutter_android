
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/screens/song_play_screen.dart';

class SongSearchScreen extends StatefulWidget {
  final List<Song> audioFiles;

  const SongSearchScreen({super.key, required this.audioFiles});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  List<Song> searchedSongs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      searchedSongs =
          widget.audioFiles
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query) ||
                    song.artist.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Songs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(CupertinoIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                searchedSongs.isEmpty
                    ? const Center(child: Text("No results found"))
                    : ListView.builder(
                      itemCount: searchedSongs.length,
                      itemBuilder: (context, index) {
                        final song = searchedSongs[index];
                        return ListTile(
                          title: Text(song.title),
                          subtitle: Text(song.artist),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayingScreen(song: song),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
