// lib/games/games_flow_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import '../board/board_speech.dart';
import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'break_screen.dart';
import 'build_phrase_screen.dart';
import 'categorize_game_screen.dart';
import 'choice_game_screen.dart';
import 'find_picture_screen.dart';
import 'game_audio.dart';
import 'game_models.dart';
import 'order_game_screen.dart';
import 'speak_game_screen.dart';

const int kStarsPerGame = 50;

class GamesFlowScreen extends StatefulWidget {
  final int startIndex;

  const GamesFlowScreen({super.key, this.startIndex = 0});

  @override
  State<GamesFlowScreen> createState() => _GamesFlowScreenState();
}

class _GamesFlowScreenState extends State<GamesFlowScreen> {
  final BoardSpeech _speech = BoardSpeech();
  late int _currentIndex;
  int _earnedStars = 0;
  List<GameStep> _steps = const [];
  String? _stepsKey;
  AppLanguage? _speechLanguage;

  /// Время в играх считается для лимита родителя.
  Timer? _playTimer;
  DateTime _playSince = DateTime.now();
  AppState? _appState;

  /// Заданий с прошлого перерыва.
  int _sinceBreak = 0;
  bool _onBreak = false;

  /// Задание уже открыто: лимит не прерывает его на середине.
  bool _inTask = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _playTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _recordPlayTime(),
    );
  }

  void _recordPlayTime() {
    final now = DateTime.now();
    _appState?.addPlayTime(now.difference(_playSince).inSeconds);
    _playSince = now;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AppLocaleScope.of(context).language;
    if (_speechLanguage != language) {
      _speechLanguage = language;
      _checkVoice(language);
    }
    _appState = AppStateScope.of(context);
    _refreshSteps();
    _syncMusic();
  }

  /// Музыка играет, пока открыты игры, и слушается переключателя в настройках.
  void _syncMusic() {
    final on = AppStateScope.of(context).musicEnabled;
    if (on) {
      GameAudio.instance.startMusic();
    } else {
      GameAudio.instance.stopMusic();
    }
  }

  Future<void> _checkVoice(AppLanguage language) async {
    final available = await _speech.setLanguage(language);
    if (available || !mounted) return;
    _showNote(S.of(context).noVoiceMessage, const Duration(seconds: 6));
  }

  /// Родитель может сменить язык, фазу или скрыть карточки прямо из игры
  /// (настройки за PIN). Тогда задания собираются заново, текущее остаётся.
  void _refreshSteps() {
    final profile = AppStateScope.of(context).activeProfile;
    final key = [
      AppLocaleScope.of(context).language.name,
      profile?.id,
      profile?.boardPhase.name,
      profile?.hiddenWordIds.join(','),
      profile?.hiddenCategories.map((c) => c.name).join(','),
      profile?.parentCards.length,
    ].join('|');
    if (key == _stepsKey) return;
    final currentId = _steps.isEmpty ? null : _steps[_currentIndex].id;
    _stepsKey = key;
    _steps = gameStepsFor(context);
    final kept = _steps.indexWhere((step) => step.id == currentId);
    _currentIndex = kept >= 0
        ? kept
        : _currentIndex.clamp(0, _steps.length - 1);
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _recordPlayTime();
    GameAudio.instance.stopMusic();
    _speech.dispose();
    super.dispose();
  }

  /// Сообщение над нижней панелью: оно не должно закрывать «Продолжить».
  void _showNote(String text, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 200),
        content: Text(text),
      ),
    );
  }

  void _handleComplete() {
    final appState = AppStateScope.of(context);
    // Звёзды даются только за первое прохождение задания.
    final awarded = appState.completeGame(
      _steps[_currentIndex].id,
      kStarsPerGame,
    );
    if (awarded) {
      _earnedStars += kStarsPerGame;
      _showNote('+$kStarsPerGame ⭐', const Duration(milliseconds: 900));
    }
    _goNext();
  }

  /// «Попробуем потом»: идём дальше без звёзд, задание остаётся
  /// непройденным, к нему можно вернуться.
  void _handleSkip() {
    _showNote(
      S.of(context).speakLaterSnackbar,
      const Duration(milliseconds: 1400),
    );
    _goNext();
  }

  void _goNext() {
    _recordPlayTime();
    _inTask = false;
    if (_currentIndex + 1 >= _steps.length) {
      _finish();
      return;
    }
    final breakAfter =
        AppStateScope.of(context).activeProfile?.breakAfterTasks ?? 4;
    setState(() {
      _currentIndex++;
      _sinceBreak++;
      if (_sinceBreak >= breakAfter) {
        _sinceBreak = 0;
        _onBreak = true;
      }
    });
  }

  Future<void> _finish() async {
    final s = S.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF0EA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          s.sessionDoneTitle,
          style: const TextStyle(
            color: Color(0xFF331A47),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          s.sessionDoneBody(_earnedStars),
          style: const TextStyle(color: Color(0xFF331A47)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.sessionDoneOk),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Лимит проверяется между заданиями: начатое задание не обрывается.
    if (AppStateScope.of(context).isGameLimitReached && !_inTask) {
      return const GameLimitScreen();
    }
    if (_onBreak) {
      return BreakScreen(
        speech: _speech,
        onContinue: () => setState(() => _onBreak = false),
      );
    }
    final step = _steps[_currentIndex];
    final total = _steps.length;
    _inTask = true;
    switch (step.kind) {
      case GameKind.findPicture:
        return FindPictureScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          speech: _speech,
          onComplete: _handleComplete,
        );
      case GameKind.buildPhrase:
        return BuildPhraseScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          speech: _speech,
          onComplete: _handleComplete,
        );
      case GameKind.choice:
        return ChoiceGameScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          speech: _speech,
          onComplete: _handleComplete,
        );
      case GameKind.order:
        return OrderGameScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          onComplete: _handleComplete,
        );
      case GameKind.categorize:
        return CategorizeGameScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          onComplete: _handleComplete,
        );
      case GameKind.speak:
        return SpeakGameScreen(
          key: ValueKey(step.id),
          step: step,
          total: total,
          speech: _speech,
          onComplete: _handleComplete,
          onSkip: _handleSkip,
        );
    }
  }
}
