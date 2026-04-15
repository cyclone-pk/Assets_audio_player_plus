import 'package:flutter/material.dart';

class PlaySpeedSelector extends StatelessWidget {
  final double playSpeed;
  final Function(double) onChange;

  const PlaySpeedSelector({
    super.key,
    required this.playSpeed,
    required this.onChange,
  });

  static const _speeds = <double>[0.5, 1.0, 2.0, 4.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playback speed',
              style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SegmentedButton<double>(
            segments: _speeds
                .map((s) => ButtonSegment<double>(
                      value: s,
                      label: Text('${s}x'),
                    ))
                .toList(),
            selected: {_speeds.contains(playSpeed) ? playSpeed : 1.0},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) onChange(set.first);
            },
          ),
        ],
      ),
    );
  }
}
