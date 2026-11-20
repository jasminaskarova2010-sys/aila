// lib/parent/board_settings_screen.dart

import 'package:flutter/material.dart';

import '../board/board_model.dart';
import '../board/board_speech.dart';
import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../board/pictogram_repository.dart';
import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'parent_card_form_screen.dart';

/// Настройки доски для родителя (за PIN): фаза, подсказка, любимые предметы,
/// свои карточки, скрытие слов и категорий.
class BoardSettingsScreen extends StatefulWidget {
  const BoardSettingsScreen({super.key});

  @override
  State<BoardSettingsScreen> createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  final BoardSpeech _speech = BoardSpeech();
  AppLanguage? _checkedLanguage;
  bool _noVoice = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AppLocaleScope.of(context).language;
    if (_checkedLanguage != language) {
      _checkedLanguage = language;
      _speech.setLanguage(language).then((available) {
        if (mounted) setState(() => _noVoice = !available);
      });
    }
  }

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final profile = appState.activeProfile!;
    final model = BoardModel(profile);
    final phase = profile.boardPhase;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      appBar: AppBar(
        backgroundColor: BoardTheme.background,
        elevation: 0,
        foregroundColor: BoardTheme.ink,
        title: Text(
          s.boardTitle,
          style: const TextStyle(
            color: BoardTheme.ink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Text(
            s.boardSettingsSubtitle,
            style: const TextStyle(color: BoardTheme.muted, fontSize: 14),
          ),
          if (_noVoice) ...[
            const SizedBox(height: 12),
            _Card(
              child: Text(
                s.noVoiceMessage,
                style: const TextStyle(
                  color: BoardTheme.ink,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ],
          _Title(s.boardPhaseSection),
          _Card(
            child: Column(
              children: [
                for (final option in BoardPhase.values)
                  _PhaseRow(
                    title: s.boardPhaseName(option),
                    body: s.boardPhaseHint(option),
                    selected: option == phase,
                    onTap: () => appState.setBoardPhase(option),
                  ),
              ],
            ),
          ),
          if (phase == BoardPhase.iiiB) ...[
            const SizedBox(height: 12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.boardCardCountLabel(profile.boardCardCount),
                    style: const TextStyle(
                      color: BoardTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    min: 3,
                    max: 20,
                    divisions: 17,
                    value: profile.boardCardCount.toDouble(),
                    activeColor: BoardTheme.ink,
                    onChanged: (v) => appState.setBoardCardCount(v.round()),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.boardCategoriesSwitch),
                    activeThumbColor: BoardTheme.ink,
                    value: profile.boardCategoriesEnabled,
                    onChanged: appState.setBoardCategoriesEnabled,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Card(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.adultHintLabel),
              subtitle: Text(s.adultHintBody),
              activeThumbColor: BoardTheme.ink,
              value: profile.adultHintEnabled,
              onChanged: appState.setAdultHintEnabled,
            ),
          ),
          _Title(s.favoritesSection),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.favoritesHint,
                  style: const TextStyle(color: BoardTheme.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final word in model.favoriteOptions)
                      FilterChip(
                        label: Text(s.boardLabel(word)),
                        selected: profile.favoriteWordIds.contains(word.id),
                        onSelected: (v) => appState.setFavorite(word.id, v),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _Title(s.myCardsSection),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.parentCards.isEmpty)
                  Text(
                    s.myCardsEmpty,
                    style: const TextStyle(color: BoardTheme.muted),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final card in profile.parentCards)
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ParentCardFormScreen(editing: card),
                            ),
                          ),
                          child: SizedBox(
                            width: 84,
                            child: Column(
                              children: [
                                PictogramRepository.image(card.toWord(), 72),
                                const SizedBox(height: 4),
                                Text(
                                  card.label,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: BoardTheme.ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                if (profile.parentCards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    s.editCardHint,
                    style: const TextStyle(
                      color: BoardTheme.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ParentCardFormScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: BoardTheme.ink),
                  label: Text(
                    s.addCard,
                    style: const TextStyle(color: BoardTheme.ink),
                  ),
                ),
              ],
            ),
          ),
          _Title(s.showHideSection),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.showHideHint,
              style: const TextStyle(color: BoardTheme.muted),
            ),
          ),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _HideSection(
                  category: BoardCategory.home,
                  title: s.boardCategoryName(BoardCategory.home),
                  words: _hideable(BoardCategory.home, profile),
                  canHideCategory: false,
                ),
                for (final category in kBoardCategoryOrder)
                  _HideSection(
                    category: category,
                    title: s.boardCategoryName(category),
                    words: _hideable(category, profile),
                    canHideCategory: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Закреплённая строка видна всегда, поэтому её слова не скрываются.
  List<BoardWord> _hideable(BoardCategory category, ChildProfile profile) => [
    for (final word in [
      ...kBoardWords,
      ...profile.parentCards.map((c) => c.toWord()),
    ])
      if (word.category == category && !kPinnedWordIds.contains(word.id)) word,
  ];
}

class _HideSection extends StatelessWidget {
  final BoardCategory category;
  final String title;
  final List<BoardWord> words;
  final bool canHideCategory;

  const _HideSection({
    required this.category,
    required this.title,
    required this.words,
    required this.canHideCategory,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final profile = appState.activeProfile!;
    return ExpansionTile(
      title: Text(title, style: const TextStyle(color: BoardTheme.ink)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canHideCategory)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.showCategory),
            activeThumbColor: BoardTheme.ink,
            value: !profile.hiddenCategories.contains(category),
            onChanged: (v) => appState.setCategoryHidden(category, !v),
          ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final word in words)
              FilterChip(
                label: Text(s.boardLabel(word)),
                selected: !profile.hiddenWordIds.contains(word.id),
                onSelected: (v) => appState.setWordHidden(word.id, !v),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhaseRow extends StatelessWidget {
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  const _PhaseRow({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: BoardTheme.ink,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: BoardTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      color: BoardTheme.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: BoardTheme.ink,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    // Material, а не Container: иначе у SwitchListTile и ExpansionTile не видно
    // отклика на нажатие.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
