import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import 'local_file_io.dart'
    if (dart.library.js_interop) 'local_file_web.dart';

const mp3Url =
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

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
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();

  double? _progress;
  int? _downloadedBytes;
  int? _totalBytes;
  String _status = 'Starting...';
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadAndPlay();
  }

  Future<void> _downloadAndPlay() async {
    try {
      setState(() => _status = 'Downloading...');
      final path = await downloadToLocal(
        url: mp3Url,
        fileName: 'cache_demo.mp3',
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() {
            _downloadedBytes = received;
            _totalBytes = total;
            _progress = received / total;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _localPath = path;
        _progress = 1;
        _status = 'Cached — playing from ${kIsWeb ? 'blob URL' : 'local file'}';
      });
      await _player.open(
        kIsWeb
            ? Audio.network(path,
                metas: Metas(title: 'Cached MP3', artist: 'SoundHelix'))
            : Audio.file(path,
                metas: Metas(title: 'Cached MP3', artist: 'SoundHelix')),
        autoStart: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _status = 'Failed';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = _progress == null
        ? null
        : '${(_progress!.clamp(0, 1) * 100).toStringAsFixed(0)}%';
    final bytesLabel = (_downloadedBytes != null && _totalBytes != null)
        ? '${_formatBytes(_downloadedBytes!)} / ${_formatBytes(_totalBytes!)}'
        : null;

    return DemoScaffold(
      title: 'Cache network audio',
      description:
          'Downloads a network MP3 with Dio (live bytes + % progress), writes it to '
          '${kIsWeb ? 'an in-memory blob URL' : 'a local temp file'}, then plays from the cache — so the plugin never streams the same URL twice.',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Download progress',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_status, style: theme.textTheme.bodyMedium),
                          Text(percent ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (bytesLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(bytesLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!,
                            style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_localPath != null)
                PlayerBuilder.current(
                  player: _player,
                  builder: (context, Playing? current) {
                    if (current == null) return const SizedBox();
                    return PlayerBuilder.isPlaying(
                      player: _player,
                      builder: (context, isPlaying) => FilledButton.icon(
                        onPressed: () => _player.playOrPause(),
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(isPlaying ? 'Pause' : 'Play'),
                      ),
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
