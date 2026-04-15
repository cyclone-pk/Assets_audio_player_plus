import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import 'demos/audio_widget.dart' as demo_audio_widget;
import 'demos/builder.dart' as demo_builder;
import 'demos/cache.dart' as demo_cache;
import 'demos/group.dart' as demo_group;
import 'demos/insert.dart' as demo_insert;
import 'demos/livestream.dart' as demo_livestream;
import 'demos/local_file.dart' as demo_local_file;
import 'demos/loop.dart' as demo_loop;
import 'demos/multiples.dart' as demo_multiples;
import 'demos/simple_playlist.dart';
import 'demos/streams.dart' as demo_streams;
import 'demos/test_playback.dart' as demo_test;
import 'demos/update_livestream.dart' as demo_update_livestream;
import 'demos/update_playlist.dart' as demo_update_playlist;

void main() {
  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    return true;
  });
  runApp(const DemoLauncherApp());
}

class DemoLauncherApp extends StatelessWidget {
  const DemoLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'assets_audio_player demos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const DemoLauncherScreen(),
    );
  }
}

class _Demo {
  final String title;
  final String description;
  final WidgetBuilder builder;
  final IconData icon;

  const _Demo({
    required this.title,
    required this.description,
    required this.builder,
    required this.icon,
  });
}

class DemoLauncherScreen extends StatelessWidget {
  const DemoLauncherScreen({super.key});

  List<_Demo> _demos() => [
        _Demo(
          title: 'Playlist player',
          description:
              'In-memory playlist of 7 tracks (network + assets) with cover art, play/pause, next/previous, seek, loop, and tap-to-play selection.',
          icon: Icons.playlist_play,
          builder: (_) => const SimplePlaylistDemo(),
        ),
        _Demo(
          title: 'Streams API',
          description:
              'Playlist wired with raw StreamBuilder on player.current / isPlaying / loopMode / volume / playSpeed — exposes volume, speed, and forward/rewind controls.',
          icon: Icons.stream,
          builder: (_) => demo_streams.MyApp(),
        ),
        _Demo(
          title: 'PlayerBuilder helpers',
          description:
              'Same playlist as Streams API, but built with player.builderCurrent / builderLoopMode / builderRealtimePlayingInfos and PlayerBuilder.isPlaying.',
          icon: Icons.build_circle_outlined,
          builder: (_) => demo_builder.MyApp(),
        ),
        _Demo(
          title: 'Multiple players',
          description:
              'Several independent AssetsAudioPlayer instances playing side by side.',
          icon: Icons.library_music,
          builder: (_) => demo_multiples.MyApp(),
        ),
        _Demo(
          title: 'Player group',
          description:
              'AssetsAudioPlayerGroup combining several players into a single notification.',
          icon: Icons.group_work,
          builder: (_) => demo_group.MyApp(),
        ),
        _Demo(
          title: 'Loop mode',
          description:
              'Opens a single track with LoopMode.playlist and exposes the current position.',
          icon: Icons.repeat,
          builder: (_) => demo_loop.MyApp(),
        ),
        _Demo(
          title: 'Live stream',
          description:
              'Plays a public HTTPS MP3 radio stream via Audio.liveStream with a buffering indicator.',
          icon: Icons.radio,
          builder: (_) => demo_livestream.MyApp(),
        ),
        _Demo(
          title: 'Update live stream metas',
          description:
              'Shows current title/artist/album in a card and updates them on the fly via audio.updateMetas().',
          icon: Icons.edit_note,
          builder: (_) => demo_update_livestream.MyApp(),
        ),
        _Demo(
          title: 'Cache network audio',
          description:
              'Downloads a network MP3 with a live progress bar (bytes + %), then plays it from the cache (native) or an in-memory blob URL (web).',
          icon: Icons.download_for_offline,
          builder: (_) => demo_cache.MyApp(),
        ),
        _Demo(
          title: 'Local file',
          description:
              'Downloads an MP3 via Dio, then plays it with Audio.file from a temp path (native) or a blob URL (web).',
          icon: Icons.file_download,
          builder: (_) => demo_local_file.MyApp(),
        ),
        _Demo(
          title: 'Swap playlist source live',
          description:
              'Two-step demo of Playlist.replaceAt(keepPlayingPositionIfCurrent: true): starts streaming from network, downloads the same MP3, then swaps to the local copy without interrupting playback.',
          icon: Icons.swap_horiz,
          builder: (_) => demo_update_playlist.MyApp(),
        ),
        _Demo(
          title: 'Insert / replace in playlist',
          description:
              'Insert and replace audios in a live Playlist using Playlist.insert/replaceAt.',
          icon: Icons.playlist_add,
          builder: (_) => demo_insert.MyApp(),
        ),
        _Demo(
          title: 'AudioWidget',
          description:
              'Declarative AudioWidget.assets widget with onPositionChanged callback.',
          icon: Icons.widgets,
          builder: (_) => demo_audio_widget.MyApp(),
        ),
        _Demo(
          title: 'Finish-event counters',
          description:
              'Plays an asset in LoopMode.single and increments counters every time playlistFinished / playlistAudioFinished fires — useful for validating loop callbacks.',
          icon: Icons.science_outlined,
          builder: (_) => demo_test.Home(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final demos = _demos();
    return Scaffold(
      appBar: AppBar(
        title: const Text('assets_audio_player'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            Card(
              color: theme.colorScheme.secondaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo gallery',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Each entry below opens a self-contained screen that tests one feature '
                      'of the assets_audio_player plugin.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...demos.map((demo) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Icon(demo.icon),
                    ),
                    title: Text(
                      demo.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(demo.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: demo.builder),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
