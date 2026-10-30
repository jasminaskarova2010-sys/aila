// lib/journal/journal.dart

import '../board/board_words.dart';

/// Запись журнала для пилота. Журнал хранится только на устройстве (П7), наружу
/// попадает, только если родитель сам поделится отчётом.
class JournalEntry {
  final DateTime time;
  final String profileId;

  /// Смена фазы; иначе сказанная фраза.
  final bool isPhaseChange;
  final String text;
  final int cards;

  /// Фраза была ответом на вопрос взрослого (фазы V–VI); иначе спонтанная.
  final bool isAnswer;
  final BoardPhase phase;

  const JournalEntry({
    required this.time,
    required this.profileId,
    this.isPhaseChange = false,
    this.text = '',
    this.cards = 0,
    this.isAnswer = false,
    required this.phase,
  });

  Map<String, dynamic> toJson() => {
    't': time.toIso8601String(),
    'p': profileId,
    if (isPhaseChange) 'c': true,
    if (text.isNotEmpty) 'x': text,
    if (cards > 0) 'n': cards,
    if (isAnswer) 'a': true,
    'f': phase.name,
  };

  static JournalEntry? fromJson(Map<String, dynamic> json) {
    final time = DateTime.tryParse(json['t'] as String? ?? '');
    if (time == null) return null;
    return JournalEntry(
      time: time,
      profileId: json['p'] as String? ?? '',
      isPhaseChange: json['c'] as bool? ?? false,
      text: json['x'] as String? ?? '',
      cards: json['n'] as int? ?? 0,
      isAnswer: json['a'] as bool? ?? false,
      phase: BoardPhase.values.firstWhere(
        (p) => p.name == json['f'],
        orElse: () => BoardPhase.iv,
      ),
    );
  }
}

class JournalCounts {
  final int spontaneous;
  final int multiCard;

  const JournalCounts({required this.spontaneous, required this.multiCard});
}

JournalCounts _count(Iterable<JournalEntry> entries) {
  final phrases = entries.where((e) => !e.isPhaseChange);
  return JournalCounts(
    spontaneous: phrases.where((e) => !e.isAnswer).length,
    multiCard: phrases.where((e) => e.cards >= 2).length,
  );
}

/// За сегодняшний календарный день.
JournalCounts countToday(Iterable<JournalEntry> entries, DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  return _count(entries.where((e) => !e.time.isBefore(start)));
}

/// За последние 7 дней, включая сегодня.
JournalCounts countWeek(Iterable<JournalEntry> entries, DateTime now) {
  final start = DateTime(now.year, now.month, now.day - 6);
  return _count(entries.where((e) => !e.time.isBefore(start)));
}

String _two(int value) => value.toString().padLeft(2, '0');

String _formatTime(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

/// Значение ячейки CSV. Подписи карточек пишет родитель, поэтому начало вроде
/// «=» экранируется: таблица не должна принять подпись за формулу.
String _cell(String value) {
  var text = value;
  if (text.isNotEmpty && '=+-@'.contains(text[0])) text = "'$text";
  if (text.contains(RegExp(r'[;"\n\r]'))) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}

/// CSV для таблицы: разделитель «;» и метка UTF-8 в начале, чтобы Excel сам понял
/// русские и казахские буквы и разбил столбцы. Имени ребёнка в отчёте нет.
String journalToCsv(
  Iterable<JournalEntry> entries, {
  required List<String> headers,
  required String phaseChangeLabel,
  required String phraseLabel,
  required String answerLabel,
  required String spontaneousLabel,
}) {
  final rows = <String>[headers.map(_cell).join(';')];
  for (final e in entries) {
    rows.add(
      [
        _formatTime(e.time),
        e.isPhaseChange ? phaseChangeLabel : phraseLabel,
        e.text,
        e.isPhaseChange ? '' : '${e.cards}',
        e.isPhaseChange ? '' : (e.isAnswer ? answerLabel : spontaneousLabel),
        e.phase.code,
      ].map(_cell).join(';'),
    );
  }
  return '﻿${rows.join('\r\n')}\r\n';
}
