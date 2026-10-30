// lib/board/board_speech.dart

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/app_language.dart';
import '../l10n/board_labels.dart';
import 'board_words.dart';
import 'parent_media.dart';
import 'phrase_builder.dart';

const _ttsLocales = {
  AppLanguage.ru: 'ru-RU',
  AppLanguage.en: 'en-US',
  AppLanguage.kk: 'kk-KZ',
};

/// Озвучка доски на языке профиля. Если у карточки есть запись голоса
/// родителя, играет она, а не синтез речи.
class BoardSpeech {
  final FlutterTts _tts = FlutterTts();
  AudioPlayer? _player;
  AppLanguage _language = AppLanguage.ru;

  /// Каждое новое озвучивание отменяет предыдущее.
  int _generation = 0;

  /// Настраивает язык. Возвращает false, если голоса для него на устройстве нет.
  Future<bool> setLanguage(AppLanguage language) async {
    _language = language;
    final locale = _ttsLocales[language]!;
    var available = true;
    try {
      final result = await _tts.isLanguageAvailable(locale);
      available = result == true || result == 1;
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      available = false;
    }
    return available;
  }

  Future<void> speakText(String text) async {
    await _stop();
    await _tts.speak(text);
  }

  Future<void> speakWord(BoardWord word) async {
    await _stop();
    if (await _playRecording(word, _generation)) return;
    await _tts.speak(word.customLabel ?? boardWordLabel(word.id, _language));
  }

  /// Фраза целиком. Карточки с записью голоса звучат своей записью, остальное
  /// — синтезом по кускам между ними.
  Future<void> speakPhrase(List<BoardWord> parts) async {
    await _stop();
    final generation = _generation;
    var run = <BoardWord>[];
    Future<void> flush() async {
      if (run.isEmpty) return;
      final text = buildPhrase(run, _language);
      run = [];
      if (generation == _generation) await _tts.speak(text);
    }

    for (final word in parts) {
      if (word.audioFile == null) {
        run.add(word);
        continue;
      }
      await flush();
      if (generation != _generation) return;
      await _playRecording(word, generation);
      if (generation != _generation) return;
    }
    await flush();
  }

  Future<bool> _playRecording(BoardWord word, int generation) async {
    final file = ParentMedia.file(word.audioFile);
    if (file == null || !file.existsSync()) return false;
    final player = _player ??= AudioPlayer();
    final done = player.onPlayerComplete.first;
    await player.play(DeviceFileSource(file.path));
    await done.timeout(const Duration(seconds: 30), onTimeout: () {});
    return generation == _generation;
  }

  Future<void> _stop() async {
    _generation++;
    await _tts.stop();
    await _player?.stop();
  }

  void dispose() {
    _generation++;
    _tts.stop();
    _player?.dispose();
  }
}
