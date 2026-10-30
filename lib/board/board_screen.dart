// lib/board/board_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'board_model.dart';
import 'board_speech.dart';
import 'board_theme.dart';
import 'board_words.dart';
import 'phrase_builder.dart';
import 'pictogram_repository.dart';

/// Доска общения. Сверху вниз: полоска фразы, стартовые фразы, закреплённая
/// строка, сетка карточек текущей категории, панель категорий. Что именно видно,
/// зависит от фазы в профиле ребёнка. Звёзды за доску не начисляются: общение
/// не игра на награды.
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardSpeech _speech = BoardSpeech();
  final ScrollController _stripScroll = ScrollController();
  final List<BoardWord> _strip = [];
  BoardCategory _category = BoardCategory.home;
  String? _hint;
  Timer? _hintTimer;
  AppLanguage? _speechLanguage;
  bool _noVoice = false;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AppLocaleScope.of(context).language;
    if (_speechLanguage != language) {
      _speechLanguage = language;
      _speech.setLanguage(language).then((available) {
        if (mounted) setState(() => _noVoice = !available);
      });
    }
    if (!_seeded) {
      _seeded = true;
      _seedStrip();
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _stripScroll.dispose();
    _speech.dispose();
    super.dispose();
  }

  BoardModel get _model => BoardModel(AppStateScope.of(context).activeProfile!);

  /// В фазах с полоской «Я хочу» уже стоит первой.
  void _seedStrip() {
    if (_model.phase.hasStrip && _strip.isEmpty) {
      _strip.add(boardWordById('i_want')!);
    }
  }

  void _onCardTap(BoardWord word) {
    _speech.speakWord(word);
    if (!_model.phase.hasStrip) {
      _showHint([word]);
      return;
    }
    setState(() {
      if (word.kind == WordKind.starter) {
        _strip.removeWhere((w) => w.kind == WordKind.starter);
        _strip.insert(0, word);
      } else {
        // Без предмета «Я хочу больно» не получится: остаётся только слово.
        final onlyWant = _strip.length == 1 && _strip.first.id == 'i_want';
        if (onlyWant && !word.isRequestable) _strip.clear();
        _strip.add(word);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stripScroll.hasClients) {
        _stripScroll.jumpTo(_stripScroll.position.maxScrollExtent);
      }
    });
  }

  void _say() {
    final hasContent = _strip.any((w) => w.kind != WordKind.starter);
    if (!hasContent) return;
    _speech.speakPhrase(_strip);
    _showHint(_strip);
  }

  void _eraseLast() {
    if (_strip.isEmpty) return;
    setState(() {
      _strip.removeLast();
      _seedStrip();
    });
  }

  void _eraseAll() {
    setState(() {
      _strip.clear();
      _seedStrip();
    });
  }

  void _askWant(S s) => _speech.speakText(s.boardQuestionWant);

  void _askSee(S s) {
    _speech.speakText(s.boardAskSee);
    final hasContent = _strip.any((w) => w.kind != WordKind.starter);
    if (!hasContent) {
      setState(() {
        _strip
          ..clear()
          ..add(boardWordById('i_see')!);
      });
    }
  }

  void _showHint(List<BoardWord> parts) {
    final profile = AppStateScope.of(context).activeProfile!;
    if (!profile.adultHintEnabled) return;
    final s = S.of(context);
    final lang = s.lang;
    final starterId = parts.first.kind == WordKind.starter
        ? parts.first.id
        : null;
    final isRequest =
        (starterId == null || starterId == 'i_want') &&
        parts.any((w) => w.isRequestable);
    final String text;
    if (isRequest) {
      text = s.hintRequest(buildPhrase(parts, lang, withStarter: false));
    } else {
      final phrase = buildPhrase(parts, lang);
      final said = lang == AppLanguage.en
          ? phrase
          : phrase[0].toLowerCase() + phrase.substring(1);
      text = s.hintComment(said);
    }
    _hintTimer?.cancel();
    setState(() => _hint = text);
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final model = _model;
    final phase = model.phase;
    final categories = model.showsCategories
        ? model.categories
        : const <BoardCategory>[];
    if (_category != BoardCategory.home && !categories.contains(_category)) {
      _category = BoardCategory.home;
    }
    return Scaffold(
      backgroundColor: BoardTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  title: s.boardTitle,
                  actions: [
                    if (phase.hasAskButton)
                      _QuestionButton(
                        label: s.boardAsk,
                        onTap: () => _askWant(s),
                      ),
                    if (phase.hasSeeQuestion)
                      _QuestionButton(
                        label: s.boardAskSee,
                        onTap: () => _askSee(s),
                      ),
                  ],
                ),
                if (_noVoice) _NoVoiceNote(
                  text: s.noVoiceMessage,
                  onClose: () => setState(() => _noVoice = false),
                ),
                if (phase.hasStrip) ...[
                  _SentenceStrip(
                    words: _strip,
                    controller: _stripScroll,
                    sayLabel: s.boardSay,
                    eraseLabel: s.boardErase,
                    onSay: _say,
                    onErase: _eraseLast,
                    onEraseAll: _eraseAll,
                  ),
                  _WordRow(words: model.starters, onTap: _onCardTap),
                ],
                _WordRow(words: model.pinned, onTap: _onCardTap),
                Expanded(
                  child: _BoardGrid(
                    words: model.gridWords(_category),
                    onTap: _onCardTap,
                  ),
                ),
                if (model.showsCategories)
                  _CategoryBar(
                    categories: categories,
                    selected: _category,
                    onSelect: (c) => setState(() => _category = c),
                  ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 8,
              // Плашка не мешает нажимать на карточки под ней.
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hint == null
                      ? const SizedBox.shrink()
                      : _AdultHint(key: ValueKey(_hint), text: _hint!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const _Header({required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back, color: BoardTheme.ink, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Кнопки для взрослого важнее заголовка: на узком экране он сжимается.
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BoardTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actions.isNotEmpty)
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuestionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: BoardTheme.questions,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: BoardTheme.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoVoiceNote extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const _NoVoiceNote({required this.text, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEF9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: BoardTheme.ink, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18, color: BoardTheme.muted),
          ),
        ],
      ),
    );
  }
}

/// Плашка для взрослого (П2): появляется плавно, на 3 секунды.
class _AdultHint extends StatelessWidget {
  final String text;

  const _AdultHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: BoardTheme.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SentenceStrip extends StatelessWidget {
  final List<BoardWord> words;
  final ScrollController controller;
  final String sayLabel;
  final String eraseLabel;
  final VoidCallback onSay;
  final VoidCallback onErase;
  final VoidCallback onEraseAll;

  const _SentenceStrip({
    required this.words,
    required this.controller,
    required this.sayLabel,
    required this.eraseLabel,
    required this.onSay,
    required this.onErase,
    required this.onEraseAll,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onSay,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE3DCEC), width: 1.4),
                  ),
                  child: ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: words.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 4),
                    itemBuilder: (context, i) {
                      final word = words[i];
                      return Container(
                        width: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: BoardTheme.frameFor(word),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(child: PictogramRepository.image(word, 32)),
                            Text(
                              s.boardLabel(word),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BoardTheme.ink,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _StripButton(
              icon: Icons.volume_up,
              label: sayLabel,
              filled: true,
              onTap: onSay,
            ),
            const SizedBox(width: 6),
            _StripButton(
              icon: Icons.backspace_outlined,
              label: eraseLabel,
              filled: false,
              onTap: onErase,
              onLongPress: onEraseAll,
            ),
          ],
        ),
      ),
    );
  }
}

class _StripButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _StripButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : BoardTheme.ink;
    return Material(
      color: filled ? BoardTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 68,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Строка компактных карточек. На узком экране карточки сжимаются до 72 dp,
/// дальше строка прокручивается.
class _WordRow extends StatelessWidget {
  final List<BoardWord> words;
  final ValueChanged<BoardWord> onTap;

  const _WordRow({required this.words, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final width =
            ((constraints.maxWidth - 8 - gap * (words.length - 1)) / words.length)
                .clamp(72.0, 92.0);
        return SizedBox(
          height: 92,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final word in words)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: gap / 2),
                      child: BoardCardTile(
                        word: word,
                        width: width,
                        height: 88,
                        onTap: () => onTap(word),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Сетка подбирает самый крупный размер карточек, при котором все помещаются.
/// Если не помещаются даже минимальные, сетка прокручивается.
class _BoardGrid extends StatelessWidget {
  static const _gap = 8.0;
  static const _padding = 10.0;
  static const _ratio = 1.2;
  static const _minWidth = 92.0;
  static const _maxWidth = 460.0;

  final List<BoardWord> words;
  final ValueChanged<BoardWord> onTap;

  const _BoardGrid({required this.words, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableW = constraints.maxWidth - _padding * 2;
        final availableH = constraints.maxHeight - _padding * 2;
        final count = words.length;
        if (count == 0) return const SizedBox.shrink();

        var bestWidth = 0.0;
        var bestColumns = 1;
        for (var columns = 1; columns <= count; columns++) {
          final rows = (count / columns).ceil();
          final cellW = (availableW - _gap * (columns - 1)) / columns;
          final cellH = (availableH - _gap * (rows - 1)) / rows;
          final width = cellW < cellH / _ratio ? cellW : cellH / _ratio;
          if (width > bestWidth) {
            bestWidth = width;
            bestColumns = columns;
          }
        }
        final fits = bestWidth >= _minWidth;
        final width = fits ? bestWidth.clamp(_minWidth, _maxWidth) : _minWidth;
        final columns = fits
            ? bestColumns
            : ((availableW + _gap) / (_minWidth + _gap)).floor().clamp(1, count);
        final tileWidth = fits
            ? width
            : (availableW - _gap * (columns - 1)) / columns;

        final grid = Wrap(
          alignment: WrapAlignment.center,
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final word in words)
              BoardCardTile(
                word: word,
                width: tileWidth,
                height: tileWidth * _ratio,
                onTap: () => onTap(word),
              ),
          ],
        );
        if (fits) return Center(child: SizedBox(width: availableW, child: grid));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: SizedBox(width: availableW, child: grid),
        );
      },
    );
  }
}

/// Карточка: при нажатии плавно увеличивается на 180 мс, без мигания.
class BoardCardTile extends StatefulWidget {
  final BoardWord word;
  final double width;
  final double height;
  final VoidCallback onTap;

  const BoardCardTile({
    super.key,
    required this.word,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<BoardCardTile> createState() => _BoardCardTileState();
}

class _BoardCardTileState extends State<BoardCardTile> {
  static const _duration = Duration(milliseconds: 180);
  bool _grown = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _grown = true);
    _timer?.cancel();
    _timer = Timer(_duration, () {
      if (mounted) setState(() => _grown = false);
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fontSize = (widget.width * 0.13).clamp(12.0, 26.0);
    final labelHeight = fontSize * 2.5;
    final space = widget.height - labelHeight - 14;
    final imageSize = space < widget.width - 12 ? space : widget.width - 12;
    return AnimatedScale(
      scale: _grown ? 1.08 : 1.0,
      duration: _duration,
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleTap,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BoardTheme.frameFor(widget.word),
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: PictogramRepository.image(widget.word, imageSize),
                  ),
                ),
                SizedBox(
                  height: labelHeight,
                  child: Center(
                    child: Text(
                      s.boardLabel(widget.word),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BoardTheme.ink,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final List<BoardCategory> categories;
  final BoardCategory selected;
  final ValueChanged<BoardCategory> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  /// Картинка кнопки: слово из этой категории.
  static const _iconWords = {
    BoardCategory.food: 'apple',
    BoardCategory.drinks: 'water',
    BoardCategory.toys: 'ball',
    BoardCategory.actions: 'play',
    BoardCategory.people: 'mom',
    BoardCategory.feelings: 'good',
    BoardCategory.descriptions: 'big',
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      height: 76,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        children: [
          _item(
            label: s.boardCategoryName(BoardCategory.home),
            category: BoardCategory.home,
            icon: const Icon(Icons.home_rounded, color: BoardTheme.ink, size: 30),
          ),
          for (final category in categories)
            _item(
              label: s.boardCategoryName(category),
              category: category,
              icon: _iconWords[category] == null
                  ? const Icon(Icons.place_outlined, color: BoardTheme.ink, size: 30)
                  : PictogramRepository.image(
                      boardWordById(_iconWords[category]!)!,
                      30,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _item({
    required String label,
    required BoardCategory category,
    required Widget icon,
  }) {
    final isSelected = category == selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? const Color(0xFFF2EEF9) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelect(category),
          child: SizedBox(
            width: 76,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BoardTheme.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
