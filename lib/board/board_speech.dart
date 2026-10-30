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

  /// Настройка озвучки, которая ещё идёт. Говорить можно только после неё:
  /// если начать фразу раньше awaitSpeakCompletion, flutter_tts на macOS падает,
  /// когда фраза закончится.
  Future<bool>? _ready;

  /// Настраивает язык. Возвращает false, если голоса для него на устройстве нет.
  Future<bool> setLanguage(AppLanguage language) {
    _language = language;
    return _ready = _configure(language);
  }

  Future<bool> _configure(AppLanguage language) async {
    final locale = _ttsLocales[language]!;
    var available = true;
    try {
      await _tts.awaitSpeakCompletion(true);
      final result = await _tts.isLanguageAvailable(locale);
      final set = await _tts.setLanguage(locale);
      // На Android при самом первом запуске движок мог отвечать «нет голоса»,
      // хотя говорил. Настоящее отсутствие голоса — это оба ответа «нет».
      available = result == true || result == 1 || set == 1;
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
    } catch (_) {
      available = false;
    }
    return available;
  }

  /// Останавливает прошлую фразу и ждёт настройки. Возвращает номер этого
  /// озвучивания: если за время ожидания началось новое, старое уже не звучит.
  Future<int> _begin() async {
    final generation = ++_generation;
    await _tts.stop();
    await _player?.stop();
    await (_ready ??= _configure(_language));
    return generation;
  }

  Future<void> speakText(String text) async {
    final generation = await _begin();
    if (generation == _generation) await _tts.speak(text);
  }

  Future<void> speakWord(BoardWord word) async {
    final generation = await _begin();
    if (generation != _generation) return;
    if (await _playRecording(word, generation)) return;
    if (generation != _generation) return;
    await _tts.speak(word.customLabel ?? boardWordLabel(word.id, _language));
  }

  /// Фраза целиком. Карточки с записью голоса звучат своей записью, остальное
  /// — синтезом по кускам между ними.
  Future<void> speakPhrase(List<BoardWord> parts) async {
    final generation = await _begin();
    if (generation != _generation) return;
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

  void dispose() {
    _generation++;
    _tts.stop();
    _player?.dispose();
  }
}
