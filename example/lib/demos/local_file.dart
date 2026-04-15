import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import 'local_file_io.dart'
    if (dart.library.js_interop) 'local_file_web.dart';

const mp3Url =
    'https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _localPath;
  String? _progress;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _progress = '0%';
      _error = null;
    });
    try {
      final path = await downloadToLocal(
        url: mp3Url,
        fileName: 'example_download.mp3',
        onProgress: (r, t) {
          if (!mounted || t <= 0) return;
          setState(() {
            _progress = '${(r / t * 100).toStringAsFixed(0)}%';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _localPath = path;
        _progress = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _progress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Local file',
      description: kIsWeb
          ? 'Downloads an MP3 to an in-memory blob URL, then opens it with Audio.file. The web has no real file system, so a blob URL stands in for a local path.'
          : 'Downloads an MP3 via Dio to a temp directory, then opens it with Audio.file for local playback.',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!),
                  ),
                ),
              if (_localPath == null && _progress == null)
                FilledButton.icon(
                  onPressed: _download,
                  icon: const Icon(Icons.file_download),
                  label: Text(kIsWeb
                      ? 'Download MP3 to memory'
                      : 'Download MP3 to device'),
                )
              else if (_progress != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text('Downloading $_progress'),
                  ],
                )
              else if (_localPath != null)
                _Player(_localPath!),
            ],
          ),
        ),
      ),
    );
  }
}

class _Player extends StatefulWidget {
  final String localPath;

  const _Player(this.localPath);

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();

  @override
  void initState() {
    super.initState();
    _player.open(
      // On web, blob URLs are http-like; use Audio.network so the web player
      // loads them as a URL. On native, Audio.file wraps a real file path.
      kIsWeb
          ? Audio.network(widget.localPath,
              metas: Metas(title: 'Downloaded MP3'))
          : Audio.file(widget.localPath,
              metas: Metas(title: 'Downloaded MP3')),
      autoStart: false,
      showNotification: true,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Path: ${widget.localPath}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        PlayerBuilder.isPlaying(
          player: _player,
          builder: (context, isPlaying) {
            return FilledButton.icon(
              onPressed: () => _player.playOrPause(),
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? 'Pause' : 'Play local file'),
            );
          },
        ),
      ],
    );
  }
}
