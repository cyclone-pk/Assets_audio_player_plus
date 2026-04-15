import 'dart:async';

import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';
import '../widgets/player/playing_controls.dart';
import '../widgets/player/position_seek_widget.dart';
import '../widgets/player/songs_selector.dart';

class SimplePlaylistDemo extends StatefulWidget {
  const SimplePlaylistDemo({super.key});

  @override
  State<SimplePlaylistDemo> createState() => _SimplePlaylistDemoState();
}

class _SimplePlaylistDemoState extends State<SimplePlaylistDemo> {
  late AssetsAudioPlayer _assetsAudioPlayer;
  final List<StreamSubscription> _subscriptions = [];

  final audios = <Audio>[
    Audio.network(
      'https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3',
      metas: Metas(
        id: 'Online',
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
        id: 'Rock',
        title: 'Rock',
        artist: 'Florent Champigny',
        album: 'RockAlbum',
        image: MetasImage.network(
            'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
      ),
    ),
    Audio(
      'assets/audios/country2.mp3',
      metas: Metas(
        id: 'Country',
        title: 'Country',
        artist: 'Florent Champigny',
        album: 'CountryAlbum',
        image: MetasImage.asset('assets/images/country.jpg'),
      ),
    ),
    Audio(
      'assets/audios/electronic.mp3',
      metas: Metas(
        id: 'Electronics',
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
        id: 'Hiphop',
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
        id: 'Pop',
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
        id: 'Instrumental',
        title: 'Instrumental',
        artist: 'Florent Champigny',
        album: 'InstrumentalAlbum',
        image: MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
  ];

  String? _openError;

  @override
  void initState() {
    super.initState();
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      debugPrint('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      debugPrint('audioSessionId : $sessionId');
    }));
    _openPlayer();
  }

  Future<void> _openPlayer() async {
    debugPrint('simple_playlist: calling open()...');
    try {
      await _assetsAudioPlayer.open(
        Playlist(audios: audios, startIndex: 0),
        showNotification: false,
        autoStart: false,
      );
      debugPrint('simple_playlist: open() returned successfully');
    } catch (e, st) {
      debugPrint('simple_playlist open() failed: $e\n$st');
      if (mounted) setState(() => _openError = '$e');
    }
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  Audio _find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  Widget _coverPlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 160,
      width: 160,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.music_note,
          size: 72, color: colors.onSecondaryContainer),
    );
  }

  Widget _cover() {
    return StreamBuilder<Playing?>(
      stream: _assetsAudioPlayer.current,
      builder: (context, playing) {
        if (playing.data == null) {
          return Center(child: _coverPlaceholder(context));
        }
        final myAudio = _find(audios, playing.data!.audio.assetAudioPath);
        final image = myAudio.metas.image;
        final errorBuilder =
            (BuildContext ctx, Object _, StackTrace? __) =>
                _coverPlaceholder(ctx);
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image == null
                ? _coverPlaceholder(context)
                : image.type == ImageType.network
                    ? Image.network(image.path,
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: errorBuilder)
                    : Image.asset(image.path,
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: errorBuilder),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Playlist player',
      description:
          'Demonstrates opening a playlist and controlling play/pause, skip, loop, seek, and per-track selection.',
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
            if (_openError != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Player failed to open:\n$_openError',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _cover(),
            const SizedBox(height: 16),
            // Transport controls: rendered unconditionally. Streams fall back
            // to sensible defaults before the first emission so the UI doesn't
            // disappear while the first track loads on Android.
            StreamBuilder<LoopMode>(
              stream: _assetsAudioPlayer.loopMode,
              initialData: LoopMode.none,
              builder: (context, loopSnap) {
                final loopMode = loopSnap.data ?? LoopMode.none;
                return StreamBuilder<bool>(
                  stream: _assetsAudioPlayer.isPlaying,
                  initialData: false,
                  builder: (context, playingSnap) {
                    final isPlaying = playingSnap.data ?? false;
                    return PlayingControls(
                      loopMode: loopMode,
                      isPlaying: isPlaying,
                      isPlaylist: true,
                      onStop: () => _assetsAudioPlayer.stop(),
                      toggleLoop: () => _assetsAudioPlayer.toggleLoop(),
                      onPlay: () => _assetsAudioPlayer.playOrPause(),
                      onNext: () =>
                          _assetsAudioPlayer.next(keepLoopMode: true),
                      onPrevious: () => _assetsAudioPlayer.previous(),
                    );
                  },
                );
              },
            ),
            _assetsAudioPlayer.builderCurrent(
              builder: (context, Playing? playing) {
                return Column(
                  children: [
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
            const SizedBox(height: 8),
            StreamBuilder<Playing?>(
              stream: _assetsAudioPlayer.current,
              builder: (context, snapshot) {
                return SongsSelector(
                  audios: audios,
                  onPlaylistSelected: (myAudios) async {
                    try {
                      await _assetsAudioPlayer.open(
                        Playlist(audios: myAudios),
                        autoStart: true,
                        showNotification: true,
                        headPhoneStrategy:
                            HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
                        audioFocusStrategy: AudioFocusStrategy.request(
                            resumeAfterInterruption: true),
                      );
                    } catch (e, st) {
                      debugPrint('playlist open(playlist) failed: $e\n$st');
                    }
                  },
                  onSelected: (myAudio) async {
                    debugPrint(
                        'playlist: opening ${myAudio.path} (${myAudio.audioType})');
                    try {
                      await _assetsAudioPlayer.open(
                        myAudio,
                        autoStart: true,
                        showNotification: true,
                        playInBackground: PlayInBackground.enabled,
                        audioFocusStrategy: AudioFocusStrategy.request(
                            resumeAfterInterruption: true,
                            resumeOthersPlayersAfterDone: true),
                        headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
                        notificationSettings: NotificationSettings(),
                      );
                    } catch (e, st) {
                      debugPrint('playlist open(audio) failed: $e\n$st');
                    }
                  },
                  playing: snapshot.data,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
