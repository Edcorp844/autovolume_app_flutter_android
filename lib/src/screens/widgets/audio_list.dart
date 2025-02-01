import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/extensions/build_context_extension.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/screens/song_play_screen.dart';

class AudioList extends StatelessWidget {
  final List<Song> audioFiles;

  const AudioList({required this.audioFiles, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
        backgroundColor: context.backgroundColor!,
        children: [
          for (Song song in audioFiles)
            CupertinoListTile.notched(
              backgroundColor: context.backgroundColor,
              title: Text(
                song.title,
                style: TextStyle(color: context.textColor),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayingScreen(song: song),
                  ),
                );
              },
            )
        ]);
  }
}
