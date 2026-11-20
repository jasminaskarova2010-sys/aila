import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/support_contacts.dart';
import 'package:aila_app/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('экран поддержки: контакты только из файла настроек',
      (tester) async {
    await tester.pumpWidget(AppLocaleScope(
      controller: LocaleController(),
      child: const MaterialApp(home: SupportScreen()),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Без --dart-define-from-file контактов нет и строк с ними тоже.
    for (final value in [kSupportPhone1, kSupportPhone2, kSupportEmail]) {
      if (value.isEmpty) continue;
      expect(find.text(value), findsOneWidget);
    }
    if (kSupportPhone1.isEmpty && kSupportEmail.isEmpty) {
      expect(find.byIcon(Icons.phone), findsNothing);
      expect(find.byIcon(Icons.email), findsNothing);
    }
  });
}
