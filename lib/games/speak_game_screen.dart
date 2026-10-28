// lib/games/speak_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../l10n/strings.dart';
import '../widgets/primary_button.dart';
import 'game_models.dart';
import 'game_shell.dart';

/// Речевая практика вместе с родителем: приложение произносит фразу,
/// ребёнок пробует повторить, а взрослый отмечает «Получилось» или
/// «Попробуем потом». Приложение само ничего не засчитывает: распознавания
/// речи в MVP нет.
class SpeakGameScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const SpeakGameScreen({
    super.key,
    required this.step,
    required this.total,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<SpeakGameScreen> createState() => _SpeakGameScreenState();
}

class _SpeakGameScreenState extends State<SpeakGameScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    // Тексты игр пока только на русском; озвучка игр на языке профиля —
    // этап 4 ТЗ.
    _tts.setLanguage('ru-RU');
    _tts.setSpeechRate(0.42);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    await _tts.stop();
    await _tts.speak(widget.step.speakPhrase);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final step = widget.step;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EEF9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_outline,
                  color: Color(0xFF7A6C99),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    s.practiceWithParent,
                    style: const TextStyle(
                      color: Color(0xFF7A6C99),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GamePromptCard(
            imagePath: step.promptImagePath,
            pictogramBuilder: step.promptPictogramBuilder,
            placeholderNote: step.promptPlaceholderNote,
            speech: step.speakPhrase,
            onPlaySpeech: _speak,
          ),
          GestureDetector(
            onTap: _speak,
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF331A47),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF331A47).withOpacity(0.3),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.speakListen,
                  style: const TextStyle(
                    color: Color(0xFF331A47),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.speakTryRepeat,
            style: const TextStyle(
              color: Color(0xFF331A47),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_solved) ...[
            const SizedBox(height: 20),
            Text(
              s.speakParentHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF331A47).withOpacity(0.6),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: s.speakDone,
              onTap: () => setState(() => _solved = true),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: s.speakLater,
              filled: false,
              onTap: widget.onSkip,
            ),
          ],
        ],
      ),
    );
  }
}
