// Проверки этапа 3 ТЗ: опрос родителя, расчёт фазы, PDF, совет, напоминание.

import 'package:aila_app/board/board_screen.dart';
import 'package:aila_app/board/board_words.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/parent/print_cards.dart';
import 'package:aila_app/settings_screen.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:aila_app/survey/survey_data.dart';
import 'package:aila_app/survey/survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const a = SurveyAnswer.almostAlways;
const so = SurveyAnswer.sometimes;
const n = SurveyAnswer.never;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (call) async => 1,
        );
  });

  group('расчёт фазы', () {
    test('вопрос 1 или 2 не «Почти всегда»: сначала специалист', () {
      for (final answers in [
        [n],
        [so],
        [a, n],
        [a, so],
        [n, a, a, a, a, a, a, a],
      ]) {
        final result = calculateSurveyResult(answers);
        expect(result.startWithSpecialist, isTrue, reason: '$answers');
        expect(result.phase, BoardPhase.iiiA);
      }
    });

    test('фаза: первый вопрос 3–8 не «Почти всегда»', () {
      expect(calculateSurveyResult([a, a, so, a, a, a, a, a]).phase, BoardPhase.iiiA);
      expect(calculateSurveyResult([a, a, a, n, a, a, a, a]).phase, BoardPhase.iiiB);
      // Пример из ТЗ: «Почти всегда» на 1–4 и «Иногда» на 5 дают фазу IV.
      expect(calculateSurveyResult([a, a, a, a, so, a, a, a]).phase, BoardPhase.iv);
      expect(calculateSurveyResult([a, a, a, a, a, n, a, a]).phase, BoardPhase.ivPlus);
      expect(calculateSurveyResult([a, a, a, a, a, a, so, a]).phase, BoardPhase.v);
      expect(calculateSurveyResult([a, a, a, a, a, a, a, n]).phase, BoardPhase.vi);
      expect(calculateSurveyResult([a, a, a, a, a, a, a, a]).phase, BoardPhase.vi);
      expect(
        calculateSurveyResult([a, a, a, a, so, a, a, a]).startWithSpecialist,
        isFalse,
      );
    });
  });

  test('напоминание через 4 недели, ответы сохраняются', () async {
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    expect(state.isSurveyDue(), isFalse);

    final passed = DateTime(2026, 1, 1);
    state.saveSurvey([a, a, a, a, so, a, a, a], now: passed);
    expect(state.isSurveyDue(now: passed.add(const Duration(days: 27))), isFalse);
    expect(state.isSurveyDue(now: passed.add(const Duration(days: 28))), isTrue);

    final reloaded = await AppState.load();
    expect(reloaded.activeProfile!.lastSurveyAt, passed);
    expect(reloaded.activeProfile!.surveyAnswers[4], so);
  });

  testWidgets('PDF собирается на всех языках', (tester) async {
    expect(kPrintCardIds.length, 12);
    for (final language in AppLanguage.values) {
      final bytes = (await tester.runAsync(() => buildBaseCardsPdf(language)))!;
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(10000));
    }
  });

  Future<AppState> openSurvey(WidgetTester tester, {bool firstRun = false}) async {
    tester.view.physicalSize = const Size(900, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(builder: (_) => SurveyScreen(firstRun: firstRun)));
    await tester.pumpAndSettle();
    return state;
  }

  Future<void> answer(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('«Никогда» на вопрос 1: экран специалиста и доска III-A', (
    tester,
  ) async {
    final state = await openSurvey(tester);
    expect(find.text('1 / 8'), findsOneWidget);
    expect(find.textContaining('Это не диагноз'), findsOneWidget);

    await answer(tester, 'Никогда');
    expect(find.textContaining('из рук в руки'), findsOneWidget);
    expect(find.text('Распечатать набор карточек'), findsOneWidget);
    expect(state.activeProfile!.lastSurveyAt, isNotNull);

    await answer(tester, 'Всё равно открыть доску');
    expect(find.byType(BoardScreen), findsOneWidget);
    expect(state.activeProfile!.boardPhase, BoardPhase.iiiA);
    expect(find.text('Сказать'), findsNothing);
  });

  testWidgets('весь опрос: фаза IV, ручная смена, «назад»', (tester) async {
    final state = await openSurvey(tester);
    state.setBoardPhase(BoardPhase.vi);
    await tester.pumpAndSettle();

    await answer(tester, 'Почти всегда');
    await answer(tester, 'Почти всегда');
    expect(find.text('3 / 8'), findsOneWidget);
    // «Назад» возвращает к прошлому вопросу, ответ можно изменить.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('2 / 8'), findsOneWidget);
    await answer(tester, 'Почти всегда');
    await answer(tester, 'Почти всегда');
    await answer(tester, 'Почти всегда');
    await answer(tester, 'Иногда');
    await answer(tester, 'Почти всегда');
    await answer(tester, 'Почти всегда');
    await answer(tester, 'Почти всегда');

    expect(find.text('Рекомендуем начать с фазы'), findsOneWidget);
    expect(find.text('IV: фраза «Я хочу»'), findsOneWidget);
    expect(find.textContaining('Я хочу + предмет'), findsOneWidget);
    // Пока родитель не подтвердил, фаза прежняя.
    expect(state.activeProfile!.boardPhase, BoardPhase.vi);

    await answer(tester, 'Изменить фазу вручную');
    await tester.tap(find.text('V: ответ на вопрос'));
    await tester.pumpAndSettle();
    expect(find.text('Выбранная фаза'), findsOneWidget);
    await answer(tester, 'Продолжить');
    expect(state.activeProfile!.boardPhase, BoardPhase.v);

    // Доска сразу в новой фазе.
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const BoardScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Задать вопрос'), findsOneWidget);
    expect(find.text('Что ты видишь?'), findsNothing);
  });

  testWidgets('«Пройти позже» при первом запуске ведёт в приложение', (
    tester,
  ) async {
    final state = await openSurvey(tester, firstRun: true);
    await answer(tester, 'Пройти позже');
    expect(find.text('Привет, Айла!'), findsOneWidget);
    expect(state.activeProfile!.boardPhase, BoardPhase.iv);
    expect(state.activeProfile!.lastSurveyAt, isNull);
  });

  testWidgets('настройки: совет по фазе, напоминание, опрос', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Совет на сегодня'), findsOneWidget);
    expect(find.textContaining('вне досягаемости'), findsOneWidget);
    expect(find.text('Пройти опрос'), findsOneWidget);
    expect(find.text('Пройти опрос заново?'), findsNothing);

    state.setBoardPhase(BoardPhase.iiiA);
    state.saveSurvey([a, a], now: DateTime.now().subtract(const Duration(days: 30)));
    await tester.pumpAndSettle();
    expect(find.textContaining('нейтральную'), findsWidgets);
    expect(find.text('Пройти опрос заново?'), findsOneWidget);

    await tester.tap(find.text('Пройти опрос заново?'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 8'), findsOneWidget);
  });

  testWidgets('новый ребёнок из настроек сразу идёт на опрос', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('6'));
    await tester.pump();
    await tester.tap(find.text('Русский').last);
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 8'), findsOneWidget);
    expect(state.profiles.length, 2);
    await tester.tap(find.text('Пройти позже'));
    await tester.pumpAndSettle();
    expect(find.text('Совет на сегодня'), findsOneWidget);
  });
}
