import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'abstract_web_player.dart';

/// Web Player
class WebPlayerHtml extends WebPlayer {
  WebPlayerHtml({required super.channel});

  web.HTMLAudioElement? _audioElement;

  JSFunction? _onEndedListener;
  JSFunction? _onCanPlayListener;

  void _clearListeners() {
    final el = _audioElement;
    if (el != null) {
      if (_onEndedListener != null) {
        el.removeEventListener('ended', _onEndedListener);
        _onEndedListener = null;
      }
      if (_onCanPlayListener != null) {
        el.removeEventListener('canplay', _onCanPlayListener);
        _onCanPlayListener = null;
      }
    }
  }

  @override
  num get volume => _audioElement?.volume ?? 1.0;

  @override
  set volume(num volume) {
    _audioElement?.volume = volume.toDouble();
    channel.invokeMethod(WebPlayer.methodVolume, volume);
  }

  @override
  num get playSpeed => _audioElement?.playbackRate ?? 1.0;

  @override
  set playSpeed(num playSpeed) {
    _audioElement?.playbackRate = playSpeed.toDouble();
    channel.invokeMethod(WebPlayer.methodPlaySpeed, playSpeed);
  }

  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  set isPlaying(bool value) {
    _isPlaying = value;
    channel.invokeMethod(WebPlayer.methodIsPlaying, value);
    if (value) {
      _listenPosition();
    } else {
      _stopListenPosition();
    }
  }

  @override
  num get currentPosition => _audioElement?.currentTime ?? 0;

  var __listenPosition = false;

  num? _durationMs;
  num? _position;

  void _listenPosition() async {
    __listenPosition = true;
    await Future.doWhile(() {
      final durationMs = (_audioElement?.duration ?? 0) * 1000;
      if (durationMs != _durationMs) {
        _durationMs = durationMs;
        channel.invokeMethod(
            WebPlayer.methodCurrent, {'totalDurationMs': durationMs});
      }

      if (_position != currentPosition) {
        _position = currentPosition;
        final positionMs = currentPosition * 1000;
        channel.invokeMethod(WebPlayer.methodPosition, positionMs);
      }
      return Future.delayed(Duration(milliseconds: 200)).then((value) {
        return __listenPosition;
      });
    });
  }

  void _stopListenPosition() {
    __listenPosition = false;
  }

  @override
  void play() {
    if (_audioElement != null) {
      isPlaying = true;
      forwardHandler?.stop();
      _audioElement?.play();
    }
  }

  @override
  void pause() {
    if (_audioElement != null) {
      isPlaying = false;
      forwardHandler?.stop();
      _audioElement?.pause();
    }
  }

  @override
  void stop() {
    forwardHandler?.stop();
    forwardHandler = null;

    _clearListeners();

    final old = _audioElement;
    if (old != null) {
      isPlaying = false;
      old.pause();
      old.currentTime = 0;
      // Fully detach the old element so the browser releases its media
      // resource. Without this, a subsequent open() can leave the previous
      // element still playing, producing overlapping audio.
      old.src = '';
      old.load();
      _audioElement = null;
      channel.invokeMethod(WebPlayer.methodPosition, 0);
    }
  }

  @override
  Future<void> open({
    required String path,
    required String audioType,
    String? package,
    bool autoStart = false,
    double volume = 1,
    double? seek,
    double? playSpeed,
    Map? networkHeaders,
  }) async {
    stop();
    _durationMs = null;
    _position = null;
    final element = web.HTMLAudioElement()
      ..src = findAssetPath(path, audioType, package: package);
    _audioElement = element;

    // HTMLAudioElement cannot take networkHeaders

    _onEndedListener = ((web.Event event) {
      channel.invokeMethod(WebPlayer.methodFinished, true);
    }).toJS;
    element.addEventListener('ended', _onEndedListener);

    _onCanPlayListener = ((web.Event event) {
      if (autoStart) {
        play();
      }

      this.volume = volume;
      final durationMs = (element.duration) * 1000;

      if (durationMs != _durationMs) {
        _durationMs = durationMs;
        channel.invokeMethod(
            WebPlayer.methodCurrent, {'totalDurationMs': durationMs});
      }

      if (seek != null) {
        this.seek(to: seek);
      }

      if (playSpeed != null) {
        this.playSpeed = playSpeed;
      }

      // single event
      if (_onCanPlayListener != null) {
        element.removeEventListener('canplay', _onCanPlayListener);
        _onCanPlayListener = null;
      }
    }).toJS;
    element.addEventListener('canplay', _onCanPlayListener);
  }

  @override
  void seek({double? to}) {
    if (_audioElement != null && to != null) {
      /// The value sent from the plugin is in milliseconds; HTMLAudioElement
      /// uses seconds.
      final toInSeconds = to / 1000;
      _audioElement?.currentTime = toInSeconds;
    }
  }

  @override
  void loopSingleAudio(bool loop) {
    _audioElement?.loop = loop;
  }

  void seekBy({required double by}) {
    final current = currentPosition;
    final to = current + by;
    seek(to: to.toDouble());
  }

  ForwardHandler? forwardHandler;
  @override
  void forwardRewind(double speed) {
    pause();
    channel.invokeMethod(WebPlayer.methodForwardRewindSpeed, speed);
    forwardHandler?.stop();
    forwardHandler = ForwardHandler();
    _listenPosition(); // for this usecase, enable listen position
    forwardHandler?.start(this, speed);
  }
}

class ForwardHandler {
  bool _isEnabled = false;
  static final _timelapse = 300;

  void start(WebPlayerHtml player, double speed) async {
    _isEnabled = true;
    while (_isEnabled) {
      player.seekBy(by: speed * _timelapse);
      await Future.delayed(Duration(milliseconds: _timelapse));
    }
  }

  void stop() {
    _isEnabled = false;
  }
}
