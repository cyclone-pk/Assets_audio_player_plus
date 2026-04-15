import 'dart:async';
import 'dart:convert';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/demo_scaffold.dart';

// Public HTTPS MP3 stream (SomaFM Groove Salad). HTTP URLs are blocked by
// browsers on HTTPS pages, so live streams must be HTTPS for web builds.
const streamUrl = 'https://ice1.somafm.com/groovesalad-128-mp3';
const nowPlayingUrl = 'https://somafm.com/songs/groovesalad.json';
const stationName = 'Groove Salad';
const stationArtist = 'SomaFM';
const stationAlbum = 'Ambient / downtempo radio';
const stationImage = 'https://somafm.com/img3/groovesalad400.jpg';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScaffold(
      title: 'Live stream',
      description:
          'Plays a public HTTPS MP3 radio stream via Audio.liveStream, shows station metadata, and polls SomaFM for the currently-playing track every 20 s.',
      body: _Player(),
    );
  }
}

class _NowPlaying {
  final String title;
  final String artist;
  final String? album;
  final String? albumArt;
  _NowPlaying(
      {required this.title,
      required this.artist,
      this.album,
      this.albumArt});
}

class _Player extends StatefulWidget {
  const _Player();

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();
  _NowPlaying? _nowPlaying;
  String? _nowPlayingError;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _init();
    _pollNowPlaying();
    _pollTimer = Timer.periodic(
        const Duration(seconds: 20), (_) => _pollNowPlaying());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _player.onErrorDo = (error) {
        error.player.stop();
      };
      await _player.open(
        Audio.liveStream(
          streamUrl,
          metas: Metas(
            title: stationName,
            album: stationAlbum,
            artist: stationArtist,
            image: MetasImage.network(stationImage),
          ),
        ),
        autoStart: false,
        showNotification: true,
        notificationSettings: const NotificationSettings(
            nextEnabled: false, prevEnabled: false, stopEnabled: false),
      );
    } catch (t) {
      debugPrint('$t');
    }
  }

  Future<void> _pollNowPlaying() async {
    try {
      final r =
          await http.get(Uri.parse(nowPlayingUrl)).timeout(
                const Duration(seconds: 6),
              );
      if (r.statusCode != 200) {
        throw 'HTTP ${r.statusCode}';
      }
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final songs = data['songs'] as List?;
      if (songs == null || songs.isEmpty) {
        throw 'no songs in response';
      }
      final s = songs.first as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _nowPlayingError = null;
        _nowPlaying = _NowPlaying(
          title: (s['title'] ?? '') as String,
          artist: (s['artist'] ?? '') as String,
          album: s['album'] as String?,
          albumArt: s['albumart'] as String?,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _nowPlayingError = 'Now-playing unavailable (CORS?)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Station card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      stationImage,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        width: 100,
                        color: theme.colorScheme.secondaryContainer,
                        child: Icon(Icons.radio,
                            color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stationName, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(stationArtist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary)),
                        const SizedBox(height: 4),
                        Text(stationAlbum,
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        PlayerBuilder.isBuffering(
                          player: _player,
                          builder: (context, buffering) =>
                              PlayerBuilder.isPlaying(
                            player: _player,
                            builder: (context, isPlaying) => Row(
                              children: [
                                Icon(
                                  buffering
                                      ? Icons.hourglass_top
                                      : isPlaying
                                          ? Icons.graphic_eq
                                          : Icons.stop_circle_outlined,
                                  size: 16,
                                  color: isPlaying
                                      ? Colors.green
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  buffering
                                      ? 'Buffering...'
                                      : isPlaying
                                          ? 'Live'
                                          : 'Stopped',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Now-playing card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Now playing',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Refresh now-playing',
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: _pollNowPlaying,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_nowPlaying != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_nowPlaying!.albumArt != null &&
                            _nowPlaying!.albumArt!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _nowPlaying!.albumArt!,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                  height: 60, width: 60),
                            ),
                          )
                        else
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.music_note,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nowPlaying!.title.isEmpty
                                    ? '—'
                                    : _nowPlaying!.title,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                _nowPlaying!.artist.isEmpty
                                    ? '—'
                                    : _nowPlaying!.artist,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant),
                              ),
                              if (_nowPlaying!.album != null &&
                                  _nowPlaying!.album!.isNotEmpty)
                                Text(_nowPlaying!.album!,
                                    style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (_nowPlayingError != null)
                    Text(_nowPlayingError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error))
                  else
                    const Row(
                      children: [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading...'),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text('Polled every 20 s from somafm.com',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Play/pause
          PlayerBuilder.isPlaying(
            player: _player,
            builder: (context, isPlaying) => FilledButton.icon(
              onPressed: () async {
                try {
                  await _player.playOrPause();
                } catch (t) {
                  debugPrint('$t');
                }
              },
              icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 28),
              label: Text(isPlaying ? 'Pause stream' : 'Play stream'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Stream URL: $streamUrl',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
