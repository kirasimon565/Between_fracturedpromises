import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../engine/engine.dart';

/// Music / ambience / one-shot SFX, driven entirely by engine effects.
///
/// Track names in scripts are bare (`@music "silence_broken"`); the controller
/// maps them onto `assets/music/*.mp3` and silently ignores anything missing so
/// a script can reference audio that has not been recorded yet.
class AudioController {
  AudioController();

  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _ambience = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  bool _initialised = false;
  String? _currentTrack;
  EngineSettings _settings = const EngineSettings();

  String? get currentTrack => _currentTrack;

  Future<void> initialise() async {
    if (_initialised) return;
    _initialised = true;
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _music.setLoopMode(LoopMode.one);
      await _ambience.setLoopMode(LoopMode.one);
    } catch (error) {
      debugPrint('Audio session unavailable: $error');
    }
  }

  void applySettings(EngineSettings settings) {
    _settings = settings;
    unawaited(_music.setVolume(_musicVolume()));
    if (!settings.musicEnabled) unawaited(_music.pause());
  }

  double _musicVolume([double? requested]) =>
      (requested ?? _settings.musicVolume) * _settings.masterVolume;

  /// Reacts to one engine effect. Returns true when the effect was audio.
  Future<bool> handle(EngineEffect effect) async {
    if (effect is MusicEffect) {
      if (effect.stop || effect.track == null) {
        await stopMusic(fade: effect.fade);
      } else {
        await playMusic(effect.track!, volume: effect.volume, loop: effect.loop);
      }
      return true;
    }
    if (effect is AmbienceEffect) {
      if (effect.stop || effect.track == null) {
        await _ambience.stop();
      } else {
        await _play(_ambience, effect.track!, effect.volume);
      }
      return true;
    }
    if (effect is PlaySoundEffect) {
      await playSound(effect.asset, volume: effect.volume);
      return true;
    }
    return false;
  }

  Future<void> playMusic(
    String track, {
    double volume = 0.6,
    bool loop = true,
  }) async {
    if (!_settings.musicEnabled) return;
    if (_currentTrack == track && _music.playing) return;
    _currentTrack = track;
    await _music.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    await _play(_music, track, volume);
  }

  Future<void> stopMusic({Duration fade = const Duration(milliseconds: 500)}) async {
    _currentTrack = null;
    try {
      const int steps = 6;
      final double from = _music.volume;
      for (int i = steps; i >= 0; i--) {
        await _music.setVolume(from * i / steps);
        await Future<void>.delayed(fade ~/ steps);
      }
      await _music.stop();
    } catch (_) {
      await _music.stop();
    }
  }

  Future<void> playSound(String asset, {double volume = 1.0}) async {
    if (!_settings.soundEnabled) return;
    await _play(_sfx, asset, volume * _settings.sfxVolume, loop: false);
  }

  Future<void> _play(
    AudioPlayer player,
    String name,
    double volume, {
    bool loop = true,
  }) async {
    final String path = _resolve(name);
    try {
      await player.setAsset(path);
      await player.setVolume(_musicVolume(volume));
      await player.play();
    } catch (error) {
      // Missing audio must never break playback of the story.
      debugPrint('Audio "$path" unavailable ($error)');
    }
  }

  static String _resolve(String name) {
    if (name.startsWith('assets/')) return name;
    if (name.contains('.')) return 'assets/music/$name';
    return 'assets/music/$name.mp3';
  }

  Future<void> pauseAll() async {
    await _music.pause();
    await _ambience.pause();
  }

  Future<void> resumeAll() async {
    if (_settings.musicEnabled && _currentTrack != null) await _music.play();
  }

  Future<void> dispose() async {
    await _music.dispose();
    await _ambience.dispose();
    await _sfx.dispose();
  }
}

final Provider<AudioController> audioControllerProvider =
    Provider<AudioController>((ref) {
  final AudioController controller = AudioController();
  unawaited(controller.initialise());
  ref.onDispose(() => unawaited(controller.dispose()));
  return controller;
});
