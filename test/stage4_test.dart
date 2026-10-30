// Проверки этапа 4 ТЗ: игры на словах доски, перерывы, языки, журнал и отчёт.

import 'dart:math';

import 'package:aila_app/board/board_model.dart';
import 'package:aila_app/board/board_screen.dart';
import 'package:aila_app/board/board_words.dart';
import 'package:aila_app/games/game_models.dart';
import 'package:aila_app/games/game_pictograms.dart';
import 'package:aila_app/games/games_flow_screen.dart';
import 'package:aila_app/journal/journal.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/l10n/strings.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/parent/today_screen.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<String> spoken;
  late List<String> ttsLanguages;
  late bool voiceAvailable;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    spoken = [];
    ttsLanguages = [];
    voiceAvailable = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') spoken.add(call.arguments as String);
          if (call.method == 'setLanguage') {
            ttsLanguages.add(call.arguments as String);
          }
          if (call.method == 'isLanguageAvailable') {
            return voiceAvailable ? 1 : 0;
          }
          return 1;
        });
  });

  Future<AppState> newState({
    AppLanguage language = AppLanguage.ru,
    BoardPhase phase = BoardPhase.iv,
  }) async {
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: language);
    state.setPin('1234');
    state.setBoardPhase(phase);
    return state;
  }

  Future<void> openFlow(WidgetTester tester, AppState state, int start) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute(builder: (_) => GamesFlowScreen(startIndex: start)),
        );
    await tester.pumpAndSettle();
  }

  group('задания', () {
    test('«Собери фразу» только с фазы IV, число карточек по фазе', () async {
      final state = await newState();
      const s = S(AppLanguage.ru);
      for (final phase in BoardPhase.values) {
        state.setBoardPhase(phase);
        final model = BoardModel(state.activeProfile!);
        final steps = buildGameSteps(s, model);
        final hasPhrase = steps.any((st) => st.kind == GameKind.buildPhrase);
        expect(hasPhrase, phase.hasStrip, reason: '$phase');
        expect(steps.length, phase.hasStrip ? 10 : 9);
        // Номера на экране идут подряд, постоянные номера не повторяются.
        expect(steps.map((st) => st.index), [
          for (var i = 1; i <= steps.length; i++) i,
        ]);
        expect(steps.map((st) => st.id).toSet().length, steps.length);
        final find = steps.firstWhere((st) => st.kind == GameKind.findPicture);
        expect(find.findRounds.first.options.length, findCardCount(phase));
      }
      expect(findCardCount(BoardPhase.iiiA), 2);
      expect(findCardCount(BoardPhase.vi), 6);
    });

    test('фразы по фазам: описание в IV+, «Я вижу» в VI', () async {
      final state = await newState(phase: BoardPhase.ivPlus);
      const s = S(AppLanguage.ru);
      GameStep phraseStep() => buildGameSteps(
        s,
        BoardModel(state.activeProfile!),
      ).firstWhere((st) => st.kind == GameKind.buildPhrase);
      expect(phraseStep().phraseWords.length, 3);
      expect(phraseStep().phraseWords[1].kind, WordKind.adjective);
      state.setBoardPhase(BoardPhase.vi);
      expect(phraseStep().phraseWords.first.id, 'i_see');
      state.setBoardPhase(BoardPhase.iv);
      expect(phraseStep().phraseWords.first.id, 'i_want');
      expect(phraseStep().phraseWords.length, 2);
    });

    test('скрытые карточка и категория не появляются в играх', () async {
      final state = await newState(phase: BoardPhase.vi);
      state.setWordHidden('ball', true);
      state.setCategoryHidden(BoardCategory.drinks, true);
      final model = BoardModel(state.activeProfile!);
      const s = S(AppLanguage.ru);
      for (var seed = 0; seed < 40; seed++) {
        final steps = buildGameSteps(s, model, random: Random(seed));
        final used = <BoardWord>[
          for (final st in steps) ...[
            for (final round in st.findRounds) ...[
              round.target,
              ...round.options,
            ],
            ...st.phrasePool,
          ],
        ];
        expect(used, isNotEmpty);
        for (final word in used) {
          expect(word.id, isNot('ball'));
          expect(word.category, isNot(BoardCategory.drinks));
        }
        final says = steps.firstWhere((st) => st.id == 5);
        final labels = says.options.map((o) => o.label);
        expect(labels, isNot(contains('мяч')));
        expect(labels, isNot(contains('вода')));
        expect(says.promptSpeech, isNot(contains('мяч')));
        // «Повтори фразу» с водой недоступна: берётся другое слово.
        expect(steps.firstWhere((st) => st.id == 6).speakPhrase, isNot('Я хочу воду'));
      }
    });

    test('если карточек мало, задание пропускается', () async {
      final state = await newState();
      for (final category in [
        BoardCategory.food,
        BoardCategory.drinks,
        BoardCategory.toys,
      ]) {
        state.setCategoryHidden(category, true);
      }
      final steps = buildGameSteps(
        const S(AppLanguage.ru),
        BoardModel(state.activeProfile!),
      );
      // Остались задания на фото.
      expect(steps.map((st) => st.id), [0, 1, 2, 3, 7]);
    });

    test('прохождение хранится по постоянному номеру', () async {
      final state = await newState();
      expect(state.completeGame(9, 50), isTrue);
      expect(state.isGameCompleted(9), isTrue);
      expect(state.isGameCompleted(8), isFalse);
    });
  });

  testWidgets('«Найди картинку»: звучит слово, ошибка спокойная', (tester) async {
    final state = await newState();
    await openFlow(tester, state, 0);
    expect(find.text('Найди картинку'), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);

    for (var round = 0; round < 3; round++) {
      await tester.pump(const Duration(milliseconds: 300));
      final prompt = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((t) => t.startsWith('Найди: '));
      expect(spoken.last, prompt);
      final word = prompt.substring('Найди: '.length);

      if (round == 0) {
        final other = tester
            .widgetList<BoardCardTile>(find.byType(BoardCardTile))
            .firstWhere((t) => boardWordLabelOf(t.word) != word);
        await tester.tap(find.text(boardWordLabelOf(other.word)));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Попробуй ещё раз'), findsOneWidget);
        expect(find.text('Продолжить'), findsNothing);
      }
      await tester.tap(
        find.descendant(
          of: find.byType(BoardCardTile),
          matching: find.text(word),
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(find.text('Продолжить'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(state.stars, 50);
    expect(state.isGameCompleted(8), isTrue);
    expect(find.text('Кто счастлив?'), findsOneWidget);
  });

  testWidgets('«Собери фразу»: нужные карточки, фраза звучит целиком', (
    tester,
  ) async {
    final state = await newState();
    await openFlow(tester, state, 7);
    expect(find.text('Собери фразу'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    final phrase = spoken.last;
    expect(phrase, startsWith('Я хочу '));

    await tester.tap(
      find.descendant(
        of: find.byType(BoardCardTile),
        matching: find.text('Я хочу'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Продолжить'), findsNothing);

    // Лишняя карточка не засчитывается.
    final tiles = tester.widgetList<BoardCardTile>(find.byType(BoardCardTile));
    final texts = {for (final t in tiles) boardWordLabelOf(t.word): t.word};
    expect(texts.length, 3);
    var solved = false;
    for (final label in texts.keys) {
      await tester.tap(
        find.descendant(
          of: find.byType(BoardCardTile),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      if (find.text('Продолжить').evaluate().isNotEmpty) {
        solved = true;
        break;
      }
      expect(find.text('Попробуй ещё раз'), findsOneWidget);
    }
    expect(solved, isTrue);
    expect(spoken.last, phrase);
  });

  testWidgets('перерыв после заданного числа заданий', (tester) async {
    final state = await newState();
    state.setBreakAfterTasks(3);
    await openFlow(tester, state, 1);

    Future<void> solve(Finder finder) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
    }

    Finder asset(String path) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == path,
    );

    await solve(asset('assets/games/emotions/happy_child.PNG'));
    expect(find.text('Время перерыва'), findsNothing);
    await solve(asset('assets/games/social/waiting_in_line.PNG'));
    expect(find.text('Время перерыва'), findsNothing);
    await solve(find.byType(PlanePictogram));
    expect(find.text('Время перерыва'), findsOneWidget);
    expect(find.text('перерыв'), findsOneWidget);

    // Таймера нет: экран ждёт взрослого.
    await tester.pump(const Duration(minutes: 5));
    expect(find.text('Время перерыва'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('5 / 10'), findsOneWidget);
  });

  testWidgets('казахский: тексты игр, озвучка, интерфейс', (tester) async {
    final state = await newState(language: AppLanguage.kk);
    await openFlow(tester, state, 0);
    expect(ttsLanguages, contains('kk-KZ'));
    expect(find.text('Суретті тап'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(spoken.last, startsWith('Тап: '));

    // Каждое задание на казахском: нет заголовков на русском.
    final steps = buildGameSteps(
      const S(AppLanguage.kk),
      BoardModel(state.activeProfile!),
    );
    expect(steps[1].title, 'Кім бақытты?');
    expect(steps.last.promptSpeech, contains('Досың'));
    expect(steps.firstWhere((st) => st.id == 6).speakPhrase, 'Мен су қалаймын');

    state.setLanguage(AppLanguage.ru);
    await tester.pumpAndSettle();
    expect(find.text('Найди картинку'), findsOneWidget);
  });

  testWidgets('игра говорит только после настройки озвучки', (tester) async {
    // Настоящая настройка занимает время. Если заговорить раньше
    // awaitSpeakCompletion, flutter_tts на macOS падает, когда фраза закончится.
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          calls.add(call.method);
          if (call.method == 'isLanguageAvailable') {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          }
          return 1;
        });
    final state = await newState();
    await openFlow(tester, state, 0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(calls, contains('speak'));
    expect(
      calls.indexOf('awaitSpeakCompletion'),
      lessThan(calls.indexOf('speak')),
    );
  });

  testWidgets('нет голоса: честное сообщение родителю', (tester) async {
    voiceAvailable = false;
    final state = await newState(language: AppLanguage.kk);
    await openFlow(tester, state, 0);
    expect(find.textContaining('дауыс жоқ'), findsOneWidget);
  });

  group('журнал', () {
    Future<void> say(WidgetTester tester, String word) async {
      await tester.tap(find.text(word).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    }

    Future<void> openBoard(WidgetTester tester, AppState state) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MyApp(appState: state));
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute(builder: (_) => const BoardScreen()));
      await tester.pumpAndSettle();
    }

    String number(WidgetTester tester, String key) {
      final column = find.byKey(ValueKey(key));
      return tester
          .widget<Text>(
            find.descendant(of: column, matching: find.byType(Text)).first,
          )
          .data!;
    }

    testWidgets('«Сегодня» показывает реальные числа после доски', (
      tester,
    ) async {
      final state = await newState(phase: BoardPhase.v);
      await openBoard(tester, state);
      await say(tester, 'яблоко');
      await tester.longPress(find.text('Стереть'));
      await tester.pumpAndSettle();

      // Ответ на вопрос не считается спонтанной фразой.
      await tester.tap(find.text('Задать вопрос'));
      await tester.pump(const Duration(milliseconds: 100));
      await say(tester, 'мяч');

      final entries = state.journalEntries.where((e) => !e.isPhaseChange).toList();
      expect(entries.length, 2);
      expect(entries[0].text, 'Я хочу яблоко');
      expect(entries[0].cards, 2);
      expect(entries[0].isAnswer, isFalse);
      expect(entries[1].text, 'Я хочу мяч');
      expect(entries[1].isAnswer, isTrue);
      expect(entries[1].phase, BoardPhase.v);

      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute(builder: (_) => const TodayScreen()));
      await tester.pumpAndSettle();
      expect(number(tester, 'За сегодня spontaneous'), '1');
      expect(number(tester, 'За сегодня multi'), '2');
      expect(number(tester, 'За 7 дней spontaneous'), '1');
      expect(number(tester, 'За 7 дней multi'), '2');
      expect(find.text('Поделиться отчётом'), findsOneWidget);
    });

    testWidgets('фаза III: нажатие на карточку — фраза из одной карточки', (
      tester,
    ) async {
      final state = await newState(phase: BoardPhase.iiiA);
      await openBoard(tester, state);
      await tester.tap(find.text('яблоко'));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final entry = state.journalEntries.lastWhere((e) => !e.isPhaseChange);
      expect(entry.text, 'яблоко');
      expect(entry.cards, 1);
    });

    test('неделя, смена фазы, у каждого ребёнка свой журнал, сохранение', () async {
      final state = await newState();
      final now = DateTime(2026, 10, 30, 12);
      state.logPhrase(text: 'сегодня', cards: 2, now: now);
      state.logPhrase(
        text: 'неделя',
        cards: 1,
        now: now.subtract(const Duration(days: 6)),
      );
      state.logPhrase(
        text: 'давно',
        cards: 2,
        now: now.subtract(const Duration(days: 8)),
      );
      state.logPhrase(text: 'ответ', cards: 2, isAnswer: true, now: now);
      state.setBoardPhase(BoardPhase.vi);
      state.setBoardPhase(BoardPhase.vi);

      final entries = state.journalEntries;
      final today = countToday(entries, now);
      expect(today.spontaneous, 1);
      expect(today.multiCard, 2);
      final week = countWeek(entries, now);
      expect(week.spontaneous, 2);
      expect(week.multiCard, 2);
      // Смена на ту же фазу не записывается.
      expect(entries.where((e) => e.isPhaseChange).length, 1);

      final reloaded = await AppState.load();
      expect(reloaded.journalEntries.length, entries.length);
      expect(reloaded.journalEntries.last.phase, BoardPhase.vi);

      reloaded.addProfile(name: 'Второй', age: 4, language: AppLanguage.ru);
      expect(reloaded.journalEntries, isEmpty);
    });

    test('CSV: столбцы, экранирование, метка кодировки, без имени', () {
      const s = S(AppLanguage.ru);
      final csv = journalToCsv(
        [
          JournalEntry(
            time: DateTime(2026, 10, 30, 9, 5),
            profileId: 'p',
            text: 'Я хочу яблоко, спасибо',
            cards: 3,
            phase: BoardPhase.iv,
          ),
          JournalEntry(
            time: DateTime(2026, 10, 30, 9, 6),
            profileId: 'p',
            text: 'Мишка; "большой"',
            cards: 2,
            isAnswer: true,
            phase: BoardPhase.v,
          ),
          JournalEntry(
            time: DateTime(2026, 10, 30, 9, 7),
            profileId: 'p',
            text: '=SUM(A1)',
            cards: 1,
            phase: BoardPhase.v,
          ),
          JournalEntry(
            time: DateTime(2026, 10, 30, 9, 8),
            profileId: 'p',
            isPhaseChange: true,
            phase: BoardPhase.vi,
          ),
        ],
        headers: s.csvHeaders,
        phaseChangeLabel: s.csvPhaseChange,
        phraseLabel: s.csvPhrase,
        answerLabel: s.csvAnswer,
        spontaneousLabel: s.csvSpontaneous,
      );
      expect(csv.startsWith('﻿'), isTrue);
      final lines = csv.substring(1).trimRight().split('\r\n');
      expect(lines.length, 5);
      expect(lines[0], 'Дата и время;Тип;Фраза;Карточек;Как сказано;Фаза');
      expect(lines[1], '2026-10-30 09:05;фраза;Я хочу яблоко, спасибо;3;спонтанно;IV');
      expect(lines[2], '2026-10-30 09:06;фраза;"Мишка; ""большой""";2;ответ на вопрос;V');
      expect(lines[3], "2026-10-30 09:07;фраза;'=SUM(A1);1;спонтанно;V");
      expect(lines[4], '2026-10-30 09:08;смена фазы;;;;VI');
    });
  });
}

String boardWordLabelOf(BoardWord word) => const S(AppLanguage.ru).boardLabel(word);
