import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

import '../utils/string_duration.dart';
import '../widgets/demo_scaffold.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScaffold(
      title: 'AudioWidget (declarative)',
      description:
          'AudioWidget.assets plays an asset declaratively: you just flip a bool (play: true/false) and it starts or stops. Position is delivered via onPositionChanged.',
      body: _MyPageWithAudio(),
    );
  }
}

class _MyPageWithAudio extends StatefulWidget {
  const _MyPageWithAudio();

  @override
  State<_MyPageWithAudio> createState() => _MyPageWithAudioState();
}

class _MyPageWithAudioState extends State<_MyPageWithAudio>
    with SingleTickerProviderStateMixin {
  bool _play = false;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;
  bool _ready = false;
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void didUpdateWidget(covariant _MyPageWithAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _play = !_play);
    if (_play) {
      _rotation.repeat();
    } else {
      _rotation.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _total.inMilliseconds == 0
        ? 0.0
        : (_current.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);

    return AudioWidget.assets(
      path: 'assets/audios/electronic.mp3',
      play: _play,
      onReadyToPlay: (total) {
        setState(() {
          _total = total;
          _ready = true;
        });
      },
      onPositionChanged: (current, total) {
        setState(() {
          _current = current;
          _total = total;
          _ready = true;
        });
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_ready)
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Preparing electronic.mp3 — AudioWidget doesn\'t expose a download %, so this just waits for the browser to buffer the asset.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme
                                      .colorScheme.onSecondaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_ready) const SizedBox(height: 16),
                // Rotating vinyl-style cover
                AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _rotation,
                      builder: (context, child) => Transform.rotate(
                        angle: _rotation.value * 6.2831853,
                        child: child,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primary,
                              Colors.black,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Electronic',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Florent Champigny',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _total == Duration.zero ? null : progress,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_current.mmSSFormat,
                        style: theme.textTheme.bodySmall),
                    Text(_total.mmSSFormat,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: FilledButton.tonal(
                    onPressed: _togglePlay,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: Icon(
                      _play ? Icons.pause : Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _play ? 'play: true' : 'play: false',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
