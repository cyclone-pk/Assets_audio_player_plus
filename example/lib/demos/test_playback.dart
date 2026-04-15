import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../utils/string_duration.dart';
import '../widgets/demo_scaffold.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: const Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _player = AssetsAudioPlayer.newPlayer();
  final Audio _audio =
      Audio('assets/audios/water.mp3', metas: Metas(title: 'Water loop'));

  int _audioFinishedCount = 0;
  int _playlistFinishedCount = 0;
  String? _lastEvent;
  bool _loaded = false;

  StreamSubscription? _audioFinishedSub;
  StreamSubscription? _playlistFinishedSub;

  @override
  void initState() {
    super.initState();
    _audioFinishedSub =
        _player.playlistAudioFinished.listen((Playing playing) {
      if (!mounted) return;
      setState(() {
        _audioFinishedCount++;
        _lastEvent =
            'playlistAudioFinished → ${playing.audio.audio.metas.title ?? '...'}';
      });
    });
    _playlistFinishedSub = _player.playlistFinished.listen((finished) {
      if (!mounted || !finished) return;
      setState(() {
        _playlistFinishedCount++;
        _lastEvent = 'playlistFinished → true';
      });
    });
  }

  @override
  void dispose() {
    _audioFinishedSub?.cancel();
    _playlistFinishedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    await _player.open(
      _audio,
      showNotification: true,
      notificationSettings:
          const NotificationSettings(prevEnabled: false),
      loopMode: LoopMode.single,
      autoStart: false,
    );
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  void _reset() {
    setState(() {
      _audioFinishedCount = 0;
      _playlistFinishedCount = 0;
      _lastEvent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DemoScaffold(
      title: 'Finish-event counters',
      description:
          'Plays a short asset in LoopMode.single and tallies how many times the player fires playlistAudioFinished vs playlistFinished — useful for validating loop behavior.',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.secondaryContainer,
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.water_drop,
                              color: theme.colorScheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Water loop',
                                  style: theme.textTheme.titleMedium),
                              Text('LoopMode.single (replays forever)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: val),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(pos.mmSSFormat,
                                    style: theme.textTheme.bodySmall),
                                Text(dur.mmSSFormat,
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Counter cards
            Row(
              children: [
                Expanded(
                    child: _CounterCard(
                        label: 'playlistAudioFinished',
                        count: _audioFinishedCount,
                        color: theme.colorScheme.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _CounterCard(
                        label: 'playlistFinished',
                        count: _playlistFinishedCount,
                        color: theme.colorScheme.tertiary)),
              ],
            ),
            const SizedBox(height: 8),
            if (_lastEvent != null)
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_lastEvent!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace')),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Controls
            if (!_loaded)
              FilledButton.icon(
                onPressed: _loadAudio,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Load audio'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: PlayerBuilder.isPlaying(
                      player: _player,
                      builder: (context, isPlaying) => FilledButton.icon(
                        onPressed: () => isPlaying
                            ? _player.pause()
                            : _player.play(),
                        icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(isPlaying ? 'Pause' : 'Play'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PlayerBuilder.loopMode(
                      player: _player,
                      builder: (context, loopMode) {
                        final looping = loopMode != LoopMode.none;
                        return FilledButton.tonalIcon(
                          onPressed: () => _player.setLoopMode(
                            looping ? LoopMode.none : LoopMode.single,
                          ),
                          icon: Icon(looping
                              ? Icons.repeat_one_on
                              : Icons.repeat_one),
                          label: Text(looping
                              ? 'Loop: single'
                              : 'Loop: none'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset counters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CounterCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Text('$count',
                style: theme.textTheme.displayMedium?.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            Text(count == 1 ? 'event' : 'events',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
