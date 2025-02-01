import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/bloc/states/music_state.dart';
import 'package:myapp/src/extensions/build_context_extension.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/screens/widgets/audio_list.dart';

class MusicTab extends StatefulWidget {
  const MusicTab({super.key});

  @override
  State<MusicTab> createState() => _MusicTabState();
}

class _MusicTabState extends State<MusicTab>
    with AutomaticKeepAliveClientMixin {
  bool _isMusicFetched = false; // Ensure fetch happens only once
  List<Song> audioFiles = [];

  @override
  bool get wantKeepAlive => true; // Keep the tab alive

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            centerTitle: true,
            stretch: true,
            title: Text(
              'Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50), // Corrected usage
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0), // Optional padding
                child: searchButton(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<StorageBloc, SongLoadState>(
                buildWhen: (context, state) => _isMusicFetched == false,
                builder: (context, state) {
                  return buildSongList(state);
                }),
          ),
        ],
      ),
    );
  }

  Widget buildSongList(SongLoadState state) {
    if (state is MusicLoaded) {
      _isMusicFetched = true;
      audioFiles = state.audioFiles;
      print(audioFiles);
      return AudioList(audioFiles: state.audioFiles);
    } else if (state is MusicLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    } else if (state is SongLoadError) {
      debugPrint(state.message);
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else {
      return const Center(child: Text('No Songs Found'));
    }
  }

  Widget searchButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SongSearchScreen(audioFiles: audioFiles)));
      },
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
            color: context.isDark
                ? const Color.fromARGB(153, 60, 60, 67)
                : const Color.fromARGB(173, 235, 235, 245),
            borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Icon(CupertinoIcons.search, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            'Search',
            style: TextStyle(color: Colors.grey),
          ),
          Spacer()
        ]),
      ),
    );
  }
}

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
      searchedSongs = widget.audioFiles
          .where((song) =>
              song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query))
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: searchedSongs.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.builder(
                    itemCount: searchedSongs.length,
                    itemBuilder: (context, index) {
                      final song = searchedSongs[index];
                      return ListTile(
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
