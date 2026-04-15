import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      debugPrint('finished : $data');
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      debugPrint('playlistAudioFinished : $data');
    });
    _assetsAudioPlayer.current.listen((data) {
      debugPrint('current : $data');
    });
    _assetsAudioPlayer.onReadyToPlay.listen((audio) {
      debugPrint('onReadyToPlay : $audio');
    });
    _assetsAudioPlayer.open(
      Audio('assets/audios/water.mp3'),
      loopMode: LoopMode.playlist,
    );
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Loop mode',
      description:
          'Opens a single track with LoopMode.playlist and prints the current position from builderCurrentPosition.',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current position',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _assetsAudioPlayer.builderCurrentPosition(
                builder: (BuildContext context, Duration position) {
                  return Text(
                    position.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
