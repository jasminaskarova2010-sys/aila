// Проверки этапа 1 ТЗ: сохранение, профиль, PIN, честные звёзды.

import 'package:aila_app/games/games_flow_screen.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('звёзды только за первое прохождение и всё сохраняется', () async {
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.kk);
    state.setPin('1234');

    expect(state.completeGame(0, 50), isTrue);
    expect(state.completeGame(0, 50), isFalse);
    expect(state.stars, 50);
    expect(state.purchase('cap', 30), isTrue);
    state.equip('cap');
    state.setSoundEnabled(false);

    // «Перезапуск»: читаем состояние заново из хранилища.
    final reloaded = await AppState.load();
    final profile = reloaded.activeProfile!;
    expect(profile.name, 'Айла');
    expect(profile.age, 5);
    expect(profile.language, AppLanguage.kk);
    expect(reloaded.stars, 20);
    expect(reloaded.isOwned('cap'), isTrue);
    expect(reloaded.equippedOutfitId, 'cap');
    expect(reloaded.isGameCompleted(0), isTrue);
    expect(reloaded.completeGame(0, 50), isFalse);
    expect(reloaded.soundEnabled, isFalse);
    expect(reloaded.checkPin('1234'), isTrue);
  });

  test('у каждого профиля свои звёзды', () async {
    final state = await AppState.load();
    state.addProfile(name: 'Первый', age: 4, language: AppLanguage.ru);
    final firstId = state.activeProfile!.id;
    state.completeGame(0, 50);
    state.addProfile(name: 'Второй', age: 6, language: AppLanguage.ru);
    expect(state.stars, 0);
    expect(state.completeGame(0, 50), isTrue);
    state.switchProfile(firstId);
    expect(state.stars, 50);
    expect(state.profiles.length, 2);
  });

  testWidgets('первый запуск: профиль, PIN, настройки только за PIN',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = await AppState.load();
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();

    // Нигде нет email/пароля.
    expect(find.text('Email'), findsNothing);
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    expect(find.text('Профиль ребёнка'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Айла');
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('PIN родителя'), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.text('Введите этот PIN ещё раз'), findsOneWidget);
    await enterPin(tester, '1234');

    // После PIN открывается опрос родителя (этап 3), его можно отложить.
    expect(find.text('Опрос для родителя'), findsOneWidget);
    await tester.tap(find.text('Пройти позже'));
    await tester.pumpAndSettle();

    expect(find.text('Привет, Айла!'), findsOneWidget);
    expect(state.hasPin, isTrue);

    // Настройки открываются только после PIN.
    await tester.tap(find.text('Настройки').first);
    await tester.pumpAndSettle();
    expect(find.text('Для взрослых'), findsOneWidget);
    expect(find.text('Профили детей'), findsNothing);

    await enterPin(tester, '9999');
    expect(find.text('PIN не подошёл. Попробуйте ещё раз.'), findsOneWidget);
    expect(find.text('Профили детей'), findsNothing);

    await enterPin(tester, '1234');
    expect(find.text('Профили детей'), findsOneWidget);
  });

  Future<AppState> readyState() async {
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    return state;
  }

  testWidgets('забытый PIN сбрасывается через пример', (tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = await readyState();
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Настройки').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Забыли PIN?'));
    await tester.pumpAndSettle();

    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.contains('×'));
    final match = RegExp(r'(\d+) × (\d+)').firstMatch(question)!;
    final answer = int.parse(match[1]!) * int.parse(match[2]!);
    await tester.enterText(find.byType(TextField), '$answer');
    await tester.tap(find.text('Проверить'));
    await tester.pumpAndSettle();

    expect(find.text('PIN родителя'), findsOneWidget);
    await enterPin(tester, '5555');
    await enterPin(tester, '5555');
    expect(find.text('Профили детей'), findsOneWidget);
    expect(state.checkPin('5555'), isTrue);
  });

  testWidgets('речевая игра не засчитывает успех сама', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_tts'), (call) async => 1);

    final state = await readyState();
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator));

    // Шаг 7 «Повтори фразу» (позиция 6 в списке).
    nav.push(MaterialPageRoute(
        builder: (_) => const GamesFlowScreen(startIndex: 6)));
    await tester.pumpAndSettle();
    expect(find.text('Тренировка вместе с родителем'), findsOneWidget);
    await tester.tap(find.text('Послушать'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Продолжить'), findsNothing);
    expect(state.stars, 0);

    // «Попробуем потом»: дальше без звёзд и без ошибки.
    await tester.tap(find.text('Попробуем потом'));
    await tester.pumpAndSettle();
    expect(find.text('Что делать?'), findsOneWidget);
    expect(state.stars, 0);
    expect(state.isGameCompleted(6), isFalse);

    // «Получилось» — звёзды за первое прохождение.
    nav.pop();
    await tester.pumpAndSettle();
    nav.push(MaterialPageRoute(
        builder: (_) => const GamesFlowScreen(startIndex: 6)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Получилось'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(state.stars, 50);
    expect(state.isGameCompleted(6), isTrue);
  });

  testWidgets('все игры путешествия открываются', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_tts'), (call) async => 1);

    final state = await readyState();
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    for (var i = 0; i < 8; i++) {
      nav.push(MaterialPageRoute(
          builder: (_) => GamesFlowScreen(startIndex: i)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('${i + 1} / 8'), findsOneWidget);
      nav.pop();
      await tester.pumpAndSettle();
    }
  });
}
