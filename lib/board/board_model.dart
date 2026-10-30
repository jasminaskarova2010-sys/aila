// lib/board/board_model.dart

import '../state/app_state.dart';
import 'board_words.dart';

/// Что показать на доске для этого профиля. Порядок всегда постоянный (П4).
class BoardModel {
  final ChildProfile profile;

  const BoardModel(this.profile);

  BoardPhase get phase => profile.boardPhase;

  List<BoardWord> get _allWords => [
    ...kBoardWords,
    ...profile.parentCards.map((c) => c.toWord()),
  ];

  BoardWord? _byId(String id) {
    for (final word in _allWords) {
      if (word.id == id) return word;
    }
    return null;
  }

  bool _visible(BoardWord word) => !profile.hiddenWordIds.contains(word.id);

  List<BoardWord> get favorites => [
    for (final id in profile.favoriteWordIds)
      if (_byId(id) case final word? when _visible(word)) word,
  ];

  /// То, что можно выбрать в «Любимые предметы»: предметы и карточки родителя.
  List<BoardWord> get favoriteOptions =>
      _allWords.where((w) => w.kind == WordKind.noun).toList();

  List<BoardWord> get pinned => [
    for (final id in kPinnedWordIds) boardWordById(id)!,
  ];

  List<BoardWord> get starters => [
    for (final id in starterIdsFor(phase)) boardWordById(id)!,
  ];

  /// Предметы для фазы III: сначала любимые, потом остальные по порядку.
  List<BoardWord> get _objects {
    final objects = favorites.toList();
    for (final word in _allWords) {
      if (word.kind == WordKind.noun &&
          word.category != BoardCategory.people &&
          !kPinnedWordIds.contains(word.id) &&
          _visible(word) &&
          !objects.contains(word)) {
        objects.add(word);
      }
    }
    return objects;
  }

  /// Фаза III-A: любимый предмет и нейтральный.
  List<BoardWord> get twoCards {
    final favorite = favorites.isEmpty ? boardWordById('apple')! : favorites.first;
    final neutral = kNeutralWordIds
        .map((id) => boardWordById(id)!)
        .firstWhere(
          (w) => w.id != favorite.id,
          orElse: () => boardWordById('book')!,
        );
    return [favorite, neutral];
  }

  bool get showsCategories {
    if (phase == BoardPhase.iiiA) return false;
    if (phase == BoardPhase.iiiB) return profile.boardCategoriesEnabled;
    return true;
  }

  /// Кнопки нижней панели, не считая «Домой». «Места» появляются, только когда
  /// родитель добавит туда карточки.
  List<BoardCategory> get categories => [
    for (final category in kBoardCategoryOrder)
      if (_categoryAvailable(category)) category,
  ];

  bool _categoryAvailable(BoardCategory category) {
    if (profile.hiddenCategories.contains(category)) return false;
    if (category == BoardCategory.descriptions) return phase.hasDescriptions;
    if (category == BoardCategory.places) {
      return wordsIn(BoardCategory.places).isNotEmpty;
    }
    return true;
  }

  List<BoardWord> wordsIn(BoardCategory category) {
    if (category == BoardCategory.home) {
      final social = _allWords.where(
        (w) =>
            w.category == BoardCategory.home &&
            !kPinnedWordIds.contains(w.id) &&
            _visible(w),
      );
      return [...social, ...favorites];
    }
    return _allWords
        .where((w) => w.category == category && _visible(w))
        .toList();
  }

  /// Карточки в сетке с учётом фазы.
  List<BoardWord> gridWords(BoardCategory category) {
    switch (phase) {
      case BoardPhase.iiiA:
        return twoCards;
      case BoardPhase.iiiB:
        final count = profile.boardCardCount;
        final words = profile.boardCategoriesEnabled
            ? wordsIn(category)
            : _objects;
        return words.take(count).toList();
      case BoardPhase.iv:
      case BoardPhase.ivPlus:
      case BoardPhase.v:
      case BoardPhase.vi:
        return wordsIn(category);
    }
  }
}
