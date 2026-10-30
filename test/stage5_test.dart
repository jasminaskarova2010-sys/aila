// Проверки этапа 5 ТЗ: экран «О приложении», файлы сборки, тексты интерфейса.

import 'dart:io';

import 'package:aila_app/info_screen.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/state/app_state.dart';
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
}
