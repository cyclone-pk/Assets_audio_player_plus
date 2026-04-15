import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import '../widgets/player/forward_rewind_selector.dart';
import '../widgets/player/play_speed_selector.dart';
import '../widgets/player/playing_controls.dart';
import '../widgets/player/position_seek_widget.dart';
import '../widgets/player/songs_selector.dart';
import '../widgets/player/volume_selector.dart';

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
        image: MetasImage.network(
            'https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg'),
      ),
    ),
    Audio(
      'assets/audios/rock.mp3',
      metas: Metas(
        title: 'Rock',
        artist: 'Florent Champigny',
        album: 'RockAlbum',
        image: MetasImage.network(
            'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
      ),
    ),
    Audio(
      'assets/audios/country.mp3',
      metas: Metas(
        title: 'Country',
        artist: 'Florent Champigny',
        album: 'CountryAlbum',
        image: MetasImage.asset('assets/images/country.jpg'),
      ),
    ),
    Audio(
      'assets/audios/electronic.mp3',
      metas: Metas(
        title: 'Electronic',
        artist: 'Florent Champigny',
        album: 'ElectronicAlbum',
        image: MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
    Audio(
      'assets/audios/hiphop.mp3',
      metas: Metas(
        title: 'HipHop',
        artist: 'Florent Champigny',
        album: 'HipHopAlbum',
        image: MetasImage.network(
            'https://beyoudancestudio.ch/wp-content/uploads/2019/01/apprendre-danser.hiphop-1.jpg'),
      ),
    ),
    Audio(
      'assets/audios/pop.mp3',
      metas: Metas(
        title: 'Pop',
        artist: 'Florent Champigny',
        album: 'PopAlbum',
        image: MetasImage.network(
            'https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg'),
      ),
    ),
    Audio(
      'assets/audios/instrumental.mp3',
      metas: Metas(
        title: 'Instrumental',
        artist: 'Florent Champigny',
        album: 'InstrumentalAlbum',
        image: MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
  ];

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    _subscriptions.add(_assetsAudioPlayer.playlistFinished.listen((data) {
      debugPrint('finished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      debugPrint('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.current.listen((data) {
      debugPrint('current : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.onReadyToPlay.listen((audio) {
      debugPrint('onRedayToPlay : $audio');
    }));
    super.initState();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Streams API',
      description:
          'Subscribes to raw player Streams (current, loopMode, isPlaying, volume, playSpeed, forwardRewindSpeed) via StreamBuilder.',
      actions: [
        IconButton(
          tooltip: 'Play horn sound effect',
          icon: const Icon(Icons.add_alert),
          onPressed: () {
            AssetsAudioPlayer.playAndForget(Audio('assets/audios/horn.mp3'));
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            StreamBuilder<Playing?>(
              stream: _assetsAudioPlayer.current,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox(height: 160);
                }
                final playing = snapshot.data!;
                final myAudio = find(audios, playing.audio.assetAudioPath);
                final image = myAudio.metas.image;
                if (image == null) return const SizedBox(height: 160);
                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: image.type == ImageType.network
                        ? Image.network(image.path,
                            height: 150, width: 150, fit: BoxFit.cover)
                        : Image.asset(image.path,
                            height: 150, width: 150, fit: BoxFit.cover),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<Playing?>(
              stream: _assetsAudioPlayer.current,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox();
                }
                final playing = snapshot.data!;
                return Column(
                  children: [
                    StreamBuilder<LoopMode>(
                      stream: _assetsAudioPlayer.loopMode,
                      initialData: LoopMode.none,
                      builder: (context, snapshotLooping) {
                        final loopMode = snapshotLooping.data ?? LoopMode.none;
                        return StreamBuilder<bool>(
                          stream: _assetsAudioPlayer.isPlaying,
                          initialData: false,
                          builder: (context, snapshotPlaying) {
                            final isPlaying = snapshotPlaying.data ?? false;
                            return PlayingControls(
                              loopMode: loopMode,
                              isPlaying: isPlaying,
                              isPlaylist:
                                  playing.playlist.audios.length > 1,
                              toggleLoop: () =>
                                  _assetsAudioPlayer.toggleLoop(),
                              onPlay: () =>
                                  _assetsAudioPlayer.playOrPause(),
                              onNext: () => _assetsAudioPlayer.next(),
                              onPrevious: () =>
                                  _assetsAudioPlayer.previous(),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<RealtimePlayingInfos>(
                      stream: _assetsAudioPlayer.realtimePlayingInfos,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final infos = snapshot.data!;
                        return PositionSeekWidget(
                          currentPosition: infos.currentPosition,
                          duration: infos.duration,
                          seekTo: (to) => _assetsAudioPlayer.seek(to),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<Playing?>(
              stream: _assetsAudioPlayer.current,
              builder: (context, snapshot) {
                final playing = snapshot.data;
                return SongsSelector(
                  audios: audios,
                  onPlaylistSelected: (myAudios) async {
                    try {
                      await _assetsAudioPlayer.open(
                        Playlist(audios: myAudios),
                        autoStart: true,
                        showNotification: true,
                      );
                    } catch (e, st) {
                      debugPrint('streams open(playlist) failed: $e\n$st');
                    }
                  },
                  onSelected: (myAudio) async {
                    debugPrint(
                        'streams: opening ${myAudio.path} (${myAudio.audioType})');
                    try {
                      await _assetsAudioPlayer.open(
                        myAudio,
                        autoStart: true,
                        showNotification: true,
                      );
                    } catch (e, st) {
                      debugPrint('streams open(audio) failed: $e\n$st');
                    }
                  },
                  playing: playing,
                );
              },
            ),
            StreamBuilder<double>(
              stream: _assetsAudioPlayer.volume,
              initialData: AssetsAudioPlayer.defaultVolume,
              builder: (context, snapshot) {
                final volume =
                    snapshot.data ?? AssetsAudioPlayer.defaultVolume;
                return VolumeSelector(
                  volume: volume,
                  onChange: (v) => _assetsAudioPlayer.setVolume(v),
                );
              },
            ),
            StreamBuilder<double?>(
              stream: _assetsAudioPlayer.forwardRewindSpeed,
              initialData: null,
              builder: (context, snapshot) {
                final speed = snapshot.data ?? 0.0;
                return ForwardRewindSelector(
                  speed: speed,
                  onChange: (v) => _assetsAudioPlayer.forwardOrRewind(v),
                );
              },
            ),
            StreamBuilder<double>(
              stream: _assetsAudioPlayer.playSpeed,
              initialData: AssetsAudioPlayer.defaultPlaySpeed,
              builder: (context, snapshot) {
                final playSpeed =
                    snapshot.data ?? AssetsAudioPlayer.defaultPlaySpeed;
                return PlaySpeedSelector(
                  playSpeed: playSpeed,
                  onChange: (v) => _assetsAudioPlayer.setPlaySpeed(v),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
