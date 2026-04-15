import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import '../widgets/player/playing_controls.dart';
import '../widgets/player/position_seek_widget.dart';
import '../widgets/player/songs_selector.dart';

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

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
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
    // Open the playlist paused so the cover + transport controls are visible
    // immediately — the user just taps play.
    _assetsAudioPlayer.open(
      Playlist(audios: audios),
      autoStart: false,
      showNotification: true,
    );
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
      title: 'PlayerBuilder helpers',
      description:
          'Uses player.builderCurrent / builderLoopMode / builderRealtimePlayingInfos and PlayerBuilder.isPlaying instead of raw streams.',
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
            _assetsAudioPlayer.builderCurrent(
              builder: (context, Playing? playing) {
                final colors = Theme.of(context).colorScheme;
                Widget placeholder({String? hint}) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.music_note,
                                size: 64, color: colors.onSecondaryContainer),
                          ),
                          if (hint != null) ...[
                            const SizedBox(height: 12),
                            Text(hint,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ],
                      ),
                    );
                if (playing == null) {
                  return placeholder(hint: 'Select a song below to start');
                }
                final myAudio = find(audios, playing.audio.assetAudioPath);
                final image = myAudio.metas.image;
                if (image == null) return placeholder();
                final errorBuilder =
                    (BuildContext _, Object __, StackTrace? ___) =>
                        placeholder();
                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: image.type == ImageType.network
                        ? Image.network(image.path,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: errorBuilder)
                        : Image.asset(image.path,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: errorBuilder),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _assetsAudioPlayer.builderCurrent(
              builder: (context, Playing? playing) {
                if (playing == null) return const SizedBox();
                return Column(
                  children: [
                    _assetsAudioPlayer.builderLoopMode(
                      builder: (context, loopMode) {
                        return PlayerBuilder.isPlaying(
                          player: _assetsAudioPlayer,
                          builder: (context, isPlaying) {
                            return PlayingControls(
                              loopMode: loopMode,
                              isPlaying: isPlaying,
                              isPlaylist: true,
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
                    _assetsAudioPlayer.builderRealtimePlayingInfos(
                      builder: (context, RealtimePlayingInfos? infos) {
                        if (infos == null) return const SizedBox();
                        return Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: infos.currentPosition,
                              duration: infos.duration,
                              seekTo: (to) => _assetsAudioPlayer.seek(to),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed: () => _assetsAudioPlayer
                                        .seekBy(const Duration(seconds: -10)),
                                    icon: const Icon(Icons.replay_10),
                                    label: const Text('Back 10s'),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _assetsAudioPlayer
                                        .seekBy(const Duration(seconds: 10)),
                                    icon: const Icon(Icons.forward_10),
                                    label: const Text('Forward 10s'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            _assetsAudioPlayer.builderCurrent(
              builder: (context, Playing? playing) {
                return SongsSelector(
                  audios: audios,
                  onPlaylistSelected: (myAudios) {
                    _assetsAudioPlayer.open(
                      Playlist(audios: myAudios),
                      showNotification: true,
                    );
                  },
                  onSelected: (myAudio) {
                    _assetsAudioPlayer.open(
                      myAudio,
                      autoStart: true,
                      respectSilentMode: true,
                      showNotification: true,
                    );
                  },
                  playing: playing,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
