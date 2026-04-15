# assets_audio_player_example

A Material 3 demo app for the `assets_audio_player_plus` plugin. The launcher
screen lists every feature the plugin ships; each entry is a self-contained
demo with a one-line description of what it tests.

## Running the example

```bash
cd example
flutter pub get
flutter run -d chrome     # web (DDC)
flutter run -d <android>  # Android
flutter run -d <iOS>      # iOS
flutter run -d macos      # macOS
```

For a WebAssembly build:

```bash
flutter build web --wasm
```

## Project layout

```
lib/
  main.dart                    # launcher screen — lists every demo
  demos/                       # one file per feature, snake_case
    simple_playlist.dart       # full playlist player (cover, controls, seek)
    streams.dart               # raw StreamBuilder wiring
    builder.dart               # player.builderXxx helpers
    multiples.dart             # several independent players
    group.dart                 # AssetsAudioPlayerGroup
    loop.dart                  # LoopMode.single / playlist
    livestream.dart            # HTTPS live stream + now-playing polling
    update_livestream.dart     # audio.updateMetas() at runtime
    cache.dart                 # cached: true (native) / blob URL (web)
    local_file.dart            # download → Audio.file
    update_playlist.dart       # Playlist.replaceAt with source swap
    insert.dart                # Playlist.insert / replaceAt
    audio_widget.dart          # AudioWidget.assets declarative API
    test_playback.dart         # finish-event counters
  widgets/
    demo_scaffold.dart         # shared AppBar + info banner
    player/                    # shared player controls, seek bar, selectors
  utils/
    string_duration.dart       # Duration → mm:ss
    blob_url_stub.dart         # conditional-import stub
    blob_url_web.dart          # package:web + dart:js_interop blob helper
```

## What each demo shows

| Demo                           | What it exercises                                                                                         |
|--------------------------------|----------------------------------------------------------------------------------------------------------|
| Playlist player                | `AssetsAudioPlayer.newPlayer()`, `open(Playlist)`, `playOrPause()`, `next()`, `previous()`, `seek()`     |
| Streams API                    | Raw `StreamBuilder` on `player.current`, `isPlaying`, `loopMode`, `volume`, `playSpeed`                   |
| PlayerBuilder helpers          | `player.builderCurrent`, `builderLoopMode`, `builderRealtimePlayingInfos`, `PlayerBuilder.isPlaying`     |
| Multiple players               | Several `AssetsAudioPlayer.newPlayer()` instances side-by-side                                           |
| Player group                   | `AssetsAudioPlayerGroup` combining players into one notification                                         |
| Loop mode                      | `LoopMode.playlist` with live position                                                                   |
| Live stream                    | `Audio.liveStream`, buffering indicator, `isBuffering` / `isPlaying`, live now-playing metadata          |
| Update live stream metas       | `audio.updateMetas(title, artist, ...)` — UI reflects the change via `player.current`                    |
| Cache network audio            | `Audio.network(..., cached: true)` with download progress (native); `Dio` + blob URL (web)                |
| Local file                     | Download → `Audio.file` (native) or `Audio.network(blobUrl)` (web)                                        |
| Swap playlist source live      | `Playlist.replaceAt(..., keepPlayingPositionIfCurrent: true)`                                            |
| Insert / replace in playlist   | `Playlist.insert` and `Playlist.replaceAt` with a live-updating list UI                                  |
| AudioWidget                    | Declarative `AudioWidget.assets` — playback driven by `play: bool`                                       |
| Finish-event counters          | `playlistAudioFinished` and `playlistFinished` streams under `LoopMode.single`                           |

## Smallest working snippet

```dart
import 'package:assets_audio_player_plus/assets_audio_player.dart';

final player = AssetsAudioPlayer.newPlayer();

await player.open(
  Audio('assets/audios/rock.mp3',
      metas: Metas(title: 'Rock', artist: 'Florent Champigny')),
  autoStart: true,
  showNotification: true,
);

player.playOrPause();
player.seek(const Duration(seconds: 30));
await player.dispose();
```

See `lib/demos/simple_playlist.dart` for a full-featured playlist player with
cover art, seek, loop, and track selection.

## Web specifics

The web implementation lives in the sibling `assets_audio_player_plus_web/`
package and is wired up automatically via Flutter's federated plugin
resolution. It uses `package:web` + `dart:js_interop` so the example
compiles to both JS and WASM.

File-system-dependent APIs (`Audio.file`, `cached: true`) are stubbed on web
with in-memory blob URLs — see `utils/blob_url_web.dart` and the `cache`
/ `local_file` demos.

## Assets

Sample tracks under `assets/audios/` come from
[freemusicarchive.org](https://www.freemusicarchive.org/). The launcher uses
network cover art from a handful of public hosts as `MetasImage.network`
examples.
