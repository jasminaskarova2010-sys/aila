// lib/survey/survey_screen.dart

import 'package:flutter/material.dart';

import '../board/board_theme.dart';
import '../l10n/strings.dart';
import '../main_screen.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';
import 'survey_data.dart';
import 'survey_result_screen.dart';

/// Закрывает опрос: при первом запуске открывает приложение, иначе
/// возвращает туда, откуда опрос открыли (настройки).
void leaveSurvey(BuildContext context, {required bool firstRun}) {
  if (firstRun) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  } else {
    Navigator.of(context).pop();
  }
}

/// Опрос родителя: один вопрос на экране, ответ сразу ведёт дальше. Опрос
/// применяется к текущему профилю и фазу сам не меняет: это происходит только
/// после подтверждения на экране результата.
class SurveyScreen extends StatefulWidget {
  final bool firstRun;

  const SurveyScreen({super.key, this.firstRun = false});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final List<SurveyAnswer> _answers = [];
  int _index = 0;

  void _answer(SurveyAnswer answer) {
    setState(() {
      _answers.length = _index;
      _answers.add(answer);
    });
    // Если нужен экран «начните со специалистом», остальные вопросы не влияют
    // на результат, и родителю незачем на них отвечать.
    if (needsSpecialistFirst(_answers) || _answers.length == kSurveyQuestionCount) {
      _finish();
      return;
    }
    setState(() => _index++);
  }

  void _finish() {
    AppStateScope.of(context).saveSurvey(_answers);
    final result = calculateSurveyResult(_answers);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => result.startWithSpecialist
            ? SurveySpecialistScreen(firstRun: widget.firstRun)
            : SurveyResultScreen(
                recommended: result.phase,
                firstRun: widget.firstRun,
              ),
      ),
    );
  }

  void _goBack() {
    if (_index > 0) {
      setState(() => _index--);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final showBack = _index > 0 || Navigator.of(context).canPop();
    final selected = _index < _answers.length ? _answers[_index] : null;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (showBack)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back, color: BoardTheme.ink),
                    ),
                  Expanded(
                    child: Text(
                      s.surveyTitle,
                      style: const TextStyle(
                        color: BoardTheme.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_index + 1} / $kSurveyQuestionCount',
                    style: const TextStyle(
                      color: BoardTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                s.surveyQuestion(_index),
                style: const TextStyle(
                  color: BoardTheme.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              for (final answer in SurveyAnswer.values) ...[
                PrimaryButton(
                  label: s.surveyAnswer(answer),
                  filled: answer == selected,
                  onTap: () => _answer(answer),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              Text(
                s.surveyDisclaimer,
                style: const TextStyle(
                  color: BoardTheme.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => leaveSurvey(context, firstRun: widget.firstRun),
                  child: Text(
                    s.surveyLater,
                    style: const TextStyle(color: BoardTheme.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
