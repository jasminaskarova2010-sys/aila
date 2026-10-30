// lib/state/app_state.dart

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../board/board_words.dart';
import '../journal/journal.dart';
import '../l10n/app_language.dart';
import '../survey/survey_data.dart';

/// Профиль одного ребёнка. У каждого ребёнка свои звёзды, наряды и
/// пройденные задания.
class ChildProfile {
  final String id;
  String name;
  int age;
  AppLanguage language;
  int stars;
  final Set<String> ownedOutfitIds;
  String equippedOutfitId;
  final Set<int> completedGameIndices;

  // Доска общения
  BoardPhase boardPhase;
  bool adultHintEnabled;
  int boardCardCount;
  bool boardCategoriesEnabled;
  final List<String> favoriteWordIds;
  final Set<String> hiddenWordIds;
  final Set<BoardCategory> hiddenCategories;
  final List<ParentCard> parentCards;

  /// Игры: перерыв после стольких заданий (3–5).
  int breakAfterTasks;

  // Опрос родителя
  List<SurveyAnswer> surveyAnswers;
  DateTime? lastSurveyAt;

  ChildProfile({
    required this.id,
    this.name = '',
    required this.age,
    required this.language,
    this.stars = 0,
    Set<String>? ownedOutfitIds,
    this.equippedOutfitId = 'default',
    Set<int>? completedGameIndices,
    // Пока нет опроса этапа 3, новый профиль начинает с фазы IV.
    this.boardPhase = BoardPhase.iv,
    this.adultHintEnabled = true,
    this.boardCardCount = 6,
    this.boardCategoriesEnabled = false,
    List<String>? favoriteWordIds,
    Set<String>? hiddenWordIds,
    Set<BoardCategory>? hiddenCategories,
    List<ParentCard>? parentCards,
    this.breakAfterTasks = 4,
    List<SurveyAnswer>? surveyAnswers,
    this.lastSurveyAt,
  }) : ownedOutfitIds = ownedOutfitIds ?? {'default'},
       completedGameIndices = completedGameIndices ?? {},
       favoriteWordIds = favoriteWordIds ?? List.of(kDefaultFavoriteIds),
       hiddenWordIds = hiddenWordIds ?? {},
       hiddenCategories = hiddenCategories ?? {},
       parentCards = parentCards ?? [],
       surveyAnswers = surveyAnswers ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'language': language.name,
    'stars': stars,
    'ownedOutfitIds': ownedOutfitIds.toList(),
    'equippedOutfitId': equippedOutfitId,
    'completedGameIndices': completedGameIndices.toList(),
    'boardPhase': boardPhase.name,
    'adultHintEnabled': adultHintEnabled,
    'boardCardCount': boardCardCount,
    'boardCategoriesEnabled': boardCategoriesEnabled,
    'favoriteWordIds': favoriteWordIds,
    'hiddenWordIds': hiddenWordIds.toList(),
    'hiddenCategories': hiddenCategories.map((c) => c.name).toList(),
    'parentCards': parentCards.map((c) => c.toJson()).toList(),
    'breakAfterTasks': breakAfterTasks,
    'surveyAnswers': surveyAnswers.map((a) => a.name).toList(),
    'lastSurveyAt': lastSurveyAt?.toIso8601String(),
  };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    age: json['age'] as int? ?? 4,
    language: AppLanguage.values.firstWhere(
      (l) => l.name == json['language'],
      orElse: () => AppLanguage.ru,
    ),
    stars: json['stars'] as int? ?? 0,
    ownedOutfitIds: {
      'default',
      ...(json['ownedOutfitIds'] as List? ?? []).cast<String>(),
    },
    equippedOutfitId: json['equippedOutfitId'] as String? ?? 'default',
    completedGameIndices: (json['completedGameIndices'] as List? ?? [])
        .cast<int>()
        .toSet(),
    boardPhase: BoardPhase.values.firstWhere(
      (p) => p.name == json['boardPhase'],
      orElse: () => BoardPhase.iv,
    ),
    adultHintEnabled: json['adultHintEnabled'] as bool? ?? true,
    boardCardCount: json['boardCardCount'] as int? ?? 6,
    boardCategoriesEnabled: json['boardCategoriesEnabled'] as bool? ?? false,
    favoriteWordIds: (json['favoriteWordIds'] as List?)?.cast<String>().toList(),
    hiddenWordIds: (json['hiddenWordIds'] as List? ?? [])
        .cast<String>()
        .toSet(),
    hiddenCategories: {
      for (final name in (json['hiddenCategories'] as List? ?? []).cast<String>())
        for (final category in BoardCategory.values)
          if (category.name == name) category,
    },
    parentCards: (json['parentCards'] as List? ?? [])
        .map((c) => ParentCard.fromJson(c as Map<String, dynamic>))
        .toList(),
    breakAfterTasks: json['breakAfterTasks'] as int? ?? 4,
    surveyAnswers: [
      for (final name in (json['surveyAnswers'] as List? ?? []).cast<String>())
        for (final answer in SurveyAnswer.values)
          if (answer.name == name) answer,
    ],
    lastSurveyAt: DateTime.tryParse(json['lastSurveyAt'] as String? ?? ''),
  );
}

/// Всё состояние приложения. Хранится только на этом устройстве
/// (shared_preferences), загружается при запуске и сохраняется при каждом
/// изменении.
class AppState extends ChangeNotifier {
  static const _storageKey = 'aila_state_v1';
  // Журнал лежит отдельно: он растёт, а состояние сохраняется при каждом
  // изменении.
  static const _journalKey = 'aila_journal_v1';
  static const _journalLimit = 5000;

  final SharedPreferences _prefs;
  final List<ChildProfile> _profiles;
  String? _activeProfileId;
  String? _parentPin;
  bool _soundEnabled;
  bool _musicEnabled;
  bool _vibrationEnabled;
  late final List<JournalEntry> _journal = _loadJournal();

  AppState._(
    this._prefs, {
    required List<ChildProfile> profiles,
    String? activeProfileId,
    String? parentPin,
    bool soundEnabled = true,
    bool musicEnabled = true,
    bool vibrationEnabled = true,
  }) : _profiles = profiles,
       _activeProfileId = activeProfileId,
       _parentPin = parentPin,
       _soundEnabled = soundEnabled,
       _musicEnabled = musicEnabled,
       _vibrationEnabled = vibrationEnabled;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return AppState._(prefs, profiles: []);
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final profiles = (json['profiles'] as List? ?? [])
          .map((p) => ChildProfile.fromJson(p as Map<String, dynamic>))
          .toList();
      return AppState._(
        prefs,
        profiles: profiles,
        activeProfileId: json['activeProfileId'] as String?,
        parentPin: json['parentPin'] as String?,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('Не удалось прочитать сохранённое состояние: $e');
      return AppState._(prefs, profiles: []);
    }
  }

  List<JournalEntry> _loadJournal() {
    final raw = _prefs.getString(_journalKey);
    if (raw == null) return [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          ?JournalEntry.fromJson(item as Map<String, dynamic>),
      ];
    } catch (e) {
      debugPrint('Не удалось прочитать журнал: $e');
      return [];
    }
  }

  void _addToJournal(JournalEntry entry) {
    _journal.add(entry);
    if (_journal.length > _journalLimit) {
      _journal.removeRange(0, _journal.length - _journalLimit);
    }
    _prefs.setString(
      _journalKey,
      jsonEncode(_journal.map((e) => e.toJson()).toList()),
    );
  }

  void _changed() {
    notifyListeners();
    _prefs.setString(
      _storageKey,
      jsonEncode({
        'profiles': _profiles.map((p) => p.toJson()).toList(),
        'activeProfileId': _activeProfileId,
        'parentPin': _parentPin,
        'soundEnabled': _soundEnabled,
        'musicEnabled': _musicEnabled,
        'vibrationEnabled': _vibrationEnabled,
      }),
    );
  }

  // Профили

  List<ChildProfile> get profiles => List.unmodifiable(_profiles);
  bool get hasProfile => _profiles.isNotEmpty;

  ChildProfile? get activeProfile {
    if (_profiles.isEmpty) return null;
    return _profiles.firstWhere(
      (p) => p.id == _activeProfileId,
      orElse: () => _profiles.first,
    );
  }

  void addProfile({
    required String name,
    required int age,
    required AppLanguage language,
  }) {
    final profile = ChildProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      age: age,
      language: language,
    );
    _profiles.add(profile);
    _activeProfileId = profile.id;
    _changed();
  }

  void updateProfile(
    String id, {
    required String name,
    required int age,
    required AppLanguage language,
  }) {
    final profile = _profiles.firstWhere((p) => p.id == id);
    profile
      ..name = name.trim()
      ..age = age
      ..language = language;
    _changed();
  }

  void switchProfile(String id) {
    if (_activeProfileId == id) return;
    _activeProfileId = id;
    _changed();
  }

  /// Язык текущего профиля. Меняется из настроек.
  void setLanguage(AppLanguage language) {
    final profile = activeProfile;
    if (profile == null || profile.language == language) return;
    profile.language = language;
    _changed();
  }

  // PIN родителя

  bool get hasPin => _parentPin != null;
  bool checkPin(String pin) => pin == _parentPin;

  void setPin(String pin) {
    _parentPin = pin;
    _changed();
  }

  // Настройки

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _changed();
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    _changed();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _changed();
  }

  // Звёзды, наряды, задания (текущего профиля)

  int get stars => activeProfile?.stars ?? 0;
  String get equippedOutfitId => activeProfile?.equippedOutfitId ?? 'default';
  int get completedGamesCount =>
      activeProfile?.completedGameIndices.length ?? 0;

  bool isOwned(String id) =>
      activeProfile?.ownedOutfitIds.contains(id) ?? false;
  bool isGameCompleted(int index) =>
      activeProfile?.completedGameIndices.contains(index) ?? false;

  /// Отмечает задание пройденным. Звёзды даются только за первое
  /// прохождение; возвращает true, если звёзды были начислены.
  bool completeGame(int index, int reward) {
    final profile = activeProfile;
    if (profile == null) return false;
    if (!profile.completedGameIndices.add(index)) return false;
    profile.stars += reward;
    _changed();
    return true;
  }

  bool purchase(String id, int price) {
    final profile = activeProfile;
    if (profile == null) return false;
    if (profile.ownedOutfitIds.contains(id)) return true;
    if (profile.stars < price) return false;
    profile.stars -= price;
    profile.ownedOutfitIds.add(id);
    _changed();
    return true;
  }

  void equip(String id) {
    final profile = activeProfile;
    if (profile == null) return;
    if (!profile.ownedOutfitIds.contains(id)) return;
    if (profile.equippedOutfitId == id) return;
    profile.equippedOutfitId = id;
    _changed();
  }

  // Доска общения (текущего профиля)

  void _updateBoard(void Function(ChildProfile profile) update) {
    final profile = activeProfile;
    if (profile == null) return;
    update(profile);
    _changed();
  }

  void setBoardPhase(BoardPhase phase) => _updateBoard((p) {
    if (p.boardPhase == phase) return;
    p.boardPhase = phase;
    _addToJournal(
      JournalEntry(
        time: DateTime.now(),
        profileId: p.id,
        isPhaseChange: true,
        phase: phase,
      ),
    );
  });

  void setBreakAfterTasks(int count) =>
      _updateBoard((p) => p.breakAfterTasks = count);

  // Журнал (текущего профиля)

  List<JournalEntry> get journalEntries => _journal
      .where((e) => e.profileId == activeProfile?.id)
      .toList();

  /// Фраза, сказанная на доске. Экранам незачем перерисовываться из-за записи.
  void logPhrase({
    required String text,
    required int cards,
    bool isAnswer = false,
    DateTime? now,
  }) {
    final profile = activeProfile;
    if (profile == null) return;
    _addToJournal(
      JournalEntry(
        time: now ?? DateTime.now(),
        profileId: profile.id,
        text: text,
        cards: cards,
        isAnswer: isAnswer,
        phase: profile.boardPhase,
      ),
    );
  }

  void setAdultHintEnabled(bool value) =>
      _updateBoard((p) => p.adultHintEnabled = value);

  void setBoardCardCount(int count) =>
      _updateBoard((p) => p.boardCardCount = count);

  void setBoardCategoriesEnabled(bool value) =>
      _updateBoard((p) => p.boardCategoriesEnabled = value);

  void setFavorite(String wordId, bool favorite) => _updateBoard((p) {
    p.favoriteWordIds.remove(wordId);
    if (favorite) p.favoriteWordIds.add(wordId);
  });

  void setWordHidden(String wordId, bool hidden) => _updateBoard((p) {
    hidden ? p.hiddenWordIds.add(wordId) : p.hiddenWordIds.remove(wordId);
  });

  void setCategoryHidden(BoardCategory category, bool hidden) =>
      _updateBoard((p) {
        hidden
            ? p.hiddenCategories.add(category)
            : p.hiddenCategories.remove(category);
      });

  void addParentCard(ParentCard card) =>
      _updateBoard((p) => p.parentCards.add(card));

  // Опрос родителя (текущего профиля)

  void saveSurvey(List<SurveyAnswer> answers, {DateTime? now}) =>
      _updateBoard((p) {
        p.surveyAnswers = List.of(answers);
        p.lastSurveyAt = now ?? DateTime.now();
      });

  /// Прошло 4 недели с последнего опроса: пора напомнить родителю.
  bool isSurveyDue({DateTime? now}) {
    final last = activeProfile?.lastSurveyAt;
    if (last == null) return false;
    return (now ?? DateTime.now()).difference(last).inDays >= kSurveyRepeatDays;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
