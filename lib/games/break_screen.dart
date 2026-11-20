// lib/games/break_screen.dart

import 'package:flutter/material.dart';

import '../board/board_model.dart';
import '../board/board_screen.dart';
import '../board/board_speech.dart';
import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../board/pictogram_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../widgets/aila_face.dart';
import '../widgets/primary_button.dart';

/// Игры на сегодня закончились (лимит родителя). Доска общения работает.
class GameLimitScreen extends StatelessWidget {
  const GameLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AilaFace(AilaMood.sleep, size: 170),
                const SizedBox(height: 20),
                Text(
                  s.limitTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BoardTheme.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.limitBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BoardTheme.muted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: PrimaryButton(
                    label: s.limitHome,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Спокойный перерыв между заданиями. Ребёнок выбирает вкусняшку, и ему
/// говорят показать выбор родителю: это награда. Всё на экране озвучено.
/// Таймера нет: занятие продолжает взрослый, когда ребёнок готов.
class BreakScreen extends StatefulWidget {
  final BoardSpeech speech;
  final VoidCallback onContinue;

  const BreakScreen({
    super.key,
    required this.speech,
    required this.onContinue,
  });

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  static const _treatCount = 6;
  static const _preferred = [
    'ice_cream',
    'cookie',
    'apple',
    'banana',
    'juice',
    'milk',
  ];

  BoardWord? _chosen;
  List<BoardWord>? _treats;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_treats != null) return;
    // Вкусняшки из еды и напитков, которые родитель не скрыл. Сначала
    // любимые лакомства, потом остальное. Порядок постоянный: карточки не
    // должны меняться местами (П4).
    final profile = AppStateScope.of(context).activeProfile;
    final available = profile == null
        ? const <BoardWord>[]
        : BoardModel(profile).gameObjects
              .where(
                (w) =>
                    w.category == BoardCategory.food ||
                    w.category == BoardCategory.drinks,
              )
              .toList();
    int rank(BoardWord w) {
      final i = _preferred.indexOf(w.id);
      return i < 0 ? _preferred.length : i;
    }

    _treats = ([
      ...available,
    ]..sort((a, b) => rank(a) - rank(b))).take(_treatCount).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = S.of(context);
      widget.speech.speakText(
        _treats!.isEmpty
            ? '${s.breakTitle}. ${s.breakRestOnly}'
            : '${s.breakTitle}. ${s.breakChoose}',
      );
    });
  }

  void _choose(BoardWord word) {
    final s = S.of(context);
    setState(() => _chosen = word);
    widget.speech.speakText('${s.boardLabel(word)}. ${s.breakShowParent}');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final treats = _treats ?? const <BoardWord>[];
    final chosen = _chosen;
    final breakWord = boardWordById('break')!;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: const EdgeInsets.all(16),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: BoardTheme.ink),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const AilaFace(AilaMood.sleep, size: 110),
                    const SizedBox(height: 6),
                    // Нажатие на заголовок повторяет озвучку.
                    GestureDetector(
                      onTap: () => widget.speech.speakText(
                        treats.isEmpty
                            ? s.breakTitle
                            : '${s.breakTitle}. ${s.breakChoose}',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PictogramRepository.image(breakWord, 56),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              s.breakTitle,
                              style: const TextStyle(
                                color: BoardTheme.ink,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (treats.isNotEmpty) ...[
                      Text(
                        s.breakChoose,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: BoardTheme.muted,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final word in treats)
                            _TreatCard(
                              word: word,
                              selected: word == chosen,
                              onTap: () => _choose(word),
                            ),
                        ],
                      ),
                    ],
                    if (chosen != null) ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _choose(chosen),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3DE),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              PictogramRepository.image(chosen, 72),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  s.breakShowParent,
                                  style: const TextStyle(
                                    color: Color(0xFF2F5E12),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.volume_up,
                                color: Color(0xFF2F5E12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      s.breakBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BoardTheme.muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: PrimaryButton(
                        label: s.continueButton,
                        onTap: widget.onContinue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatCard extends StatelessWidget {
  final BoardWord word;
  final bool selected;
  final VoidCallback onTap;

  const _TreatCard({
    required this.word,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Выбранная карточка обведена зелёным, остальные остаются на местах.
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? const Color(0xFF5E9B45) : Colors.transparent,
          width: 3,
        ),
      ),
      child: BoardCardTile(word: word, width: 104, height: 126, onTap: onTap),
    );
  }
}
