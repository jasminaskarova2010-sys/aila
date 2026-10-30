// Проверки этапа 2 ТЗ: доска общения, фазы, фразы, карточки родителя.

import 'dart:convert';
import 'dart:io';

import 'package:aila_app/board/board_screen.dart';
import 'package:aila_app/board/board_words.dart';
import 'package:aila_app/board/phrase_builder.dart';
import 'package:aila_app/board/pictogram_repository.dart';
import 'package:aila_app/l10n/app_language.dart';
import 'package:aila_app/l10n/board_labels.dart';
import 'package:aila_app/main.dart';
import 'package:aila_app/parent/board_settings_screen.dart';
import 'package:aila_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BoardWord w(String id) => boardWordById(id)!;

List<BoardWord> words(String ids) => ids.split(' ').map(w).toList();

void main() {
  group('стартовый набор', () {
    test('ровно 60 слов, у всех картинка и три подписи', () {
      expect(kBoardWords.length, 60);
      expect(kBoardWords.map((word) => word.id).toSet().length, 60);
      for (final word in kBoardWords) {
        for (final set in PictogramSet.values) {
          final path = PictogramRepository.assetPath(word.id, set: set);
          expect(File(path).existsSync(), isTrue, reason: path);
        }
        // Без подписи функция вернула бы сам id (по-английски они часто совпадают).
        expect(boardWordLabel(word.id, AppLanguage.ru), isNot(word.id));
        expect(boardWordLabel(word.id, AppLanguage.kk), isNot(word.id));
      }
    });

    test('manifest совпадает с тем, что показывает доска', () {
      final manifest = jsonDecode(
        File('assets/pictograms/arasaac/manifest.json').readAsStringSync(),
      );
      final entries = (manifest['words'] as List).cast<Map<String, dynamic>>();
      expect(entries.length, 60);
      for (final entry in entries) {
        final path = PictogramRepository.assetPath(entry['word'] as String);
        expect(
          path.contains('arasaac'),
          entry['source'] == 'arasaac',
          reason: entry['word'] as String,
        );
        expect(entry['id'], isNotNull);
      }
    });
  });

  group('фразы', () {
    String ru(String ids) => buildPhrase(words(ids), AppLanguage.ru);
    String en(String ids) => buildPhrase(words(ids), AppLanguage.en);
    String kk(String ids) => buildPhrase(words(ids), AppLanguage.kk);

    test('русский: падеж и род', () {
      expect(ru('i_want apple'), 'Я хочу яблоко');
      expect(ru('i_want water'), 'Я хочу воду');
      expect(ru('i_want big red ball'), 'Я хочу большой красный мяч');
      expect(ru('i_want big red toy_car'), 'Я хочу большую красную машинку');
      expect(ru('i_want small blue apple'), 'Я хочу маленькое синее яблоко');
      expect(ru('i_want big brother'), 'Я хочу большого брата');
      expect(ru('this_is big toy_car'), 'Это большая машинка');
      expect(ru('i_see mom'), 'Я вижу маму');
      expect(ru('i_want toilet'), 'Я хочу в туалет');
      expect(ru('i_want play'), 'Я хочу играть');
    });

    test('описания встают перед предметом в любом порядке нажатий', () {
      expect(ru('i_want ball red big'), 'Я хочу большой красный мяч');
      expect(ru('i_want red big ball'), 'Я хочу большой красный мяч');
    });

    test('чувства и социальные слова не ломают фразу', () {
      expect(ru('i_feel hurts'), 'Мне больно');
      expect(ru('i_feel tired'), 'Я устал');
      expect(ru('i_want hurts'), 'Больно');
      expect(ru('i_want apple thanks'), 'Я хочу яблоко, спасибо');
    });

    test('английский', () {
      expect(en('i_want apple'), 'I want an apple');
      expect(en('i_want big red ball'), 'I want a big red ball');
      expect(en('i_want water'), 'I want water');
      expect(en('i_want play'), 'I want to play');
      expect(en('i_see brother'), 'I see my brother');
      expect(en('i_feel sad'), 'I feel sad');
    });

    test('казахский: глагол в конце', () {
      expect(kk('i_want apple'), 'Мен алма қалаймын');
      expect(kk('i_want big red ball'), 'Мен үлкен қызыл доп қалаймын');
      expect(kk('i_want play'), 'Мен ойнағым келеді');
      expect(kk('this_is ball'), 'Бұл доп');
    });

    test('без начала: для подсказки взрослому', () {
      expect(
        buildPhrase(words('i_want water'), AppLanguage.ru, withStarter: false),
        'воду',
      );
    });
  });

  group('экран доски', () {
    late List<String> spoken;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      spoken = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
            call,
          ) async {
            if (call.method == 'speak') spoken.add(call.arguments as String);
            return 1;
          });
    });

    Future<AppState> openBoard(
      WidgetTester tester, {
      BoardPhase phase = BoardPhase.iv,
      AppLanguage language = AppLanguage.ru,
      Size size = const Size(1000, 1400),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final state = await AppState.load();
      state.addProfile(name: 'Айла', age: 5, language: language);
      state.setPin('1234');
      state.setBoardPhase(phase);
      await tester.pumpWidget(MyApp(appState: state));
      await tester.pumpAndSettle();
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute(builder: (_) => const BoardScreen()));
      await tester.pumpAndSettle();
      return state;
    }

    Future<void> finishHint(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    }

    testWidgets('фаза IV: «Я хочу яблоко» за 2 нажатия, звёзд нет', (
      tester,
    ) async {
      final state = await openBoard(tester);
      await tester.tap(find.text('яблоко').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, 'Я хочу яблоко');
      expect(
        find.text('Ребёнок просит: яблоко. Дайте и назовите вслух'),
        findsOneWidget,
      );
      expect(state.stars, 0);
      await finishHint(tester);
      expect(find.textContaining('Ребёнок просит'), findsNothing);
    });

    testWidgets('«Стереть»: последняя карточка, долгое нажатие — всё', (
      tester,
    ) async {
      await openBoard(tester);
      await tester.tap(find.text('яблоко').first);
      await tester.tap(find.text('да'));
      await tester.pumpAndSettle();
      expect(find.text('да'), findsNWidgets(2));
      await tester.tap(find.text('Стереть'));
      await tester.pumpAndSettle();
      expect(find.text('да'), findsOneWidget);
      expect(find.text('яблоко'), findsNWidgets(2));
      await tester.longPress(find.text('Стереть'));
      await tester.pumpAndSettle();
      expect(find.text('яблоко'), findsOneWidget);
      // «Я хочу» осталось в полоске и в строке стартовых фраз.
      expect(find.text('Я хочу'), findsNWidgets(2));
    });

    testWidgets('фаза III-A: две большие карточки, без полоски', (tester) async {
      await openBoard(tester, phase: BoardPhase.iiiA);
      expect(find.text('Сказать'), findsNothing);
      expect(find.text('Я хочу'), findsNothing);
      expect(find.text('яблоко'), findsOneWidget);
      expect(find.text('книга'), findsOneWidget);
      expect(find.text('Домой'), findsNothing);

      final card = tester.getSize(
        find
            .ancestor(
              of: find.text('яблоко'),
              matching: find.byType(BoardCardTile),
            )
            .first,
      );
      expect(card.width, greaterThan(200));

      await tester.tap(find.text('яблоко'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, 'яблоко');
      expect(find.textContaining('Ребёнок просит: яблоко'), findsOneWidget);
      await finishHint(tester);
    });

    testWidgets('закреплённая строка видна на всех фазах', (tester) async {
      for (final phase in BoardPhase.values) {
        final state = await openBoard(tester, phase: phase);
        for (final id in kPinnedWordIds) {
          expect(
            find.text(boardWordLabel(id, AppLanguage.ru)),
            findsWidgets,
            reason: '$phase $id',
          );
        }
        expect(state.activeProfile!.boardPhase, phase);
        await tester.pumpWidget(const SizedBox());
        SharedPreferences.setMockInitialValues({});
      }
    });

    testWidgets('фаза IV+: описания открыты и фраза собирается', (tester) async {
      await openBoard(tester, phase: BoardPhase.ivPlus);
      await tester.tap(find.text('Описания'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('большой'));
      await tester.tap(find.text('красный'));
      await tester.tap(find.text('Игрушки'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('мяч'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, 'Я хочу большой красный мяч');
      await finishHint(tester);
    });

    testWidgets('в фазе IV описаний нет', (tester) async {
      await openBoard(tester);
      expect(find.text('Описания'), findsNothing);
      expect(find.text('Задать вопрос'), findsNothing);
    });

    testWidgets('фаза V: «Задать вопрос»; фаза VI: «Что ты видишь?»', (
      tester,
    ) async {
      await openBoard(tester, phase: BoardPhase.v);
      expect(find.text('Что ты видишь?'), findsNothing);
      await tester.tap(find.text('Задать вопрос'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(spoken.last, 'Что ты хочешь?');

      await tester.pumpWidget(const SizedBox());
      SharedPreferences.setMockInitialValues({});
      await openBoard(tester, phase: BoardPhase.vi);
      await tester.tap(find.text('Что ты видишь?'));
      await tester.pumpAndSettle();
      expect(spoken.last, 'Что ты видишь?');
      // «Я вижу» встала в полоску и есть в строке стартовых фраз.
      expect(find.text('Я вижу'), findsNWidgets(2));
      expect(find.text('Я слышу'), findsOneWidget);
      expect(find.text('Это'), findsOneWidget);
      await tester.tap(find.text('мяч').first, warnIfMissed: false);
      await tester.tap(find.text('Игрушки'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('мяч').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, startsWith('Я вижу мяч'));
      expect(find.textContaining('Ребёнок говорит: я вижу мяч'), findsOneWidget);
      await finishHint(tester);
    });

    testWidgets('подсказку можно отключить', (tester) async {
      final state = await openBoard(tester);
      state.setAdultHintEnabled(false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('яблоко').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Ребёнок просит'), findsNothing);
    });

    testWidgets('скрытое слово и категория не показываются', (tester) async {
      final state = await openBoard(tester);
      state.setWordHidden('yes', true);
      state.setCategoryHidden(BoardCategory.food, true);
      await tester.pumpAndSettle();
      expect(find.text('да'), findsNothing);
      expect(find.text('Еда'), findsNothing);
    });

    testWidgets('язык меняет и подписи, и озвучку', (tester) async {
      final state = await openBoard(tester);
      expect(find.text('Сказать'), findsOneWidget);
      state.setLanguage(AppLanguage.kk);
      await tester.pumpAndSettle();
      expect(find.text('Айту'), findsOneWidget);
      await tester.tap(find.text('алма').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(spoken.last, 'алма');
      await tester.tap(find.text('Айту'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, 'Мен алма қалаймын');
      await finishHint(tester);
    });

    testWidgets('«Места» появляются, когда родитель добавит карточку', (
      tester,
    ) async {
      final state = await openBoard(tester);
      expect(find.text('Места'), findsNothing);
      state.addParentCard(
        const ParentCard(
          id: 'parent_1',
          label: 'Дача',
          category: BoardCategory.places,
          imageFile: 'none.jpg',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Места'), findsOneWidget);
      await tester.tap(find.text('Места'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Дача'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(spoken.last, 'Дача');
      await tester.tap(find.text('Сказать'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spoken.last, 'Я хочу Дача');
      await finishHint(tester);
    });

    testWidgets('настройки родителя: фаза, новая карточка, скрытие', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final state = await AppState.load();
      state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
      await tester.pumpWidget(MyApp(appState: state));
      await tester.pumpAndSettle();
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute(builder: (_) => const BoardSettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('III-A: две карточки'));
      await tester.pumpAndSettle();
      expect(state.activeProfile!.boardPhase, BoardPhase.iiiA);

      await tester.tap(find.text('III-B: больше карточек'));
      await tester.pumpAndSettle();
      expect(find.text('Карточек на экране: 6'), findsOneWidget);

      await tester.tap(find.text('Добавить карточку'));
      await tester.pumpAndSettle();
      expect(find.text('Подпись'), findsOneWidget);
      expect(tester.takeException(), isNull);
      nav.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Еда'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Показывать категорию'));
      await tester.pumpAndSettle();
      expect(state.activeProfile!.hiddenCategories, contains(BoardCategory.food));
    });

    testWidgets('телефон: на узком экране ничего не вылезает', (tester) async {
      for (final phase in BoardPhase.values) {
        await openBoard(tester, phase: phase, size: const Size(375, 760));
        expect(tester.takeException(), isNull, reason: '$phase');
        await tester.pumpWidget(const SizedBox());
        SharedPreferences.setMockInitialValues({});
      }
    });
  });

  test('карточка родителя и настройки доски сохраняются', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    state.addProfile(name: 'Айла', age: 5, language: AppLanguage.ru);
    state.setBoardPhase(BoardPhase.vi);
    state.setFavorite('toy_car', true);
    state.setWordHidden('yes', true);
    state.setCategoryHidden(BoardCategory.food, true);
    state.setBoardCardCount(12);
    state.setAdultHintEnabled(false);
    state.addParentCard(
      const ParentCard(
        id: 'parent_1',
        label: 'Мишка',
        category: BoardCategory.toys,
        imageFile: 'mishka.jpg',
        audioFile: 'mishka.m4a',
      ),
    );

    final profile = (await AppState.load()).activeProfile!;
    expect(profile.boardPhase, BoardPhase.vi);
    expect(profile.favoriteWordIds, contains('toy_car'));
    expect(profile.hiddenWordIds, contains('yes'));
    expect(profile.hiddenCategories, contains(BoardCategory.food));
    expect(profile.boardCardCount, 12);
    expect(profile.adultHintEnabled, isFalse);
    final card = profile.parentCards.single;
    expect(card.label, 'Мишка');
    expect(card.imageFile, 'mishka.jpg');
    expect(card.audioFile, 'mishka.m4a');
    expect(card.toWord().category, BoardCategory.toys);
  });
}
