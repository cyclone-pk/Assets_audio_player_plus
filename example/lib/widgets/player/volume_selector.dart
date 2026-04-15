import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

class VolumeSelector extends StatelessWidget {
  final double volume;
  final Function(double) onChange;

  const VolumeSelector({
    super.key,
    required this.volume,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume',
              style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Icon(Icons.volume_down),
              Expanded(
                child: Slider(
                  min: AssetsAudioPlayer.minVolume,
                  max: AssetsAudioPlayer.maxVolume,
                  value: volume.clamp(
                      AssetsAudioPlayer.minVolume, AssetsAudioPlayer.maxVolume),
                  label: (volume * 100).toStringAsFixed(0) + '%',
                  divisions: 20,
                  onChanged: onChange,
                ),
              ),
              const Icon(Icons.volume_up),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text('${(volume * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
