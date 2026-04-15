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
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();

  final Playlist playlist = Playlist(audios: [
    Audio.network(mp3Url, metas: Metas(title: 'Streaming from network')),
  ]);

  final List<String> _log = [];
  String? _localPath;
  double? _downloadProgress;
  bool _replaced = false;

  @override
  void initState() {
    super.initState();
    _addLog('1. Opened playlist with Audio.network (source: network)');
    _player.open(playlist, autoStart: true, showNotification: true);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      _log.add(msg);
    });
  }

  Future<void> _downloadLocal() async {
    if (_localPath != null) return;
    _addLog('2. Downloading the same MP3 in parallel...');
    setState(() => _downloadProgress = 0);
    try {
      final path = await downloadToLocal(
        url: mp3Url,
        fileName: 'swap_me.mp3',
        onProgress: (r, t) {
          if (!mounted || t <= 0) return;
          setState(() => _downloadProgress = r / t);
        },
      );
      if (!mounted) return;
      setState(() {
        _localPath = path;
        _downloadProgress = null;
      });
      _addLog('3. Download complete — ready to swap');
    } catch (e) {
      _addLog('Download failed: $e');
    }
  }

  void _swapToLocal() {
    if (_localPath == null || _replaced) return;
    final beforePos = _player.currentPosition.valueOrNull;
    playlist.replaceAt(
      0,
      (oldAudio) => kIsWeb
          ? Audio.network(_localPath!,
              metas: Metas(title: 'Playing from local blob URL'))
          : oldAudio.copyWith(
              audioType: AudioType.file, path: _localPath!),
      keepPlayingPositionIfCurrent: true,
    );
    setState(() => _replaced = true);
    _addLog(
        '4. Called playlist.replaceAt(0, ...) with keepPlayingPositionIfCurrent: true');
    _addLog('   Position before swap: ${_fmt(beforePos)}');
    _addLog(
        '   Playback continues uninterrupted — now sourced from ${kIsWeb ? 'blob URL' : 'local file'}');
  }

  static String _fmt(Duration? d) {
    if (d == null) return '—';
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DemoScaffold(
      title: 'Update playlist (replace source)',
      description:
          'Starts playing a network MP3. You download the same file in parallel, then swap the playlist entry to the local copy with keepPlayingPositionIfCurrent — playback continues seamlessly.',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Source card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current source',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _replaced
                              ? (kIsWeb
                                  ? Icons.memory
                                  : Icons.folder)
                              : Icons.cloud,
                          color: _replaced
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _replaced
                                ? (kIsWeb
                                    ? 'Local blob URL (swapped)'
                                    : 'Local file (swapped)')
                                : 'Network stream',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<RealtimePlayingInfos>(
                      stream: _player.realtimePlayingInfos,
                      builder: (context, snapshot) {
                        final infos = snapshot.data;
                        final pos = infos?.currentPosition ?? Duration.zero;
                        final dur = infos?.duration ?? Duration.zero;
                        final val = dur.inMilliseconds == 0
                            ? 0.0
                            : (pos.inMilliseconds / dur.inMilliseconds)
                                .clamp(0.0, 1.0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: val),
                            const SizedBox(height: 4),
                            Text('${_fmt(pos)} / ${_fmt(dur)}',
                                style: theme.textTheme.bodySmall),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    PlayerBuilder.isPlaying(
                      player: _player,
                      builder: (context, isPlaying) => Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _player.playOrPause(),
                          icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isPlaying ? 'Pause' : 'Play'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            FilledButton.icon(
              onPressed:
                  (_downloadProgress != null || _localPath != null)
                      ? null
                      : _downloadLocal,
              icon: _downloadProgress != null
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download),
              label: Text(
                _localPath != null
                    ? 'Downloaded'
                    : _downloadProgress != null
                        ? 'Downloading... ${(_downloadProgress! * 100).toStringAsFixed(0)}%'
                        : 'Step 1 — Download same MP3 locally',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: (_localPath != null && !_replaced)
                  ? _swapToLocal
                  : null,
              icon: const Icon(Icons.swap_horiz),
              label: Text(_replaced
                  ? 'Swapped'
                  : 'Step 2 — Swap network → local (replaceAt)'),
            ),
            const SizedBox(height: 16),

            // Event log
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event log',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    if (_log.isEmpty)
                      Text('—',
                          style: theme.textTheme.bodySmall)
                    else
                      for (final line in _log)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2),
                          child: Text(line,
                              style: theme.textTheme.bodyMedium),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
