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
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final rock = Audio(
    'assets/audios/rock.mp3',
    metas: Metas(
      id: 'Rock',
      title: 'Rock',
      artist: 'Florent Champigny',
      image: MetasImage.network(
          'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
    ),
  );

  static final pop = Audio(
    'assets/audios/pop.mp3',
    metas: Metas(
      id: 'Pop',
      title: 'Pop',
      artist: 'Florent Champigny',
      image: MetasImage.network(
          'https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg'),
    ),
  );

  static final electronic = Audio(
    'assets/audios/electronic.mp3',
    metas: Metas(
      id: 'Electronic',
      title: 'Electronic',
      artist: 'Florent Champigny',
    ),
  );

  final playlist = Playlist(audios: [rock, electronic]);
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();

  String? _lastAction;
  // true while we explicitly know a track change is in progress (prev/next
  // /play tap, or insert/replace on the current index).
  bool _pending = false;
  Timer? _pendingTimeout;
  String? _pendingBaseline; // current path when action started
  StreamSubscription? _currentSub;
  StreamSubscription? _playingSub;

  @override
  void initState() {
    super.initState();
    _player.open(playlist, autoStart: false, showNotification: true);
    _currentSub = _player.current.listen((playing) {
      // Clear loader when the current track actually changes from what it
      // was when the action started (covers prev/next/insert/replace).
      if (_pending && mounted && playing?.audio.assetAudioPath != _pendingBaseline) {
        _clearPending();
      }
    });
    _playingSub = _player.isPlaying.listen((isPlaying) {
      // Clear loader when audio starts playing (covers the Play button case
      // where the current track doesn't change).
      if (_pending && mounted && isPlaying) {
        _clearPending();
      }
    });
  }

  @override
  void dispose() {
    _pendingTimeout?.cancel();
    _currentSub?.cancel();
    _playingSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _clearPending() {
    setState(() => _pending = false);
    _pendingTimeout?.cancel();
  }

  void _markPending(String label) {
    setState(() {
      _pending = true;
      _lastAction = label;
      _pendingBaseline = _player.current.valueOrNull?.audio.assetAudioPath;
    });
    _pendingTimeout?.cancel();
    // Hard fallback so we don't get stuck if nothing emits.
    _pendingTimeout = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _pending = false);
    });
  }

  void _runMutation(String label, void Function() op) {
    op();
    // The plugin re-opens the source when we touch the currently-playing
    // entry, so show the loader until it emits a new `current`.
    _markPending(label);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audios = playlist.audios;

    return DemoScaffold(
      title: 'Insert / replace in playlist',
      description:
          'Mutates a live Playlist with Playlist.insert and Playlist.replaceAt. The list updates live, the current track is highlighted, and a loader shows while the plugin re-opens the audio source.',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live playlist with buffering overlay
            StreamBuilder<bool>(
              stream: _player.isBuffering,
              initialData: false,
              builder: (context, buffSnap) {
                final isBuffering = buffSnap.data ?? false;
                final showOverlay = _pending || isBuffering;
                return Stack(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Current playlist',
                                    style: theme.textTheme.labelLarge
                                        ?.copyWith(
                                            color:
                                                theme.colorScheme.primary)),
                                const Spacer(),
                                Text('${audios.length} track(s)',
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<Playing?>(
                              stream: _player.current,
                              builder: (context, snapshot) {
                                final currentPath =
                                    snapshot.data?.audio.assetAudioPath;
                                return Column(
                                  children: [
                                    for (var i = 0; i < audios.length; i++)
                                      _playlistRow(context, i, audios[i],
                                          currentPath),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _seekBar(theme),
                            const SizedBox(height: 8),
                            PlayerBuilder.isPlaying(
                              player: _player,
                              builder: (context, isPlaying) => Row(
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed: _pending
                                        ? null
                                        : () {
                                            if (!isPlaying) {
                                              _markPending('play');
                                            }
                                            _player.playOrPause();
                                          },
                                    icon: Icon(isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    label: Text(
                                        isPlaying ? 'Pause' : 'Play'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: _pending
                                        ? null
                                        : () {
                                            _markPending('previous');
                                            _player.previous();
                                          },
                                    icon: const Icon(Icons.skip_previous),
                                    label: const Text('Prev'),
                                  ),
                                  TextButton.icon(
                                    onPressed: _pending
                                        ? null
                                        : () {
                                            _markPending('next');
                                            _player.next();
                                          },
                                    icon: const Icon(Icons.skip_next),
                                    label: const Text('Next'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showOverlay)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: theme.colorScheme.surface
                                .withValues(alpha: 0.75),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                Text(
                                  isBuffering
                                      ? 'Buffering...'
                                      : 'Loading track...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Last action + busy indicator strip
            SizedBox(
              height: 20,
              child: Row(
                children: [
                  if (_pending) ...[
                    const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      _lastAction == null
                          ? 'Tap an action below'
                          : (_pending
                              ? 'Running: $_lastAction'
                              : 'Done: $_lastAction'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _section(context, 'Insert'),
            _action(
              label: 'Insert Pop at index 0',
              icon: Icons.playlist_add,
              hint:
                  'Adds Pop as the first track. Currently-playing track keeps playing but its index shifts by +1. Click Prev to jump back to Pop.',
              onPressed: () => _runMutation(
                  'insert(0, pop)', () => playlist.insert(0, pop)),
            ),
            _action(
              label: 'Insert Pop at end',
              icon: Icons.playlist_add,
              hint:
                  'Adds Pop as the last track. Doesn\'t interrupt current playback. Click Next to reach it once other tracks finish.',
              onPressed: () => _runMutation(
                  'insert(end, pop)',
                  () => playlist.insert(audios.length, pop)),
            ),
            const SizedBox(height: 12),

            _section(context, 'Replace'),
            _action(
              tonal: true,
              label: 'Replace index 0 with Pop (restart)',
              icon: Icons.swap_horiz,
              hint:
                  'Swaps the track at index 0 with Pop. If that track was playing, it stops and restarts Pop from 0:00.',
              onPressed: () => _runMutation(
                  'replaceAt(0) restart',
                  () => playlist.replaceAt(0, (a) => pop)),
            ),
            _action(
              tonal: true,
              label: 'Replace index 0 with Pop (keep position)',
              icon: Icons.swap_horiz,
              hint:
                  'Same swap, but the new track starts from the same millisecond the old one was at (keepPlayingPositionIfCurrent: true). Useful when you hot-swap the source of the SAME audio, e.g. network → local download.',
              onPressed: () => _runMutation(
                  'replaceAt(0) keep position',
                  () => playlist.replaceAt(0, (a) => pop,
                      keepPlayingPositionIfCurrent: true)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seekBar(ThemeData theme) {
    return StreamBuilder<RealtimePlayingInfos>(
      stream: _player.realtimePlayingInfos,
      builder: (context, snapshot) {
        final infos = snapshot.data;
        final pos = infos?.currentPosition ?? Duration.zero;
        final dur = infos?.duration ?? Duration.zero;
        final maxMs = dur.inMilliseconds == 0
            ? 1.0
            : dur.inMilliseconds.toDouble();
        final posMs =
            pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble();
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                min: 0,
                max: maxMs,
                value: posMs,
                onChanged: dur.inMilliseconds == 0
                    ? null
                    : (v) => _player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pos.mmSSFormat,
                      style: theme.textTheme.bodySmall),
                  Text(dur.mmSSFormat,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _section(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(letterSpacing: 1.2)),
      );

  Widget _action({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback onPressed,
    bool tonal = false,
  }) {
    final btn = tonal
        ? FilledButton.tonalIcon(
            onPressed: _pending ? null : onPressed,
            icon: Icon(icon),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: _pending ? null : onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: double.infinity, child: btn),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Text(hint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _playlistRow(
      BuildContext context, int index, Audio audio, String? currentPath) {
    final theme = Theme.of(context);
    final isCurrent = audio.path == currentPath;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              child: Text('$index',
                  style: TextStyle(
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                audio.metas.title ?? audio.path,
                style: TextStyle(
                  fontWeight:
                      isCurrent ? FontWeight.w600 : FontWeight.normal,
                  color: isCurrent
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isCurrent)
              Icon(Icons.volume_up,
                  size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
