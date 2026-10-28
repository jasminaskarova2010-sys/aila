// lib/games/games_flow_screen.dart

import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'categorize_game_screen.dart';
import 'choice_game_screen.dart';
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
  late int _currentIndex;
  int _earnedStars = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  void _handleComplete() {
    final appState = AppStateScope.of(context);
    // Звёзды даются только за первое прохождение задания.
    final awarded = appState.completeGame(_currentIndex, kStarsPerGame);
    if (awarded) {
      _earnedStars += kStarsPerGame;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text('+$kStarsPerGame ⭐'),
        ),
      );
    }
    _goNext();
  }

  /// «Попробуем потом»: идём дальше без звёзд, задание остаётся
  /// непройденным, к нему можно вернуться.
  void _handleSkip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1400),
        content: Text(S.of(context).speakLaterSnackbar),
      ),
    );
    _goNext();
  }

  void _goNext() {
    if (_currentIndex + 1 < kGameSteps.length) {
      setState(() => _currentIndex++);
      return;
    }
    _finish();
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
              color: Color(0xFF331A47), fontWeight: FontWeight.bold),
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
    final step = kGameSteps[_currentIndex];
    final total = kGameSteps.length;
    switch (step.kind) {
      case GameKind.choice:
        return ChoiceGameScreen(
          key: ValueKey(step.index),
          step: step,
          total: total,
          onComplete: _handleComplete,
        );
      case GameKind.order:
        return OrderGameScreen(
          key: ValueKey(step.index),
          step: step,
          total: total,
          onComplete: _handleComplete,
        );
      case GameKind.categorize:
        return CategorizeGameScreen(
          key: ValueKey(step.index),
          step: step,
          total: total,
          onComplete: _handleComplete,
        );
      case GameKind.speak:
        return SpeakGameScreen(
          key: ValueKey(step.index),
          step: step,
          total: total,
          onComplete: _handleComplete,
          onSkip: _handleSkip,
        );
    }
  }
}
