import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

class PlayingControlsSmall extends StatelessWidget {
  final bool isPlaying;
  final LoopMode loopMode;
  final Function() onPlay;
  final Function()? onStop;
  final Function()? toggleLoop;

  const PlayingControlsSmall({
    super.key,
    required this.isPlaying,
    required this.loopMode,
    this.toggleLoop,
    required this.onPlay,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: loopMode == LoopMode.playlist ? 'Loop enabled' : 'Loop off',
          isSelected: loopMode == LoopMode.playlist,
          onPressed: toggleLoop,
          icon: const Icon(Icons.repeat),
          selectedIcon: const Icon(Icons.repeat_on),
        ),
        IconButton.filled(
          tooltip: isPlaying ? 'Pause' : 'Play',
          onPressed: onPlay,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        if (onStop != null)
          IconButton.filledTonal(
            tooltip: 'Stop',
            onPressed: onStop,
            icon: const Icon(Icons.stop),
          ),
      ],
    );
  }
}
