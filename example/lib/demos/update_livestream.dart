import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audio = Audio.liveStream(
    // SomaFM Groove Salad — public HTTPS MP3 stream (works on web).
    'https://ice1.somafm.com/groovesalad-128-mp3',
    metas: Metas(
      title: 'Groove Salad',
      artist: 'SomaFM',
      album: 'Live stream',
      image: MetasImage.network(
          'https://somafm.com/img3/groovesalad400.jpg'),
    ),
  );

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
    _assetsAudioPlayer.open(audio,
        autoStart: false, showNotification: true);
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DemoScaffold(
      title: 'Update live stream metas',
      description:
          'Opens a live stream, then updates its title/artist at runtime via audio.updateMetas(). The player.current stream reflects the change immediately.',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<Playing?>(
                  stream: _assetsAudioPlayer.current,
                  builder: (context, snapshot) {
                    final metas = snapshot.data?.audio.audio.metas;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current metadata',
                            style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary)),
                        const SizedBox(height: 8),
                        _Row(
                            label: 'Title',
                            value: metas?.title ?? '—'),
                        _Row(
                            label: 'Artist',
                            value: metas?.artist ?? '—'),
                        _Row(
                            label: 'Album',
                            value: metas?.album ?? '—'),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            PlayerBuilder.isPlaying(
              player: _assetsAudioPlayer,
              builder: (context, isPlaying) => FilledButton.tonalIcon(
                onPressed: () => _assetsAudioPlayer.playOrPause(),
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? 'Pause stream' : 'Play stream'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                setState(() => _updateCount++);
                audio.updateMetas(
                  title: 'Groove Salad — update $_updateCount',
                  artist: 'Live host ${_updateCount * 2}',
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update title and artist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 72,
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall)),
          Expanded(
              child: Text(value,
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
