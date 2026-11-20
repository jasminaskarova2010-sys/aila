// lib/games/game_models.dart

import 'dart:math';

import 'package:flutter/material.dart';

import '../board/board_model.dart';
import '../board/board_words.dart';
import '../board/phrase_builder.dart';
import '../board/pictogram_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';

enum GameKind { choice, order, categorize, speak, findPicture, buildPhrase }

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

/// Один раунд «Найди картинку».
class FindRound {
  final BoardWord target;
  final List<BoardWord> options;

  const FindRound(this.target, this.options);
}

class GameStep {
  /// Постоянный номер задания: по нему хранится прохождение, поэтому он не
  /// меняется, даже если задание переставить или скрыть.
  final int id;

  /// Номер на экране (с единицы), зависит от того, какие задания доступны.
  int index = 0;

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

  // Найди картинку
  final List<FindRound> findRounds;

  // Собери фразу: нужные карточки по порядку фразы и лишние карточки
  final List<BoardWord> phraseWords;
  final List<BoardWord> phrasePool;

  final String successTitle;
  final String successBody;

  GameStep({
    required this.id,
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
    this.findRounds = const [],
    this.phraseWords = const [],
    this.phrasePool = const [],
    required this.successTitle,
    required this.successBody,
  });
}

/// Сколько карточек в «Найди картинку» на каждой фазе.
int findCardCount(BoardPhase phase) {
  switch (phase) {
    case BoardPhase.iiiA:
      return 2;
    case BoardPhase.iiiB:
      return 3;
    case BoardPhase.iv:
    case BoardPhase.ivPlus:
      return 4;
    case BoardPhase.v:
      return 5;
    case BoardPhase.vi:
      return 6;
  }
}

const int _findRoundCount = 3;
const int _minOptions = 2;

Widget Function(double size) _picture(BoardWord word) =>
    (size) => PictogramRepository.image(word, size);

GameStep? _findPictureStep(S s, BoardModel model, Random random) {
  final pool = model.gameObjects;
  if (pool.length < _minOptions) return null;
  final count = min(findCardCount(model.phase), pool.length);
  final targets = pool.toList()..shuffle(random);
  final rounds = <FindRound>[];
  for (final target in targets.take(_findRoundCount)) {
    final others = pool.where((w) => w != target).toList()..shuffle(random);
    final options = [target, ...others.take(count - 1)]..shuffle(random);
    rounds.add(FindRound(target, options));
  }
  return GameStep(
    id: 8,
    title: s.gameFindTitle,
    subtitle: s.gameFindSubtitle,
    kind: GameKind.findPicture,
    findRounds: rounds,
    successTitle: s.gameWellDone,
    successBody: s.gameFindSuccess,
  );
}

GameStep? _buildPhraseStep(S s, BoardModel model, Random random) {
  if (!model.phase.hasStrip) return null;
  final objects = model.gameObjects.toList()..shuffle(random);
  if (objects.isEmpty) return null;
  final target = objects.first;
  final starter = boardWordById(model.phase == BoardPhase.vi ? 'i_see' : 'i_want')!;
  final descriptions = model.phase == BoardPhase.ivPlus
      ? (model.visibleDescriptions.toList()..shuffle(random))
      : const <BoardWord>[];
  final words = [starter, ...descriptions.take(1), target];
  final extras = [...objects.skip(1).take(2), ...descriptions.skip(1).take(1)];
  return GameStep(
    id: 9,
    title: s.gamePhraseTitle,
    subtitle: s.gamePhraseSubtitle,
    kind: GameKind.buildPhrase,
    phraseWords: words,
    phrasePool: [...words, ...extras]..shuffle(random),
    successTitle: s.gameWellDone,
    successBody: s.gamePhraseSuccess,
  );
}

GameStep? _sortStep(S s, BoardModel model, Random random) {
  List<BoardWord> pick(BoardCategory category) {
    final words = model.gameObjects.where((w) => w.category == category).toList()
      ..shuffle(random);
    return words.take(3).toList();
  }

  final food = pick(BoardCategory.food);
  final toys = pick(BoardCategory.toys);
  if (food.length < _minOptions || toys.length < _minOptions) return null;
  return GameStep(
    id: 4,
    title: s.gameSortTitle,
    subtitle: s.gameSortSubtitle,
    kind: GameKind.categorize,
    categoryALabel: s.boardCategoryName(BoardCategory.food),
    categoryBLabel: s.boardCategoryName(BoardCategory.toys),
    categoryAPictogramBuilder: _picture(food.first),
    categoryBPictogramBuilder: _picture(toys.first),
    categorizeItems: [
      for (final word in food)
        CategorizeItemData(pictogramBuilder: _picture(word), belongsToA: true),
      for (final word in toys)
        CategorizeItemData(pictogramBuilder: _picture(word), belongsToA: false),
    ],
    successTitle: s.gameGreatWork,
    successBody: s.gameSortSuccess,
  );
}

GameStep? _whatSaysStep(S s, BoardModel model, Random random) {
  final pool = model.gameObjects.toList()..shuffle(random);
  if (pool.length < _minOptions) return null;
  final options = pool.take(4).toList();
  final target = options.first;
  options.shuffle(random);
  return GameStep(
    id: 5,
    title: s.gameSaysTitle,
    subtitle: s.gameSaysSubtitle,
    kind: GameKind.choice,
    promptSpeech: buildPhrase([boardWordById('i_want')!, target], s.lang),
    options: [
      for (final word in options)
        ChoiceOption(pictogramBuilder: _picture(word), label: s.boardLabel(word)),
    ],
    correctIndex: options.indexOf(target),
    successTitle: s.gameClever,
    successBody: s.gameSaysSuccess(s.boardLabel(target)),
  );
}

GameStep? _repeatStep(S s, BoardModel model) {
  final pool = model.gameObjects;
  if (pool.isEmpty) return null;
  final target = pool.firstWhere((w) => w.id == 'water', orElse: () => pool.first);
  return GameStep(
    id: 6,
    title: s.gameRepeatTitle,
    subtitle: s.gameRepeatSubtitle,
    kind: GameKind.speak,
    promptPictogramBuilder: _picture(target),
    speakPhrase: buildPhrase([boardWordById('i_want')!, target], s.lang),
    successTitle: s.gameListening,
    successBody: s.gameRepeatSuccess,
  );
}

/// Задания дня для этого профиля на его языке. Игры на словах доски берут только
/// карточки, которые родитель не скрыл; если их не хватает, задание пропускается.
List<GameStep> buildGameSteps(S s, BoardModel model, {Random? random}) {
  final rnd = random ?? Random();

  final happy = GameStep(
    id: 0,
    title: s.gameHappyTitle,
    subtitle: s.gameHappySubtitle,
    kind: GameKind.choice,
    options: const [
      ChoiceOption(imagePath: 'assets/games/emotions/sad_child.PNG'),
      ChoiceOption(imagePath: 'assets/games/emotions/happy_child.PNG'),
      ChoiceOption(imagePath: 'assets/games/emotions/angry_child.PNG'),
    ],
    correctIndex: 1,
    successTitle: s.gameWellDone,
    successBody: s.gameHappySuccess,
  );

  final story = GameStep(
    id: 1,
    title: s.gameStoryTitle,
    subtitle: s.gameStorySubtitle,
    kind: GameKind.choice,
    promptImagePath: 'assets/games/social/shop_scene.PNG',
    options: [
      ChoiceOption(
        imagePath: 'assets/games/social/waiting_in_line.PNG',
        label: s.gameStoryWait,
      ),
      ChoiceOption(
        imagePath: 'assets/games/social/shouting_child.PNG',
        label: s.gameStoryShout,
      ),
      ChoiceOption(
        imagePath: 'assets/games/social/running_child.PNG',
        label: s.gameStoryRun,
      ),
    ],
    correctIndex: 0,
    successTitle: s.gameGreat,
    successBody: s.gameStorySuccess,
  );

  List<OrderItemData> sequence() => [
    OrderItemData(
      imagePath: 'assets/games/daily-life/waking_up.PNG',
      label: s.gameOrderWake,
    ),
    OrderItemData(
      imagePath: 'assets/games/daily-life/brushing_teeth.PNG',
      label: s.gameOrderTeeth,
    ),
    OrderItemData(
      imagePath: 'assets/games/daily-life/eating_breakfast.PNG',
      label: s.gameOrderBreakfast,
    ),
    OrderItemData(
      imagePath: 'assets/games/daily-life/getting_dressed.PNG',
      label: s.gameOrderDress,
    ),
  ];

  final order = GameStep(
    id: 3,
    title: s.gameOrderTitle,
    subtitle: s.gameOrderSubtitle,
    kind: GameKind.order,
    referenceItems: sequence(),
    orderItems: sequence(),
    successTitle: s.gameGreat,
    successBody: s.gameOrderSuccess,
  );

  final whatToDo = GameStep(
    id: 7,
    title: s.gameDoTitle,
    subtitle: s.gameDoSubtitle,
    kind: GameKind.choice,
    promptImagePath: 'assets/games/social/comforting_friend.PNG',
    promptSpeech: s.gameDoSpeech,
    options: [
      ChoiceOption(
        number: 1,
        label: s.gameDoLaugh,
        imagePath: 'assets/games/social/laughing_at_friend.jpg',
      ),
      ChoiceOption(
        number: 2,
        label: s.gameDoHelp,
        imagePath: 'assets/games/social/helping_friend.jpg',
      ),
      ChoiceOption(
        number: 3,
        label: s.gameDoIgnore,
        imagePath: 'assets/games/social/walking_away.jpg',
      ),
    ],
    correctIndex: 1,
    successTitle: s.gameGreat,
    successBody: s.gameDoSuccess,
  );

  final steps = <GameStep>[
    ?_findPictureStep(s, model, rnd),
    happy,
    story,
    order,
    ?_sortStep(s, model, rnd),
    ?_whatSaysStep(s, model, rnd),
    ?_buildPhraseStep(s, model, rnd),
    ?_repeatStep(s, model),
    whatToDo,
  ];
  for (var i = 0; i < steps.length; i++) {
    steps[i].index = i + 1;
  }
  return steps;
}

/// Задания для текущего профиля и языка.
List<GameStep> gameStepsFor(BuildContext context) {
  final profile = AppStateScope.of(context).activeProfile;
  if (profile == null) return const [];
  return buildGameSteps(S.of(context), BoardModel(profile));
}
