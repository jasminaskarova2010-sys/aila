// lib/survey/survey_result_screen.dart

import 'package:flutter/material.dart';

import '../board/board_screen.dart';
import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../l10n/strings.dart';
import '../main_screen.dart';
import '../parent/print_cards.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';
import 'survey_screen.dart';

/// Рекомендованная фаза. Она применяется, только когда родитель подтвердит.
class SurveyResultScreen extends StatefulWidget {
  final BoardPhase recommended;
  final bool firstRun;

  const SurveyResultScreen({
    super.key,
    required this.recommended,
    required this.firstRun,
  });

  @override
  State<SurveyResultScreen> createState() => _SurveyResultScreenState();
}

class _SurveyResultScreenState extends State<SurveyResultScreen> {
  late BoardPhase _phase = widget.recommended;

  Future<void> _choosePhase() async {
    final s = S.of(context);
    final chosen = await showModalBottomSheet<BoardPhase>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final option in BoardPhase.values)
              ListTile(
                selected: option == _phase,
                selectedColor: BoardTheme.ink,
                title: Text(s.boardPhaseName(option)),
                subtitle: Text(s.boardPhaseHint(option)),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _phase = chosen);
  }

  void _confirm() {
    AppStateScope.of(context).setBoardPhase(_phase);
    leaveSurvey(context, firstRun: widget.firstRun);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isRecommended = _phase == widget.recommended;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BackRow(),
              Text(
                isRecommended ? s.surveyRecommended : s.surveyChosen,
                style: const TextStyle(color: BoardTheme.muted, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                s.boardPhaseName(_phase),
                style: const TextStyle(
                  color: BoardTheme.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  s.phaseLearning(_phase),
                  style: const TextStyle(
                    color: BoardTheme.ink,
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: s.continueButton, onTap: _confirm),
              const SizedBox(height: 12),
              PrimaryButton(
                label: s.surveyChangeManually,
                filled: false,
                onTap: _choosePhase,
              ),
              const SizedBox(height: 20),
              Text(
                s.surveyDisclaimer,
                style: const TextStyle(
                  color: BoardTheme.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Возврат без изменений, если опрос открыт из настроек: повторный опрос не
/// должен менять фазу, пока родитель этого не подтвердит. При первом запуске
/// возвращаться некуда, и стрелки нет.
class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: BoardTheme.ink),
      ),
    );
  }
}

/// Экран для детей, которым сначала важнее научиться отдавать карточку
/// взрослому из рук в руки.
class SurveySpecialistScreen extends StatelessWidget {
  final bool firstRun;

  const SurveySpecialistScreen({super.key, required this.firstRun});

  void _openBoard(BuildContext context) {
    AppStateScope.of(context).setBoardPhase(BoardPhase.iiiA);
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
    navigator.push(MaterialPageRoute(builder: (_) => const BoardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BackRow(),
              Text(
                s.surveySpecialistBody,
                style: const TextStyle(
                  color: BoardTheme.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: s.printCards,
                onTap: () => printBaseCards(context),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: s.surveyOpenBoardAnyway,
                filled: false,
                onTap: () => _openBoard(context),
              ),
              const SizedBox(height: 20),
              Text(
                s.surveyDisclaimer,
                style: const TextStyle(
                  color: BoardTheme.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
