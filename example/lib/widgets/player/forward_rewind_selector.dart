import 'package:flutter/material.dart';

class ForwardRewindSelector extends StatelessWidget {
  final double speed;
  final Function(double) onChange;

  const ForwardRewindSelector({
    super.key,
    required this.speed,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forward / Rewind',
              style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => onChange(-2),
                icon: const Icon(Icons.fast_rewind),
                label: const Text('Rewind x2'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onChange(2.0),
                icon: const Icon(Icons.fast_forward),
                label: const Text('Forward x2'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
