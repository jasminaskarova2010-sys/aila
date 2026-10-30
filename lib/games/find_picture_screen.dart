// lib/games/find_picture_screen.dart

import 'package:flutter/material.dart';

import '../board/board_screen.dart';
import '../board/board_speech.dart';
import '../l10n/strings.dart';
import 'game_models.dart';
import 'game_shell.dart';

/// «Найди картинку»: звучит слово, ребёнок находит его среди карточек. Число
/// карточек зависит от фазы. Неверный выбор не наказывается: спокойная просьба
/// попробовать ещё раз.
class FindPictureScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final BoardSpeech speech;
  final VoidCallback onComplete;

  const FindPictureScreen({
    super.key,
    required this.step,
    required this.total,
    required this.speech,
    required this.onComplete,
  });

  @override
  State<FindPictureScreen> createState() => _FindPictureScreenState();
}

class _FindPictureScreenState extends State<FindPictureScreen> {
  int _round = 0;
  bool _wrong = false;
  bool _solved = false;

  FindRound get _current => widget.step.findRounds[_round];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakPrompt();
    });
  }

  void _speakPrompt() {
    final s = S.of(context);
    widget.speech.speakText(s.gameFindPrompt(s.boardLabel(_current.target)));
  }

  Future<void> _onTap(FindRound round, int optionIndex) async {
    final word = round.options[optionIndex];
    if (word != round.target) {
      setState(() => _wrong = true);
      return;
    }
    final isLast = _round + 1 >= widget.step.findRounds.length;
    setState(() {
      _wrong = false;
      if (isLast) {
        _solved = true;
      } else {
        _round++;
      }
    });
    await widget.speech.speakWord(word);
    if (mounted && !isLast) _speakPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final step = widget.step;
    final round = _current;
    final count = round.options.length;
    final width = count <= 2 ? 170.0 : (count <= 4 ? 140.0 : 120.0);
    return GameShell(
      index: step.index,
      total: widget.total,
      title: step.title,
      subtitle: step.subtitle,
      solved: _solved,
      feedbackTitle: step.successTitle,
      feedbackBody: step.successBody,
      onContinue: widget.onComplete,
      content: Column(
        children: [
          GamePromptCard(
            speech: s.gameFindPrompt(s.boardLabel(round.target)),
            onPlaySpeech: _speakPrompt,
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                BoardCardTile(
                  key: ValueKey('${round.target.id}_${round.options[i].id}'),
                  word: round.options[i],
                  width: width,
                  height: width * 1.2,
                  onTap: () => _onTap(round, i),
                ),
            ],
          ),
          if (_wrong) ...[
            const SizedBox(height: 14),
            Text(
              s.gameTryAgain,
              style: TextStyle(
                color: const Color(0xFF331A47).withOpacity(0.55),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
