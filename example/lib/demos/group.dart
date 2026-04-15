import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import '../widgets/player/playing_controls.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audios = <Audio>[
    Audio.network(
      'https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3',
      metas: Metas(
        title: 'Online',
        artist: 'Florent Champigny',
        album: 'OnlineAlbum',
      ),
    ),
    Audio(
      'assets/audios/rock.mp3',
      metas: Metas(title: 'Rock', artist: 'Florent Champigny'),
    ),
    Audio(
      'assets/audios/country.mp3',
      metas: Metas(title: 'Country', artist: 'Florent Champigny'),
    ),
    Audio(
      'assets/audios/electronic.mp3',
      metas: Metas(title: 'Electronic', artist: 'Florent Champigny'),
    ),
  ];

  final AssetsAudioPlayerGroup _assetsAudioPlayerGroup =
      AssetsAudioPlayerGroup(updateNotification: (player, playing) async {
    return PlayerGroupMetas(
      title: 'title',
      subTitle: 'subtitle ${playing.length}',
      image: MetasImage.asset('assets/images/country.jpg'),
    );
  });

  @override
  void initState() {
    _assetsAudioPlayerGroup.addAll(audios);
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayerGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Player group',
      description:
          'Combines several audios under a single AssetsAudioPlayerGroup. Play/pause controls the entire group.',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${audios.length} audios in group',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _assetsAudioPlayerGroup.builderIsPlaying(
                builder: (context, bool? isPlaying) {
                  if (isPlaying == null) return const SizedBox();
                  return PlayingControls(
                    isPlaying: isPlaying,
                    isPlaylist: true,
                    onPlay: () => _assetsAudioPlayerGroup.playOrPause(),
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
