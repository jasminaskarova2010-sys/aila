// lib/games/break_screen.dart

import 'package:flutter/material.dart';

import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../board/pictogram_repository.dart';
import '../l10n/strings.dart';
import '../widgets/primary_button.dart';

/// Спокойный перерыв между заданиями. Таймера нет: занятие продолжает взрослый,
/// когда ребёнок готов.
class BreakScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const BreakScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final word = boardWordById('break')!;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                padding: const EdgeInsets.all(16),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: BoardTheme.ink),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.breakTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BoardTheme.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: BoardTheme.social, width: 3),
                      ),
                      child: Column(
                        children: [
                          PictogramRepository.image(word, 180),
                          const SizedBox(height: 8),
                          Text(
                            s.boardLabel(word),
                            style: const TextStyle(
                              color: BoardTheme.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      s.breakBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BoardTheme.muted,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: PrimaryButton(
                        label: s.continueButton,
                        onTap: onContinue,
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
