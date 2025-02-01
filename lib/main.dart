import 'package:flutter/material.dart' hide TabController;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/bloc/events/music_event.dart';
import 'package:myapp/src/bloc/music_bloc.dart';
import 'package:myapp/src/model/song_model.dart';
import 'package:myapp/src/screens/tab_controller.dart';
import 'package:myapp/src/services/storage_service.dart';

List<Song> globalAudioFiles = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StorageBloc(StorageService())..add(FetchMusic()),
        ),
        BlocProvider(
          create: (context) => MusicBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const TabController(),
      ),
    );
  }
}
