// lib/games/choice_game_screen.dart

import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_shell.dart';
import 'missing_photo_placeholder.dart';

class ChoiceGameScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final VoidCallback onComplete;

  const ChoiceGameScreen({
    super.key,
    required this.step,
    required this.total,
    required this.onComplete,
  });

  @override
  State<ChoiceGameScreen> createState() => _ChoiceGameScreenState();
}

class _ChoiceGameScreenState extends State<ChoiceGameScreen> {
  int? _selected;
  bool _solved = false;

  void _select(int i) {
    setState(() {
      _selected = i;
      _solved = i == widget.step.correctIndex;
    });
  }

  void _playSpeech() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Озвучка появится позже')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          GamePromptCard(
            imagePath: step.promptImagePath,
            pictogramBuilder: step.promptPictogramBuilder,
            placeholderNote: step.promptPlaceholderNote,
            caption: step.promptCaption,
            speech: step.promptSpeech,
            onPlaySpeech: _playSpeech,
          ),
          if (step.promptImagePath != null ||
              step.promptPictogramBuilder != null ||
              step.promptPlaceholderNote != null)
            const Text(
              'Выбери правильный вариант.',
              style: TextStyle(color: Color(0xFF9B8FAE), fontSize: 13),
            ),
          if (step.promptImagePath != null ||
              step.promptPictogramBuilder != null ||
              step.promptPlaceholderNote != null)
            const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: List.generate(step.options.length, (i) {
              final option = step.options[i];
              final isSelected = _selected == i;
              final isCorrect = i == step.correctIndex;
              final showResult = isSelected;
              final borderColor = showResult && isCorrect
                  ? const Color(0xFF6EA34F)
                  : (showResult
                      ? const Color(0xFFB3ACC0)
                      : Colors.transparent);

              final hasImage = option.imagePath != null;
              final hasVisual = hasImage ||
                  option.pictogramBuilder != null ||
                  option.placeholderNote != null;
              final cardWidth = hasVisual ? 130.0 : (option.label != null ? 150.0 : 100.0);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _select(i),
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(hasVisual ? 8 : 12).copyWith(
                      top: hasVisual ? 8 : 16,
                      bottom: hasVisual ? 8 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF331A47).withOpacity(0.06),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.number != null) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFE0A93E),
                            child: Text(
                              '${option.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (hasImage)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              option.imagePath!,
                              width: cardWidth - 16,
                              height: cardWidth - 16,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (option.pictogramBuilder != null)
                          option.pictogramBuilder!(cardWidth - 16)
                        else if (option.placeholderNote != null)
                          MissingPhotoPlaceholder(
                            note: option.placeholderNote!,
                            size: cardWidth - 16,
                          ),
                        if (option.label != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            option.label!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF331A47),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (showResult && isCorrect) ...[
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6EA34F),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_selected != null && !_solved) ...[
            const SizedBox(height: 14),
            Text(
              'Попробуй ещё раз',
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
