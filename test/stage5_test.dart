// Проверки этапа 5 ТЗ: экран «О приложении», файлы сборки, тексты интерфейса.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:aila_app/info_screen.dart';
import 'package:aila_app/journal/journal.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/settings_screen.dart';
import 'package:aila_app/wardrobe_screen.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:aila_app/widgets/aila_face.dart';
import 'package:aila_app/widgets/aila_hello.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('«О приложении»: назначение, специалист, авторы, приватность', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
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
        .push(MaterialPageRoute(builder: (_) => const InfoScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Для чего Айла'), findsOneWidget);
    expect(find.text('Не заменяет занятий со специалистом'), findsOneWidget);
    expect(
      find.textContaining(
        'Все данные хранятся только на этом устройстве и никуда не передаются',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Sergio Palao'), findsOneWidget);
    expect(find.textContaining('Mulberry Symbols'), findsOneWidget);
    expect(find.textContaining('AI'), findsNothing);
  });

  test('в текстах нет PECS, AI и обещаний лечения', () {
    final strings = File('lib/l10n/strings.dart').readAsStringSync();
    expect(strings, isNot(contains('PECS')));
    expect(strings, isNot(contains('AI-')));
    expect(strings.toLowerCase(), isNot(contains('вылеч')));
  });

  test('все картинки из кода есть на диске с точным регистром имени', () {
    final used = <String>{};
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final matches = RegExp(
        r"assets/[\w./-]+\.(?:png|PNG|svg|ttf)",
      ).allMatches(file.readAsStringSync());
      used.addAll(matches.map((m) => m.group(0)!));
    }
    expect(used, isNotEmpty);
    for (final path in used) {
      final file = File(path);
      final names = file.parent.listSync().map(
        (e) => e.uri.pathSegments.last,
      );
      expect(names, contains(file.uri.pathSegments.last), reason: path);
    }
  });

  test('Android: нет интернета и копий в облако, есть движок озвучки', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, isNot(contains('android.permission.INTERNET')));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android.intent.action.TTS_SERVICE'));
    expect(manifest, contains('android:label="Айла"'));
  });

  testWidgets('телефон: доска и игры на главном экране без прокрутки', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _phoneView(tester);
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    final height = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    for (final text in ['Доска общения', 'НАЧАТЬ ПУТЕШЕСТВИЕ', 'Настройки']) {
      final rect = tester.getRect(find.textContaining(text).first);
      expect(rect.bottom, lessThan(height - 80), reason: text);
    }
  });

  testWidgets('удаление профиля: данные и журнал этого ребёнка', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await AppState.load();
    state.addProfile(name: 'Первый', age: 5, language: AppLanguage.ru);
    state.logPhrase(text: 'Я хочу яблоко', cards: 2);
    state.addProfile(name: 'Второй', age: 6, language: AppLanguage.ru);
    state.logPhrase(text: 'Я хочу мяч', cards: 2);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await tester.pumpAndSettle();

    // «Отмена» ничего не удаляет.
    await tester.tap(find.text('Удалить текущий профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить профиль «Второй»?'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(state.profiles.length, 2);

    await tester.tap(find.text('Удалить текущий профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(state.profiles.map((p) => p.name), ['Первый']);
    expect(state.activeProfile!.name, 'Первый');
    expect(state.journalEntries.map((JournalEntry e) => e.text), ['Я хочу яблоко']);

    final reloaded = await AppState.load();
    expect(reloaded.profiles.length, 1);
    expect(reloaded.journalEntries.length, 1);

    // Последний профиль: приложение начинается с приветствия.
    await tester.tap(find.text('Удалить текущий профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(state.hasProfile, isFalse);
    expect(find.text('Начать'), findsOneWidget);
  });

  testWidgets('Айла на главном экране: анимация с прозрачным фоном', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    expect(find.byType(AilaHello), findsOneWidget);

    // Файл читается как анимация из многих кадров, угол кадра прозрачный.
    final bytes = File('assets/aila_hello.png').readAsBytesSync();
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      expect(codec.frameCount, greaterThan(30));
      final frame = (await codec.getNextFrame()).image;
      final pixels = (await frame.toByteData())!;
      expect(pixels.getUint8(3), 0);
      final center = (frame.height ~/ 2 * frame.width + frame.width ~/ 2) * 4;
      expect(pixels.getUint8(center + 3), greaterThan(250));
    });
  });

  testWidgets('гардероб на языке профиля, кнопки «Профиль» нет', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.kk);
    state.setPin('1234');
    await tester.pumpWidget(MyApp(appState: state));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person), findsNothing);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const WardrobeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Айланың киім шкафы'), findsOneWidget);
    expect(find.text('Күлгін худи'), findsOneWidget);
    expect(find.text('Гардероб Айлы'), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('все выражения Айлы на месте и с прозрачным фоном', (tester) async {
    await tester.runAsync(() async {
      for (final mood in AilaMood.values) {
        final bytes = File(mood.asset).readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = (await codec.getNextFrame()).image;
        final pixels = (await frame.toByteData())!;
        expect(pixels.getUint8(3), 0, reason: '${mood.name}: угол не прозрачный');
        final centre = (frame.height ~/ 2 * frame.width + frame.width ~/ 2) * 4;
        expect(pixels.getUint8(centre + 3), greaterThan(200), reason: mood.name);
      }
    });
  });
}

void _phoneView(WidgetTester tester) {
  // Обычный телефон: 1080×2340 точек при плотности 2,75.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}
