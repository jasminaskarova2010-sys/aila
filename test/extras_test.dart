// Проверки доработок после этапа 5: путешествие дня, лимит игр, отчёт,
// исправление карточек.

import 'package:aila_app/board/board_words.dart';
import 'package:aila_app/games/games_flow_screen.dart';
import 'package:aila_app/journal/journal.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/l10n/strings.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/parent/specialist_report.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (c) async => 1);
  });
  tearDown(() => AppState.clock = DateTime.now);

  Future<AppState> newState() async {
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    return state;
  }

  test('путешествие начинается заново на следующий день', () async {
    AppState.clock = () => DateTime(2026, 11, 20, 10);
    final state = await newState();
    expect(state.completeGame(0, 50), isTrue);
    expect(state.completeGame(0, 50), isFalse);
    expect(state.completedGamesCount, 1);

    AppState.clock = () => DateTime(2026, 11, 21, 9);
    expect(state.isGameCompleted(0), isFalse);
    expect(state.completedGamesCount, 0);
    expect(state.completeGame(0, 50), isTrue);
    expect(state.stars, 100);
  });

  testWidgets('лимит игр: после него спокойный экран', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await newState();
    state.setGameLimitMinutes(10);
    expect(state.isGameLimitReached, isFalse);
    state.addPlayTime(600);
    expect(state.isGameLimitReached, isTrue);

    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const GamesFlowScreen()));
    await tester.pumpAndSettle();
    expect(find.text('На сегодня игры закончились'), findsOneWidget);

    final reloaded = await AppState.load();
    expect(reloaded.playedSecondsToday, greaterThanOrEqualTo(600));
    state.setGameLimitMinutes(0);
    expect(state.isGameLimitReached, isFalse);
  });

  test('фразы по дням и самые частые', () {
    final now = DateTime(2026, 11, 20, 12);
    JournalEntry e(int daysAgo, String text) => JournalEntry(
      time: now.subtract(Duration(days: daysAgo)),
      profileId: 'p',
      text: text,
      cards: 2,
      phase: BoardPhase.iv,
    );
    final entries = [e(0, 'Я хочу сок'), e(0, 'Я хочу сок'), e(2, 'Я хочу мяч'), e(9, 'старое')];
    expect(phrasesPerDay(entries, now), [0, 0, 0, 0, 1, 0, 2]);
    final top = topPhrases(entries, now.subtract(const Duration(days: 6)));
    expect(top.first.key, 'Я хочу сок');
    expect(top.first.value, 2);
    expect(top.map((p) => p.key), isNot(contains('старое')));
  });

  testWidgets('документ для специалиста собирается', (tester) async {
    final state = await newState();
    state.logPhrase(text: 'Я хочу сок', cards: 2);
    final bytes = (await tester.runAsync(
      () => buildSpecialistReport(
        const S(AppLanguage.kk),
        state.activeProfile!,
        state.journalEntries,
        DateTime.now(),
      ),
    ))!;
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('карточку родителя можно исправить', () async {
    final state = await newState();
    state.addParentCard(const ParentCard(
      id: 'parent_1',
      label: 'Мишка',
      category: BoardCategory.toys,
      imageFile: 'a.jpg',
    ));
    state.updateParentCard(const ParentCard(
      id: 'parent_1',
      label: 'Мишутка',
      category: BoardCategory.people,
      imageFile: 'b.jpg',
      audioFile: 'v.m4a',
    ));
    final card = (await AppState.load()).activeProfile!.parentCards.single;
    expect(card.label, 'Мишутка');
    expect(card.category, BoardCategory.people);
    expect(card.imageFile, 'b.jpg');
    expect(card.audioFile, 'v.m4a');
  });
}
