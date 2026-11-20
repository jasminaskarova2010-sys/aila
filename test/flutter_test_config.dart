import 'dart:async';

import 'package:aila_app/games/game_audio.dart';

/// Общая настройка всех тестов: у тестов нет звукового движка.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GameAudio.enabled = false;
  await testMain();
}
