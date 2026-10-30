// lib/l10n/board_labels.dart

import 'app_language.dart';

/// Подписи стартовых карточек доски (русский, английский, казахский).
/// Казахские подписи должен проверить носитель языка.
const Map<String, List<String>> _labels = {
  'i_want': ['Я хочу', 'I want', 'Мен қалаймын'],
  'i_see': ['Я вижу', 'I see', 'Мен көремін'],
  'i_hear': ['Я слышу', 'I hear', 'Мен естимін'],
  'i_feel': ['Я чувствую', 'I feel', 'Мен сезінемін'],
  'this_is': ['Это', 'This is', 'Бұл'],
  'yes': ['да', 'yes', 'иә'],
  'no': ['нет', 'no', 'жоқ'],
  'help': ['помоги', 'help', 'көмектес'],
  'more': ['ещё', 'more', 'тағы'],
  'done': ['всё', 'all done', 'болды'],
  'stop': ['стоп', 'stop', 'тоқта'],
  'break': ['перерыв', 'break', 'үзіліс'],
  'hello': ['привет', 'hello', 'сәлем'],
  'bye': ['пока', 'bye', 'сау бол'],
  'thanks': ['спасибо', 'thank you', 'рақмет'],
  'water': ['вода', 'water', 'су'],
  'juice': ['сок', 'juice', 'шырын'],
  'milk': ['молоко', 'milk', 'сүт'],
  'apple': ['яблоко', 'apple', 'алма'],
  'banana': ['банан', 'banana', 'банан'],
  'cookie': ['печенье', 'cookie', 'печенье'],
  'bread': ['хлеб', 'bread', 'нан'],
  'porridge': ['каша', 'porridge', 'ботқа'],
  'ice_cream': ['мороженое', 'ice cream', 'балмұздақ'],
  'ball': ['мяч', 'ball', 'доп'],
  'toy_car': ['машинка', 'toy car', 'ойыншық көлік'],
  'blocks': ['кубики', 'blocks', 'текшелер'],
  'bubbles': ['мыльные пузыри', 'bubbles', 'сабын көпіршіктері'],
  'book': ['книга', 'book', 'кітап'],
  'cartoon': ['мультик', 'cartoon', 'мультфильм'],
  'draw': ['рисовать', 'draw', 'сурет салу'],
  'music': ['музыка', 'music', 'музыка'],
  'eat': ['есть', 'eat', 'жеу'],
  'drink': ['пить', 'drink', 'ішу'],
  'play': ['играть', 'play', 'ойнау'],
  'go': ['идти', 'go', 'бару'],
  'sleep': ['спать', 'sleep', 'ұйықтау'],
  'wash_hands': ['мыть руки', 'wash hands', 'қол жуу'],
  'toilet': ['туалет', 'toilet', 'дәретхана'],
  'open': ['открыть', 'open', 'ашу'],
  'mom': ['мама', 'mom', 'ана'],
  'dad': ['папа', 'dad', 'әке'],
  'grandma': ['бабушка', 'grandma', 'әже'],
  'grandpa': ['дедушка', 'grandpa', 'ата'],
  'brother': ['брат', 'brother', 'аға'],
  'sister': ['сестра', 'sister', 'әпке'],
  'me': ['я', 'me', 'мен'],
  'good': ['хорошо', 'good', 'жақсы'],
  'bad': ['плохо', 'bad', 'жаман'],
  'hurts': ['больно', 'it hurts', 'ауырады'],
  'tired': ['устал', 'tired', 'шаршадым'],
  'sad': ['грустно', 'sad', 'мұңды'],
  'angry': ['злюсь', 'angry', 'ашулымын'],
  'scared': ['страшно', 'scared', 'қорқамын'],
  'big': ['большой', 'big', 'үлкен'],
  'small': ['маленький', 'small', 'кішкентай'],
  'red': ['красный', 'red', 'қызыл'],
  'blue': ['синий', 'blue', 'көк'],
  'yellow': ['жёлтый', 'yellow', 'сары'],
  'green': ['зелёный', 'green', 'жасыл'],
};

String boardWordLabel(String id, AppLanguage language) {
  final labels = _labels[id];
  if (labels == null) return id;
  switch (language) {
    case AppLanguage.ru:
      return labels[0];
    case AppLanguage.en:
      return labels[1];
    case AppLanguage.kk:
      return labels[2];
  }
}
