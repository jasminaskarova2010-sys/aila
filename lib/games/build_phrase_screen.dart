// lib/games/build_phrase_screen.dart

import 'package:flutter/material.dart';

import '../board/board_screen.dart';
import '../board/board_speech.dart';
import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../board/phrase_builder.dart';
import '../board/pictogram_repository.dart';
import '../l10n/strings.dart';
import 'game_models.dart';
import 'game_shell.dart';

/// «Собери фразу» для фаз IV и выше: звучит фраза, ребёнок нажимает нужные
/// карточки, они встают в полоску на свои места. Порядок нажатий не важен.
class BuildPhraseScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final BoardSpeech speech;
  final VoidCallback onComplete;

  const BuildPhraseScreen({
    super.key,
    required this.step,
    required this.total,
    required this.speech,
    required this.onComplete,
  });

  @override
  State<BuildPhraseScreen> createState() => _BuildPhraseScreenState();
}

class _BuildPhraseScreenState extends State<BuildPhraseScreen> {
  final Set<BoardWord> _picked = {};
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakPhrase();
    });
  }

  void _speakPhrase() => widget.speech.speakPhrase(widget.step.phraseWords);

  void _onTap(BoardWord word) {
    if (!widget.step.phraseWords.contains(word)) {
      setState(() => _wrong = true);
      return;
    }
    final isDone = _picked.length + 1 == widget.step.phraseWords.length;
    setState(() {
      _wrong = false;
      _picked.add(word);
      _solved = isDone;
    });
    if (isDone) {
      _speakPhrase();
    } else {
      widget.speech.speakWord(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final step = widget.step;
    final pool = step.phrasePool.where((w) => !_picked.contains(w)).toList();
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
            speech: buildPhrase(step.phraseWords, s.lang),
            onPlaySpeech: _speakPhrase,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final word in step.phraseWords)
                _Slot(word: word, filled: _picked.contains(word)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final word in pool)
                BoardCardTile(
                  key: ValueKey(word.id),
                  word: word,
                  width: 120,
                  height: 144,
                  onTap: () => _onTap(word),
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

class _Slot extends StatelessWidget {
  final BoardWord word;
  final bool filled;

  const _Slot({required this.word, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 96,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: filled ? Colors.white : const Color(0xFFF2EEF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled ? BoardTheme.frameFor(word) : const Color(0xFFE3DCEC),
          width: 2,
        ),
      ),
      child: filled
          ? Column(
              children: [
                Expanded(child: PictogramRepository.image(word, 56)),
                Text(
                  S.of(context).boardLabel(word),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BoardTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
