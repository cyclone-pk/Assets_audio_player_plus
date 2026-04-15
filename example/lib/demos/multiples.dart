import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import '../widgets/player/model/my_audio.dart';
import '../widgets/player/playing_controls_small.dart';
import '../widgets/player/position_seek_widget.dart';

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
  // Reliable public MP3 for the "Online" entry.
  static const _onlineMp3 =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  late final List<MyAudio> audios = <MyAudio>[
    MyAudio(name: 'Online', audio: Audio.network(_onlineMp3), imageUrl: ''),
    MyAudio(
        name: 'Rock', audio: Audio('assets/audios/rock.mp3'), imageUrl: ''),
    MyAudio(
        name: 'Country',
        audio: Audio('assets/audios/country.mp3'),
        imageUrl: ''),
    MyAudio(
        name: 'Electronic',
        audio: Audio('assets/audios/electronic.mp3'),
        imageUrl: ''),
    MyAudio(
        name: 'HipHop',
        audio: Audio('assets/audios/hiphop.mp3'),
        imageUrl: ''),
    MyAudio(name: 'Pop', audio: Audio('assets/audios/pop.mp3'), imageUrl: ''),
    MyAudio(
        name: 'Instrumental',
        audio: Audio('assets/audios/instrumental.mp3'),
        imageUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Multiple players',
      description:
          'Each row has its own AssetsAudioPlayer.newPlayer() instance so they play independently.',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: audios.map((e) => PlayerWidget(myAudio: e)).toList(),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final MyAudio myAudio;

  const PlayerWidget({super.key, required this.myAudio});

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoopMode>(
      stream: _assetsAudioPlayer.loopMode,
      initialData: LoopMode.none,
      builder: (context, snapshotLooping) {
        final loopMode = snapshotLooping.data ?? LoopMode.none;
        return StreamBuilder<bool>(
          stream: _assetsAudioPlayer.isPlaying,
          initialData: false,
          builder: (context, snapshotPlaying) {
            final isPlaying = snapshotPlaying.data ?? false;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _GradientCover(name: widget.myAudio.name),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.myAudio.name,
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        PlayingControlsSmall(
                          loopMode: loopMode,
                          isPlaying: isPlaying,
                          toggleLoop: () =>
                              _assetsAudioPlayer.toggleLoop(),
                          onPlay: () {
                            if (_assetsAudioPlayer.current.valueOrNull ==
                                null) {
                              _assetsAudioPlayer.open(widget.myAudio.audio,
                                  autoStart: true);
                            } else {
                              _assetsAudioPlayer.playOrPause();
                            }
                          },
                        ),
                      ],
                    ),
                    StreamBuilder<RealtimePlayingInfos>(
                      stream: _assetsAudioPlayer.realtimePlayingInfos,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final infos = snapshot.data!;
                        return PositionSeekWidget(
                          seekTo: (to) => _assetsAudioPlayer.seek(to),
                          duration: infos.duration,
                          currentPosition: infos.currentPosition,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GradientCover extends StatelessWidget {
  final String name;
  const _GradientCover({required this.name});

  // Deterministic colour per track name — no network, no SSL, always renders.
  List<Color> _palette(String name) {
    final palettes = [
      [const Color(0xFF7C4DFF), const Color(0xFF00B0FF)],
      [const Color(0xFFFF4081), const Color(0xFFFFAB40)],
      [const Color(0xFF00BFA5), const Color(0xFF64DD17)],
      [const Color(0xFFFFC107), const Color(0xFFFF5722)],
      [const Color(0xFF3F51B5), const Color(0xFF9C27B0)],
      [const Color(0xFF009688), const Color(0xFF4CAF50)],
      [const Color(0xFFE91E63), const Color(0xFF673AB7)],
    ];
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return palettes[hash % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _palette(name);
    final letter = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
