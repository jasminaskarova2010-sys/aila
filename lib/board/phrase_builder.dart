// lib/board/phrase_builder.dart

import '../l10n/app_language.dart';
import '../l10n/board_labels.dart';
import 'board_words.dart';

/// Собирает из карточек полоски фразу для озвучки: «Я хочу большой красный
/// мяч». Прилагательные всегда встают перед предметом, размер раньше цвета,
/// в каком бы порядке ребёнок их нажал.
///
/// Как устроена грамматика (самый простой рабочий вариант для MVP):
/// - русский: у слов хранятся готовые формы (род, винительный падеж, формы
///   описаний), поэтому «большую красную машинку», а не «большой красный
///   машинка»;
/// - казахский: шаблон на каждую стартовую фразу с глаголом в конце
///   («Мен {X} қалаймын»), описания не меняются;
/// - английский: стартовая фраза и артикль.
/// Карточки родителя произносятся как записаны.
///
/// [withStarter] == false — та же фраза без начала («воду» вместо «Я хочу
/// воду»), нужна для подсказки взрослому.
String buildPhrase(
  List<BoardWord> parts,
  AppLanguage lang, {
  bool withStarter = true,
}) {
  BoardWord? starter;
  for (final word in parts) {
    if (word.kind == WordKind.starter) {
      starter = word;
      break;
    }
  }
  final segments = _group(parts);
  switch (lang) {
    case AppLanguage.ru:
      return _build(_Ru(), starter, segments, lang, withStarter);
    case AppLanguage.en:
      return _build(_En(), starter, segments, lang, withStarter);
    case AppLanguage.kk:
      return _build(_Kk(), starter, segments, lang, withStarter);
  }
}

class _Segment {
  final List<BoardWord> adjectives = [];
  BoardWord? word;

  bool get isCore =>
      word == null ||
      word!.kind == WordKind.noun ||
      word!.kind == WordKind.verb;
}

/// Описания присоединяются к следующему предмету, а если его нет — к
/// предыдущему.
List<_Segment> _group(List<BoardWord> parts) {
  final segments = <_Segment>[];
  final pending = <BoardWord>[];
  _Segment? lastNoun;
  for (final word in parts) {
    switch (word.kind) {
      case WordKind.starter:
        break;
      case WordKind.adjective:
        pending.add(word);
      case WordKind.noun:
        final segment = _Segment()
          ..word = word
          ..adjectives.addAll(pending);
        pending.clear();
        segments.add(segment);
        lastNoun = segment;
      case WordKind.verb:
      case WordKind.social:
      case WordKind.feeling:
        segments.add(_Segment()..word = word);
    }
  }
  if (pending.isNotEmpty) {
    if (lastNoun != null) {
      lastNoun.adjectives.addAll(pending);
    } else {
      segments.add(_Segment()..adjectives.addAll(pending));
    }
  }
  for (final segment in segments) {
    final sizes = segment.adjectives.where((a) => a.isSize).toList();
    final colors = segment.adjectives.where((a) => !a.isSize).toList();
    segment.adjectives
      ..clear()
      ..addAll(sizes)
      ..addAll(colors);
  }
  return segments;
}

String _build(
  _Language language,
  BoardWord? starter,
  List<_Segment> segments,
  AppLanguage lang,
  bool withStarter,
) {
  final core = segments.where((s) => s.isCore).toList();
  final rest = segments.where((s) => !s.isCore).toList();
  final inFeel = starter?.id == 'i_feel';

  final pieces = <String>[];
  if (core.isNotEmpty) {
    pieces.add(language.core(starter?.id, core, withStarter));
  } else if (starter != null && rest.isEmpty && withStarter) {
    pieces.add(boardWordLabel(starter.id, lang));
  }
  for (final segment in rest) {
    final word = segment.word!;
    pieces.add(
      word.kind == WordKind.feeling && inFeel
          ? language.feeling(word.id)
          : _label(word, lang),
    );
  }
  final phrase = pieces.join(', ');
  return withStarter ? _capitalize(phrase) : phrase;
}

String _label(BoardWord word, AppLanguage lang) =>
    word.customLabel ?? boardWordLabel(word.id, lang);

String _capitalize(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

abstract class _Language {
  String core(String? starterId, List<_Segment> core, bool withStarter);
  String feeling(String id);
}

// Русский

enum _Gender { m, n, f, pl }

class _RuNoun {
  final String acc;
  final _Gender gender;
  final bool animate;

  /// Особая форма после «Я хочу»: «в туалет».
  final String? want;

  const _RuNoun(this.acc, this.gender, {this.animate = false, this.want});
}

const _ruNouns = <String, _RuNoun>{
  'water': _RuNoun('воду', _Gender.f),
  'juice': _RuNoun('сок', _Gender.m),
  'milk': _RuNoun('молоко', _Gender.n),
  'apple': _RuNoun('яблоко', _Gender.n),
  'banana': _RuNoun('банан', _Gender.m),
  'cookie': _RuNoun('печенье', _Gender.n),
  'bread': _RuNoun('хлеб', _Gender.m),
  'porridge': _RuNoun('кашу', _Gender.f),
  'ice_cream': _RuNoun('мороженое', _Gender.n),
  'ball': _RuNoun('мяч', _Gender.m),
  'toy_car': _RuNoun('машинку', _Gender.f),
  'blocks': _RuNoun('кубики', _Gender.pl),
  'bubbles': _RuNoun('мыльные пузыри', _Gender.pl),
  'book': _RuNoun('книгу', _Gender.f),
  'cartoon': _RuNoun('мультик', _Gender.m),
  'music': _RuNoun('музыку', _Gender.f),
  'toilet': _RuNoun('туалет', _Gender.m, want: 'в туалет'),
  'mom': _RuNoun('маму', _Gender.f, animate: true),
  'dad': _RuNoun('папу', _Gender.m, animate: true),
  'grandma': _RuNoun('бабушку', _Gender.f, animate: true),
  'grandpa': _RuNoun('дедушку', _Gender.m, animate: true),
  'brother': _RuNoun('брата', _Gender.m, animate: true),
  'sister': _RuNoun('сестру', _Gender.f, animate: true),
  'me': _RuNoun('меня', _Gender.m, animate: true),
};

class _RuAdjective {
  final String m, n, f, pl, mAnimateAcc, fAcc;

  const _RuAdjective(this.m, this.n, this.f, this.pl, this.mAnimateAcc, this.fAcc);
}

const _ruAdjectives = <String, _RuAdjective>{
  'big': _RuAdjective('большой', 'большое', 'большая', 'большие', 'большого', 'большую'),
  'small': _RuAdjective('маленький', 'маленькое', 'маленькая', 'маленькие', 'маленького', 'маленькую'),
  'red': _RuAdjective('красный', 'красное', 'красная', 'красные', 'красного', 'красную'),
  'blue': _RuAdjective('синий', 'синее', 'синяя', 'синие', 'синего', 'синюю'),
  'yellow': _RuAdjective('жёлтый', 'жёлтое', 'жёлтая', 'жёлтые', 'жёлтого', 'жёлтую'),
  'green': _RuAdjective('зелёный', 'зелёное', 'зелёная', 'зелёные', 'зелёного', 'зелёную'),
};

const _ruFeelings = <String, String>{
  'good': 'мне хорошо',
  'bad': 'мне плохо',
  'hurts': 'мне больно',
  'tired': 'я устал',
  'sad': 'мне грустно',
  'angry': 'я злюсь',
  'scared': 'мне страшно',
};

class _Ru implements _Language {
  static const _accusative = {'i_want', 'i_see', 'i_hear', 'i_feel'};

  @override
  String core(String? starterId, List<_Segment> core, bool withStarter) {
    final body = core.map((s) => _segment(s, starterId)).join(', ');
    if (starterId == null || !withStarter) return body;
    return '${boardWordLabel(starterId, AppLanguage.ru)} $body';
  }

  String _segment(_Segment segment, String? starterId) {
    final word = segment.word;
    final isAccusative = _accusative.contains(starterId);
    final noun = word == null ? null : _ruNouns[word.id];
    final adjectives = segment.adjectives
        .map((a) => _adjective(_ruAdjectives[a.id]!, noun, isAccusative));
    final String? main;
    if (word == null) {
      main = null;
    } else if (noun == null) {
      main = word.customLabel ?? boardWordLabel(word.id, AppLanguage.ru);
    } else if (starterId == 'i_want' && noun.want != null) {
      main = noun.want;
    } else {
      main = isAccusative ? noun.acc : boardWordLabel(word.id, AppLanguage.ru);
    }
    return [...adjectives, ?main].join(' ');
  }

  String _adjective(_RuAdjective a, _RuNoun? noun, bool isAccusative) {
    switch (noun?.gender ?? _Gender.m) {
      case _Gender.m:
        return isAccusative && (noun?.animate ?? false) ? a.mAnimateAcc : a.m;
      case _Gender.n:
        return a.n;
      case _Gender.f:
        return isAccusative ? a.fAcc : a.f;
      case _Gender.pl:
        return a.pl;
    }
  }

  @override
  String feeling(String id) => _ruFeelings[id]!;
}

// Английский

/// Как слово стоит во фразе: «a ball», «water», «my brother».
const _enNoArticle = {
  'water', 'juice', 'milk', 'bread', 'porridge', 'ice_cream', 'blocks',
  'bubbles', 'music', 'mom', 'dad', 'grandma', 'grandpa', 'me',
};
const _enMy = {'brother', 'sister'};

const _enFeelings = <String, String>{
  'good': 'I feel good',
  'bad': 'I feel bad',
  'hurts': 'it hurts',
  'tired': 'I feel tired',
  'sad': 'I feel sad',
  'angry': 'I feel angry',
  'scared': 'I feel scared',
};

class _En implements _Language {
  @override
  String core(String? starterId, List<_Segment> core, bool withStarter) {
    final body = core.map((s) => _segment(s, starterId)).join(', ');
    if (starterId == null || !withStarter) return body;
    return '${boardWordLabel(starterId, AppLanguage.en)} $body';
  }

  String _segment(_Segment segment, String? starterId) {
    final word = segment.word;
    final inWant = starterId == 'i_want';
    if (word != null && word.kind == WordKind.verb) {
      final label = boardWordLabel(word.id, AppLanguage.en);
      return inWant ? 'to $label' : label;
    }
    if (word?.id == 'toilet' && inWant) return 'to go to the toilet';
    final words = [
      ...segment.adjectives.map((a) => boardWordLabel(a.id, AppLanguage.en)),
      if (word != null) word.customLabel ?? boardWordLabel(word.id, AppLanguage.en),
    ].join(' ');
    if (starterId == null || word == null || word.isParentCard) return words;
    if (_enMy.contains(word.id)) return 'my $words';
    if (_enNoArticle.contains(word.id)) return words;
    final article = 'aeiou'.contains(words[0]) ? 'an' : 'a';
    return '$article $words';
  }

  @override
  String feeling(String id) => _enFeelings[id]!;
}

// Казахский. Тексты должен проверить носитель языка.

/// Форма после «хочу» у слов, для которых «қалаймын» не подходит.
const _kkWant = <String, String>{
  'eat': 'жегім келеді',
  'drink': 'ішкім келеді',
  'play': 'ойнағым келеді',
  'go': 'барғым келеді',
  'sleep': 'ұйықтағым келеді',
  'wash_hands': 'қол жуғым келеді',
  'open': 'ашқым келеді',
  'draw': 'сурет салғым келеді',
  'toilet': 'дәретханаға барғым келеді',
};

const _kkTemplates = <String, String>{
  'i_want': 'Мен {} қалаймын',
  'i_see': 'Мен {} көріп тұрмын',
  'i_hear': 'Мен {} естіп тұрмын',
  'i_feel': 'Мен {} сезінемін',
  'this_is': 'Бұл {}',
};

const _kkFeelings = <String, String>{
  'good': 'маған жақсы',
  'bad': 'маған жаман',
  'hurts': 'маған ауырады',
  'tired': 'мен шаршадым',
  'sad': 'маған мұңды',
  'angry': 'мен ашулымын',
  'scared': 'мен қорқамын',
};

class _Kk implements _Language {
  @override
  String core(String? starterId, List<_Segment> core, bool withStarter) {
    final inWant = starterId == 'i_want';
    final wantForms = <String>[];
    final others = <String>[];
    for (final segment in core) {
      final form = inWant ? _kkWant[segment.word?.id] : null;
      if (form != null) {
        wantForms.add(withStarter ? 'мен $form' : form);
      } else {
        others.add(_segment(segment));
      }
    }
    final body = others.join(', ');
    final main = others.isEmpty
        ? null
        : (starterId == null || !withStarter
              ? body
              : _kkTemplates[starterId]!.replaceFirst('{}', body));
    return [?main, ...wantForms].join(', ');
  }

  String _segment(_Segment segment) => [
    ...segment.adjectives.map((a) => boardWordLabel(a.id, AppLanguage.kk)),
    if (segment.word != null)
      segment.word!.customLabel ??
          boardWordLabel(segment.word!.id, AppLanguage.kk),
  ].join(' ');

  @override
  String feeling(String id) => _kkFeelings[id]!;
}
