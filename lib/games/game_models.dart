// lib/games/game_models.dart

import 'package:flutter/material.dart';
import '../pecs/pictograms.dart' show ApplePictogram, BananaPictogram;
import 'game_pictograms.dart';

enum GameKind { choice, order, categorize, speak }

/// Визуальный контент варианта ответа. Приоритет отображения:
/// imagePath (реальное фото) → pictogramBuilder (простая иллюстрация,
/// допустима для нейтральных предметов) → placeholderNote (честная
/// заглушка, когда нужен реальный снимок человека/эмоции/ситуации,
/// а его пока нет).
class ChoiceOption {
  final String? imagePath;
  final Widget Function(double size)? pictogramBuilder;
  final String? placeholderNote;
  final String? label;
  final int? number;

  const ChoiceOption({
    this.imagePath,
    this.pictogramBuilder,
    this.placeholderNote,
    this.label,
    this.number,
  });
}

class OrderItemData {
  final String? imagePath;
  final Widget Function(double size)? pictogramBuilder;
  final String label;

  const OrderItemData({this.imagePath, this.pictogramBuilder, required this.label});
}

class CategorizeItemData {
  final Widget Function(double size) pictogramBuilder;
  final bool belongsToA;

  const CategorizeItemData({required this.pictogramBuilder, required this.belongsToA});
}

class GameStep {
  final int index;
  final String title;
  final String subtitle;
  final GameKind kind;

  // Prompt panel (choice / speak games)
  final String? promptImagePath;
  final Widget Function(double size)? promptPictogramBuilder;
  final String? promptPlaceholderNote;
  final String? promptCaption;
  final String? promptSpeech;

  // Choice game
  final List<ChoiceOption> options;
  final int correctIndex;

  // Order game
  final List<OrderItemData> orderItems;
  final List<OrderItemData> referenceItems;

  // Categorize game
  final String categoryALabel;
  final String categoryBLabel;
  final Widget Function(double size)? categoryAPictogramBuilder;
  final Widget Function(double size)? categoryBPictogramBuilder;
  final List<CategorizeItemData> categorizeItems;

  // Speak game
  final String speakPhrase;

  final String successTitle;
  final String successBody;

  const GameStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.promptImagePath,
    this.promptPictogramBuilder,
    this.promptPlaceholderNote,
    this.promptCaption,
    this.promptSpeech,
    this.options = const [],
    this.correctIndex = -1,
    this.orderItems = const [],
    this.referenceItems = const [],
    this.categoryALabel = '',
    this.categoryBLabel = '',
    this.categoryAPictogramBuilder,
    this.categoryBPictogramBuilder,
    this.categorizeItems = const [],
    this.speakPhrase = '',
    required this.successTitle,
    required this.successBody,
  });
}

final List<GameStep> kGameSteps = [
  const GameStep(
    index: 1,
    title: 'Кто счастлив?',
    subtitle: 'Выбери мальчика, который счастлив.',
    kind: GameKind.choice,
    options: [
      ChoiceOption(imagePath: 'assets/games/emotions/sad_child.PNG'),
      ChoiceOption(imagePath: 'assets/games/emotions/happy_child.PNG'),
      ChoiceOption(imagePath: 'assets/games/emotions/angry_child.PNG'),
    ],
    correctIndex: 1,
    successTitle: 'Молодец!',
    successBody: 'Ты справился!',
  ),
  const GameStep(
    index: 2,
    title: 'Социальная история',
    subtitle: 'Девочка пришла в магазин. Что нужно сделать?',
    kind: GameKind.choice,
    promptImagePath: 'assets/games/social/shop_scene.PNG',
    options: [
      ChoiceOption(
        imagePath: 'assets/games/social/waiting_in_line.PNG',
        label: 'Ждать очередь',
      ),
      ChoiceOption(
        imagePath: 'assets/games/social/shouting_child.PNG',
        label: 'Кричать',
      ),
      ChoiceOption(
        imagePath: 'assets/games/social/running_child.PNG',
        label: 'Убежать',
      ),
    ],
    correctIndex: 0,
    successTitle: 'Отлично!',
    successBody: 'Ждать очередь — это правильное и вежливое поведение!',
  ),
  GameStep(
    index: 3,
    title: 'Куда смотрит Айла?',
    subtitle: 'Посмотри, куда показывает Айла. Нажми на правильный объект.',
    kind: GameKind.choice,
    promptPlaceholderNote:
        'Нужно фото: ребёнок показывает пальцем в небо (совместное внимание)',
    promptCaption: 'Посмотри туда!',
    options: [
      ChoiceOption(pictogramBuilder: (size) => PlanePictogram(size: size)),
      ChoiceOption(pictogramBuilder: (size) => BalloonPictogram(size: size)),
      ChoiceOption(pictogramBuilder: (size) => BirdPictogram(size: size)),
    ],
    correctIndex: 0,
    successTitle: 'Молодец!',
    successBody: 'Айла показывает на самолёт! Ты отлично справился!',
  ),
  const GameStep(
    index: 4,
    title: 'Запомни последовательность',
    subtitle:
        'Посмотри на последовательность действий.\nЗатем повтори её в правильном порядке.',
    kind: GameKind.order,
    referenceItems: [
      OrderItemData(
          imagePath: 'assets/games/daily-life/waking_up.PNG', label: 'Проснуться'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/brushing_teeth.PNG',
          label: 'Почистить зубы'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/eating_breakfast.PNG',
          label: 'Позавтракать'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/getting_dressed.PNG', label: 'Одеться'),
    ],
    orderItems: [
      OrderItemData(
          imagePath: 'assets/games/daily-life/waking_up.PNG', label: 'Проснуться'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/brushing_teeth.PNG',
          label: 'Почистить зубы'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/eating_breakfast.PNG',
          label: 'Позавтракать'),
      OrderItemData(
          imagePath: 'assets/games/daily-life/getting_dressed.PNG', label: 'Одеться'),
    ],
    successTitle: 'Отлично!',
    successBody: 'Ты отлично запоминаешь последовательность!',
  ),
  GameStep(
    index: 5,
    title: 'Что относится к фруктам?',
    subtitle: 'Перетащи картинки в правильную корзину.',
    kind: GameKind.categorize,
    categoryALabel: 'Фрукты',
    categoryBLabel: 'Игрушки',
    categoryAPictogramBuilder: (size) => ApplePictogram(size: size),
    categoryBPictogramBuilder: (size) => Icon(Icons.toys, size: size, color: const Color(0xFF4A7FBF)),
    categorizeItems: [
      CategorizeItemData(
          pictogramBuilder: (size) => ApplePictogram(size: size), belongsToA: true),
      CategorizeItemData(
          pictogramBuilder: (size) => TeddyBearPictogram(size: size), belongsToA: false),
      CategorizeItemData(
          pictogramBuilder: (size) => BananaPictogram(size: size), belongsToA: true),
      CategorizeItemData(
          pictogramBuilder: (size) => BallPictogram(size: size), belongsToA: false),
      CategorizeItemData(
          pictogramBuilder: (size) => GrapesPictogram(size: size), belongsToA: true),
      CategorizeItemData(
          pictogramBuilder: (size) => CarPictogram(size: size), belongsToA: false),
    ],
    successTitle: 'Отличная работа!',
    successBody: 'Ты учишься сортировать предметы по категориям!',
  ),
  GameStep(
    index: 6,
    title: 'Что хочет сказать Айла?',
    subtitle: 'Послушай фразу и выбери картинку, которая подходит.',
    kind: GameKind.choice,
    promptPlaceholderNote:
        'Нужно фото: ребёнок просит игрушку (указывает или протягивает руку)',
    promptSpeech: 'Я хочу играть с мячом.',
    options: [
      ChoiceOption(pictogramBuilder: (size) => TeddyBearPictogram(size: size)),
      ChoiceOption(pictogramBuilder: (size) => BallPictogram(size: size)),
      ChoiceOption(pictogramBuilder: (size) => BookPictogram(size: size)),
      ChoiceOption(pictogramBuilder: (size) => CarPictogram(size: size)),
    ],
    correctIndex: 1,
    successTitle: 'Умница!',
    successBody: 'Мяч — это правильно! Давай продолжим!',
  ),
  const GameStep(
    index: 7,
    title: 'Повтори фразу',
    subtitle: 'Послушай фразу и повтори её.\nГовори чётко и спокойно.',
    kind: GameKind.speak,
    promptPlaceholderNote: 'Нужно фото: ребёнок пьёт воду из стакана',
    speakPhrase: 'Я хочу пить воду.',
    successTitle: 'Я тебя слушаю!',
    successBody: 'Отлично произнесено!',
  ),
  const GameStep(
    index: 8,
    title: 'Что делать?',
    subtitle: 'Послушай ситуацию и выбери лучший вариант.',
    kind: GameKind.choice,
    promptImagePath: 'assets/games/social/comforting_friend.PNG',
    promptSpeech: 'Друг упал на площадке и заплакал. Что ты будешь делать?',
    options: [
      ChoiceOption(
        number: 1,
        label: 'Посмеяться и уйти',
        placeholderNote: 'Нужно фото: ребёнок смеётся и уходит',
      ),
      ChoiceOption(
        number: 2,
        label: 'Подойти и помочь',
        placeholderNote: 'Нужно фото: ребёнок подходит и протягивает руку помощи',
      ),
      ChoiceOption(
        number: 3,
        label: 'Пройти мимо, как будто ничего не случилось',
        placeholderNote: 'Нужно фото: ребёнок проходит мимо, не реагируя',
      ),
    ],
    correctIndex: 1,
    successTitle: 'Отлично!',
    successBody: 'Подойти и помочь — это правильный выбор!',
  ),
];
