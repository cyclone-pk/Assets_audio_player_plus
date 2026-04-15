import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

class PlayingControls extends StatelessWidget {
  final bool isPlaying;
  final LoopMode? loopMode;
  final bool isPlaylist;
  final Function()? onPrevious;
  final Function() onPlay;
  final Function()? onNext;
  final Function()? toggleLoop;
  final Function()? onStop;

  const PlayingControls({
    super.key,
    required this.isPlaying,
    this.isPlaylist = false,
    this.loopMode,
    this.toggleLoop,
    this.onPrevious,
    required this.onPlay,
    this.onNext,
    this.onStop,
  });

  String _loopLabel() {
    switch (loopMode) {
      case LoopMode.playlist:
        return 'Loop: Playlist';
      case LoopMode.single:
        return 'Loop: Single';
      case LoopMode.none:
      default:
        return 'Loop: Off';
    }
  }

  IconData _loopIcon() {
    if (loopMode == LoopMode.single) return Icons.repeat_one;
    return Icons.repeat;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            if (toggleLoop != null)
              FilledButton.tonalIcon(
                onPressed: toggleLoop,
                icon: Icon(_loopIcon()),
                label: Text(_loopLabel()),
              ),
            IconButton.filledTonal(
              tooltip: 'Previous',
              onPressed: isPlaylist ? onPrevious : null,
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton.filled(
              tooltip: isPlaying ? 'Pause' : 'Play',
              iconSize: 36,
              onPressed: onPlay,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton.filledTonal(
              tooltip: 'Next',
              onPressed: isPlaylist ? onNext : null,
              icon: const Icon(Icons.skip_next),
            ),
            if (onStop != null)
              IconButton.filledTonal(
                tooltip: 'Stop',
                onPressed: onStop,
                icon: const Icon(Icons.stop),
              ),
          ],
        ),
      ],
    );
  }
}
