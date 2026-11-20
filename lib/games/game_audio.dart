// lib/games/game_audio.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Спокойная музыка в играх, мягкий звук и лёгкая вибрация при верном ответе.
/// Каждое включается своим переключателем в настройках. На доске общения
/// музыки нет: там важна озвучка фраз.
///
/// Звуки сделаны скриптом `tool/make_sounds.py`, чужих записей нет.
class GameAudio {
  GameAudio._();

  static final GameAudio instance = GameAudio._();

  /// В автотестах нет звукового движка: там всё молчит.
  static bool enabled = true;

  static const _musicVolume = 0.18;
  static const _successVolume = 0.6;

  AudioPlayer? _music;
  AudioPlayer? _effects;
  bool _musicPlaying = false;

  Future<void> startMusic() async {
    if (!enabled || _musicPlaying) return;
    _musicPlaying = true;
    try {
      final player = _music ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(
        AssetSource('audio/calm_music.m4a'),
        volume: _musicVolume,
      );
    } catch (_) {
      _musicPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    if (!enabled || !_musicPlaying) return;
    _musicPlaying = false;
    try {
      await _music?.stop();
    } catch (_) {}
  }

  Future<void> success({required bool sound, required bool vibration}) async {
    if (!enabled) return;
    if (vibration) HapticFeedback.lightImpact();
    if (!sound) return;
    try {
      final player = _effects ??= AudioPlayer();
      await player.stop();
      await player.play(
        AssetSource('audio/success.m4a'),
        volume: _successVolume,
      );
    } catch (_) {}
  }
}
