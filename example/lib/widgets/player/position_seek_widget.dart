import 'package:flutter/material.dart';

class PositionSeekWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration) seekTo;

  const PositionSeekWidget({
    super.key,
    required this.currentPosition,
    required this.duration,
    required this.seekTo,
  });

  @override
  State<PositionSeekWidget> createState() => _PositionSeekWidgetState();
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  late Duration _visibleValue;
  bool listenOnlyUserInterraction = false;

  double get _maxMs => widget.duration.inMilliseconds <= 0
      ? 1
      : widget.duration.inMilliseconds.toDouble();

  double get _currentMs {
    final v = _visibleValue.inMilliseconds.toDouble();
    if (v < 0) return 0;
    if (v > _maxMs) return _maxMs;
    return v;
  }

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seek', style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600)),
          Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(durationToString(_visibleValue)),
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: _maxMs,
                  value: _currentMs,
                  onChangeStart: (_) {
                    setState(() {
                      listenOnlyUserInterraction = true;
                    });
                  },
                  onChanged: (newValue) {
                    setState(() {
                      _visibleValue =
                          Duration(milliseconds: newValue.floor());
                    });
                  },
                  onChangeEnd: (newValue) {
                    setState(() {
                      listenOnlyUserInterraction = false;
                      widget.seekTo(_visibleValue);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  durationToString(widget.duration),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds =
      twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
