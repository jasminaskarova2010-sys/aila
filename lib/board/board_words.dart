// lib/board/board_words.dart

/// Фаза доски. Хранится в профиле ребёнка, меняется родителем за PIN.
enum BoardPhase { iiiA, iiiB, iv, ivPlus, v, vi }

extension BoardPhaseChecks on BoardPhase {
  /// С фазы IV ребёнок собирает фразу в полоске.
  bool get hasStrip => index >= BoardPhase.iv.index;
  bool get hasDescriptions => index >= BoardPhase.ivPlus.index;
  bool get hasAskButton => index >= BoardPhase.v.index;
  bool get hasSeeQuestion => this == BoardPhase.vi;

  /// Короткое название для отчёта.
  String get code {
    switch (this) {
      case BoardPhase.iiiA:
        return 'III-A';
      case BoardPhase.iiiB:
        return 'III-B';
      case BoardPhase.iv:
        return 'IV';
      case BoardPhase.ivPlus:
        return 'IV+';
      case BoardPhase.v:
        return 'V';
      case BoardPhase.vi:
        return 'VI';
    }
  }
}

enum BoardCategory {
  home,
  food,
  drinks,
  toys,
  actions,
  people,
  places,
  feelings,
  descriptions,
  starters,
}

/// Порядок кнопок на нижней панели (после «Домой»).
const List<BoardCategory> kBoardCategoryOrder = [
  BoardCategory.food,
  BoardCategory.drinks,
  BoardCategory.toys,
  BoardCategory.actions,
  BoardCategory.people,
  BoardCategory.places,
  BoardCategory.feelings,
  BoardCategory.descriptions,
];

enum WordKind { starter, noun, verb, adjective, social, feeling }

/// Одно слово доски: стартовое или добавленное родителем. Подпись берётся из
/// `S.boardLabel`, картинка — из `PictogramRepository`, экраны не знают,
/// откуда они.
class BoardWord {
  final String id;
  final BoardCategory category;
  final WordKind kind;

  /// Для описаний: размер в озвучке идёт раньше цвета («большой красный»).
  final bool isSize;

  // Только у карточек родителя.
  final String? customLabel;
  final String? imageFile;
  final String? audioFile;

  const BoardWord(
    this.id,
    this.category,
    this.kind, {
    this.isSize = false,
    this.customLabel,
    this.imageFile,
    this.audioFile,
  });

  bool get isParentCard => customLabel != null;

  /// Предмет, человек или действие: то, что можно попросить.
  bool get isRequestable =>
      kind == WordKind.noun ||
      kind == WordKind.verb ||
      kind == WordKind.adjective;
}

const _s = WordKind.social;
const _n = WordKind.noun;
const _v = WordKind.verb;
const _f = WordKind.feeling;
const _a = WordKind.adjective;
const _st = WordKind.starter;

/// Стартовый набор: ровно 60 слов из ТЗ.
const List<BoardWord> kBoardWords = [
  BoardWord('i_want', BoardCategory.starters, _st),
  BoardWord('i_see', BoardCategory.starters, _st),
  BoardWord('i_hear', BoardCategory.starters, _st),
  BoardWord('i_feel', BoardCategory.starters, _st),
  BoardWord('this_is', BoardCategory.starters, _st),
  BoardWord('yes', BoardCategory.home, _s),
  BoardWord('no', BoardCategory.home, _s),
  BoardWord('help', BoardCategory.home, _s),
  BoardWord('more', BoardCategory.home, _s),
  BoardWord('done', BoardCategory.home, _s),
  BoardWord('stop', BoardCategory.home, _s),
  BoardWord('break', BoardCategory.home, _s),
  BoardWord('hello', BoardCategory.home, _s),
  BoardWord('bye', BoardCategory.home, _s),
  BoardWord('thanks', BoardCategory.home, _s),
  BoardWord('water', BoardCategory.drinks, _n),
  BoardWord('juice', BoardCategory.drinks, _n),
  BoardWord('milk', BoardCategory.drinks, _n),
  BoardWord('apple', BoardCategory.food, _n),
  BoardWord('banana', BoardCategory.food, _n),
  BoardWord('cookie', BoardCategory.food, _n),
  BoardWord('bread', BoardCategory.food, _n),
  BoardWord('porridge', BoardCategory.food, _n),
  BoardWord('ice_cream', BoardCategory.food, _n),
  BoardWord('ball', BoardCategory.toys, _n),
  BoardWord('toy_car', BoardCategory.toys, _n),
  BoardWord('blocks', BoardCategory.toys, _n),
  BoardWord('bubbles', BoardCategory.toys, _n),
  BoardWord('book', BoardCategory.toys, _n),
  BoardWord('cartoon', BoardCategory.toys, _n),
  BoardWord('draw', BoardCategory.toys, _v),
  BoardWord('music', BoardCategory.toys, _n),
  BoardWord('eat', BoardCategory.actions, _v),
  BoardWord('drink', BoardCategory.actions, _v),
  BoardWord('play', BoardCategory.actions, _v),
  BoardWord('go', BoardCategory.actions, _v),
  BoardWord('sleep', BoardCategory.actions, _v),
  BoardWord('wash_hands', BoardCategory.actions, _v),
  BoardWord('toilet', BoardCategory.actions, _n),
  BoardWord('open', BoardCategory.actions, _v),
  BoardWord('mom', BoardCategory.people, _n),
  BoardWord('dad', BoardCategory.people, _n),
  BoardWord('grandma', BoardCategory.people, _n),
  BoardWord('grandpa', BoardCategory.people, _n),
  BoardWord('brother', BoardCategory.people, _n),
  BoardWord('sister', BoardCategory.people, _n),
  BoardWord('me', BoardCategory.people, _n),
  BoardWord('good', BoardCategory.feelings, _f),
  BoardWord('bad', BoardCategory.feelings, _f),
  BoardWord('hurts', BoardCategory.feelings, _f),
  BoardWord('tired', BoardCategory.feelings, _f),
  BoardWord('sad', BoardCategory.feelings, _f),
  BoardWord('angry', BoardCategory.feelings, _f),
  BoardWord('scared', BoardCategory.feelings, _f),
  BoardWord('big', BoardCategory.descriptions, _a, isSize: true),
  BoardWord('small', BoardCategory.descriptions, _a, isSize: true),
  BoardWord('red', BoardCategory.descriptions, _a),
  BoardWord('blue', BoardCategory.descriptions, _a),
  BoardWord('yellow', BoardCategory.descriptions, _a),
  BoardWord('green', BoardCategory.descriptions, _a),
];

/// Закреплённая строка, видна на любой фазе и не скрывается.
const List<String> kPinnedWordIds = ['toilet', 'hurts', 'help', 'stop', 'break'];

/// В ТЗ стартовые фразы «видны с фазы IV», а «Я вижу», «Я слышу» и «Это»
/// открываются в фазе VI. До неё в строке только просьба и чувство.
List<String> starterIdsFor(BoardPhase phase) {
  if (!phase.hasStrip) return const [];
  if (phase == BoardPhase.vi) {
    return const ['i_want', 'i_see', 'i_hear', 'i_feel', 'this_is'];
  }
  return const ['i_want', 'i_feel'];
}

/// Любимые предметы нового профиля; родитель меняет их в настройках.
const List<String> kDefaultFavoriteIds = ['apple', 'ball', 'water'];

/// Нейтральные предметы для второй карточки фазы III-A (порядок постоянный).
const List<String> kNeutralWordIds = ['book', 'bread', 'blocks', 'milk'];

BoardWord? boardWordById(String id) {
  for (final word in kBoardWords) {
    if (word.id == id) return word;
  }
  return null;
}

/// Карточка, которую родитель добавил сам: фото, подпись, запись голоса.
/// В профиле лежат только имена файлов, сами файлы — в папке `ParentMedia`.
class ParentCard {
  final String id;
  final String label;
  final BoardCategory category;
  final String imageFile;
  final String? audioFile;

  const ParentCard({
    required this.id,
    required this.label,
    required this.category,
    required this.imageFile,
    this.audioFile,
  });

  BoardWord toWord() => BoardWord(
    id,
    category,
    WordKind.noun,
    customLabel: label,
    imageFile: imageFile,
    audioFile: audioFile,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'category': category.name,
    'imageFile': imageFile,
    'audioFile': audioFile,
  };

  factory ParentCard.fromJson(Map<String, dynamic> json) => ParentCard(
    id: json['id'] as String,
    label: json['label'] as String,
    category: BoardCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => BoardCategory.toys,
    ),
    imageFile: json['imageFile'] as String,
    audioFile: json['audioFile'] as String?,
  );
}
