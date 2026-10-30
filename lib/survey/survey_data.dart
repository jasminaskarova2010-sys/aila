// lib/survey/survey_data.dart

import '../board/board_words.dart';

// ЧЕРНОВИК: вопросы опроса (тексты в S.surveyQuestion), расчёт фазы и советы
// по фазам (S.phaseTip) должен проверить специалист: логопед или дефектолог.

enum SurveyAnswer { never, sometimes, almostAlways }

const int kSurveyQuestionCount = 8;

/// Через столько дней после опроса в настройках появляется напоминание.
const int kSurveyRepeatDays = 28;

/// Фазы вопросов 3–8 по порядку.
const List<BoardPhase> _phaseByQuestion = [
  BoardPhase.iiiA,
  BoardPhase.iiiB,
  BoardPhase.iv,
  BoardPhase.ivPlus,
  BoardPhase.v,
  BoardPhase.vi,
];

class SurveyResult {
  final BoardPhase phase;

  /// Ответ на вопрос 1 или 2 не «Почти всегда»: ребёнку сначала важнее
  /// научиться отдавать карточку взрослому из рук в руки.
  final bool startWithSpecialist;

  const SurveyResult(this.phase, {this.startWithSpecialist = false});
}

/// Правила из ТЗ. Если на вопрос 1 или 2 ответ не «Почти всегда», остальные
/// ответы на результат не влияют, поэтому список может быть неполным.
SurveyResult calculateSurveyResult(List<SurveyAnswer> answers) {
  if (needsSpecialistFirst(answers)) {
    return const SurveyResult(BoardPhase.iiiA, startWithSpecialist: true);
  }
  for (var i = 0; i < _phaseByQuestion.length; i++) {
    final index = i + 2;
    if (index >= answers.length || answers[index] != SurveyAnswer.almostAlways) {
      return SurveyResult(_phaseByQuestion[i]);
    }
  }
  return const SurveyResult(BoardPhase.vi);
}

/// Уже понятно, что нужен экран «начните со специалистом»?
bool needsSpecialistFirst(List<SurveyAnswer> answers) => answers
    .take(2)
    .any((answer) => answer != SurveyAnswer.almostAlways);
