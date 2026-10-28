// lib/pecs/pecs_data.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pictograms.dart';

/// Карточка коммуникации. `image` — путь к будущему растровому фото;
/// `pictogramBuilder` — визуал по умолчанию: либо настоящая иллюстрация
/// (Mulberry Symbols, assets/pecs_symbols/*.svg), либо — если подходящего
/// символа для этого слова нет — простая однозначная векторная пиктограмма
/// в едином стиле (не эмодзи).
class PecsCardData {
  final String id;
  final String category;
  final String label;
  final String? image;
  final String spokenText;
  final Widget Function(double size) pictogramBuilder;

  const PecsCardData({
    required this.id,
    required this.category,
    required this.label,
    this.image,
    required this.spokenText,
    required this.pictogramBuilder,
  });
}

Widget Function(double size) _icon(IconData icon, Color color) {
  return (size) => Icon(icon, size: size * 0.62, color: color);
}

/// Иллюстрация из набора Mulberry Symbols (CC BY-SA 4.0, © Steve Lee).
Widget Function(double size) _svg(String fileName) {
  return (size) => SvgPicture.asset(
        'assets/pecs_symbols/$fileName',
        width: size,
        height: size,
      );
}

const Color _needsColor = Color(0xFF7A6C99);
const Color _dailyColor = Color(0xFF5A9E6F);
const Color _peopleColor = Color(0xFF4A7FBF);
const Color _urgentColor = Color(0xFFC9636B);

class PecsCategoryInfo {
  final String title;
  final Color background;

  const PecsCategoryInfo({required this.title, required this.background});
}

const Map<String, PecsCategoryInfo> kPecsCategoryInfo = {
  'Основные потребности':
      PecsCategoryInfo(title: 'Основные потребности', background: Color(0xFFE9E4F2)),
  'Еда и напитки':
      PecsCategoryInfo(title: 'Еда и напитки', background: Color(0xFFFCE9D2)),
  'Повседневные потребности':
      PecsCategoryInfo(title: 'Повседневные потребности', background: Color(0xFFE1F0E4)),
  'Эмоции': PecsCategoryInfo(title: 'Эмоции', background: Color(0xFFFDF0D5)),
  'Очень важные карточки':
      PecsCategoryInfo(title: 'Очень важные карточки', background: Color(0xFFF9E1E2)),
  'Люди': PecsCategoryInfo(title: 'Люди', background: Color(0xFFE1EBF7)),
};

const List<String> kPecsCategoryOrder = [
  'Основные потребности',
  'Еда и напитки',
  'Повседневные потребности',
  'Эмоции',
  'Очень важные карточки',
  'Люди',
];

final List<PecsCardData> kPecsCards = [
  // Основные потребности
  PecsCardData(
    id: 'want',
    category: 'Основные потребности',
    label: 'Я хочу',
    spokenText: 'Я хочу',
    pictogramBuilder: _svg('want.svg'),
  ),
  PecsCardData(
    id: 'more',
    category: 'Основные потребности',
    label: 'Ещё',
    spokenText: 'Ещё',
    pictogramBuilder: _svg('more.svg'),
  ),
  PecsCardData(
    id: 'dont_want',
    category: 'Основные потребности',
    label: 'Не хочу',
    spokenText: 'Не хочу',
    // Подходящего символа "не хочу" в наборе Mulberry Symbols нет.
    pictogramBuilder: _icon(Icons.not_interested, _needsColor),
  ),
  PecsCardData(
    id: 'yes',
    category: 'Основные потребности',
    label: 'Да',
    spokenText: 'Да',
    pictogramBuilder: _svg('yes.svg'),
  ),
  PecsCardData(
    id: 'no',
    category: 'Основные потребности',
    label: 'Нет',
    spokenText: 'Нет',
    pictogramBuilder: _svg('no.svg'),
  ),
  PecsCardData(
    id: 'stop',
    category: 'Основные потребности',
    label: 'Стоп',
    spokenText: 'Стоп',
    // Подходящего символа "стоп" в наборе Mulberry Symbols нет.
    pictogramBuilder: _icon(Icons.pan_tool, _urgentColor),
  ),
  PecsCardData(
    id: 'help',
    category: 'Основные потребности',
    label: 'Помоги',
    spokenText: 'Помоги',
    pictogramBuilder: _svg('help.svg'),
  ),
  PecsCardData(
    id: 'wait',
    category: 'Основные потребности',
    label: 'Подожди',
    spokenText: 'Подожди',
    pictogramBuilder: _svg('wait.svg'),
  ),
  PecsCardData(
    id: 'break',
    category: 'Основные потребности',
    label: 'Перерыв',
    spokenText: 'Перерыв',
    pictogramBuilder: _svg('break.svg'),
  ),
  PecsCardData(
    id: 'done',
    category: 'Основные потребности',
    label: 'Готово',
    spokenText: 'Готово',
    pictogramBuilder: _svg('done.svg'),
  ),

  // Еда и напитки
  PecsCardData(
    id: 'water',
    category: 'Еда и напитки',
    label: 'Вода',
    spokenText: 'Вода',
    pictogramBuilder: _svg('water.svg'),
  ),
  PecsCardData(
    id: 'juice',
    category: 'Еда и напитки',
    label: 'Сок',
    spokenText: 'Сок',
    pictogramBuilder: _svg('juice.svg'),
  ),
  PecsCardData(
    id: 'milk',
    category: 'Еда и напитки',
    label: 'Молоко',
    spokenText: 'Молоко',
    pictogramBuilder: _svg('milk.svg'),
  ),
  PecsCardData(
    id: 'eat',
    category: 'Еда и напитки',
    label: 'Есть',
    spokenText: 'Есть',
    pictogramBuilder: _svg('eat.svg'),
  ),
  PecsCardData(
    id: 'drink',
    category: 'Еда и напитки',
    label: 'Пить',
    spokenText: 'Пить',
    pictogramBuilder: _svg('drink.svg'),
  ),
  PecsCardData(
    id: 'apple',
    category: 'Еда и напитки',
    label: 'Яблоко',
    spokenText: 'Яблоко',
    pictogramBuilder: _svg('apple.svg'),
  ),
  PecsCardData(
    id: 'banana',
    category: 'Еда и напитки',
    label: 'Банан',
    spokenText: 'Банан',
    pictogramBuilder: _svg('banana.svg'),
  ),
  PecsCardData(
    id: 'bread',
    category: 'Еда и напитки',
    label: 'Хлеб',
    spokenText: 'Хлеб',
    pictogramBuilder: _svg('bread.svg'),
  ),

  // Повседневные потребности
  PecsCardData(
    id: 'toilet',
    category: 'Повседневные потребности',
    label: 'Туалет',
    spokenText: 'Туалет',
    pictogramBuilder: _svg('toilet.svg'),
  ),
  PecsCardData(
    id: 'sleep',
    category: 'Повседневные потребности',
    label: 'Спать',
    spokenText: 'Спать',
    pictogramBuilder: _svg('sleep.svg'),
  ),
  PecsCardData(
    id: 'walk',
    category: 'Повседневные потребности',
    label: 'Гулять',
    spokenText: 'Гулять',
    pictogramBuilder: _svg('walk.svg'),
  ),
  PecsCardData(
    id: 'home',
    category: 'Повседневные потребности',
    label: 'Домой',
    spokenText: 'Домой',
    pictogramBuilder: _svg('home.svg'),
  ),
  PecsCardData(
    id: 'play',
    category: 'Повседневные потребности',
    label: 'Играть',
    spokenText: 'Играть',
    pictogramBuilder: _svg('play.svg'),
  ),
  PecsCardData(
    id: 'read',
    category: 'Повседневные потребности',
    label: 'Читать',
    spokenText: 'Читать',
    pictogramBuilder: _svg('read.svg'),
  ),
  PecsCardData(
    id: 'watch',
    category: 'Повседневные потребности',
    label: 'Смотреть',
    spokenText: 'Смотреть',
    // Подходящего символа "смотреть" в наборе Mulberry Symbols нет.
    pictogramBuilder: _icon(Icons.tv, _dailyColor),
  ),
  PecsCardData(
    id: 'listen',
    category: 'Повседневные потребности',
    label: 'Слушать',
    spokenText: 'Слушать',
    pictogramBuilder: _svg('listen.svg'),
  ),
  PecsCardData(
    id: 'dress',
    category: 'Повседневные потребности',
    label: 'Одеваться',
    spokenText: 'Одеваться',
    pictogramBuilder: _svg('dress.svg'),
  ),
  PecsCardData(
    id: 'wash_hands',
    category: 'Повседневные потребности',
    label: 'Мыть руки',
    spokenText: 'Мыть руки',
    pictogramBuilder: _svg('wash_hands.svg'),
  ),

  // Эмоции
  PecsCardData(
    id: 'happy',
    category: 'Эмоции',
    label: 'Я рад',
    spokenText: 'Я рад',
    pictogramBuilder: _svg('happy.svg'),
  ),
  PecsCardData(
    id: 'sad',
    category: 'Эмоции',
    label: 'Мне грустно',
    spokenText: 'Мне грустно',
    pictogramBuilder: _svg('sad.svg'),
  ),
  PecsCardData(
    id: 'angry',
    category: 'Эмоции',
    label: 'Я злюсь',
    spokenText: 'Я злюсь',
    pictogramBuilder: _svg('angry.svg'),
  ),
  PecsCardData(
    id: 'scared',
    category: 'Эмоции',
    label: 'Мне страшно',
    spokenText: 'Мне страшно',
    pictogramBuilder: _svg('scared.svg'),
  ),
  PecsCardData(
    id: 'tired',
    category: 'Эмоции',
    label: 'Я устал',
    spokenText: 'Я устал',
    pictogramBuilder: _svg('tired.svg'),
  ),
  PecsCardData(
    id: 'bad',
    category: 'Эмоции',
    label: 'Мне плохо',
    spokenText: 'Мне плохо',
    // Подходящего символа "плохо себя чувствую" в наборе Mulberry Symbols нет.
    pictogramBuilder: (size) => FacePictogram(mood: FaceMood.sick, size: size * 0.68),
  ),
  PecsCardData(
    id: 'good',
    category: 'Эмоции',
    label: 'Мне хорошо',
    spokenText: 'Мне хорошо',
    // Подходящего символа "хорошо себя чувствую" в наборе Mulberry Symbols нет.
    pictogramBuilder: (size) => FacePictogram(mood: FaceMood.good, size: size * 0.68),
  ),

  // Очень важные карточки
  PecsCardData(
    id: 'hurts',
    category: 'Очень важные карточки',
    label: 'Мне больно',
    spokenText: 'Мне больно',
    // Подходящего символа "больно" в наборе Mulberry Symbols нет.
    pictogramBuilder: (size) => FacePictogram(mood: FaceMood.pain, size: size * 0.68),
  ),
  PecsCardData(
    id: 'help_me',
    category: 'Очень важные карточки',
    label: 'Помоги мне',
    spokenText: 'Помоги мне',
    pictogramBuilder: _svg('help.svg'),
  ),
  PecsCardData(
    id: 'need_break',
    category: 'Очень важные карточки',
    label: 'Мне нужен перерыв',
    spokenText: 'Мне нужен перерыв',
    pictogramBuilder: _svg('break.svg'),
  ),
  PecsCardData(
    id: 'too_loud',
    category: 'Очень важные карточки',
    label: 'Слишком громко',
    spokenText: 'Слишком громко',
    pictogramBuilder: _svg('too_loud.svg'),
  ),
  PecsCardData(
    id: 'hot',
    category: 'Очень важные карточки',
    label: 'Мне жарко',
    spokenText: 'Мне жарко',
    pictogramBuilder: _svg('hot.svg'),
  ),
  PecsCardData(
    id: 'cold',
    category: 'Очень важные карточки',
    label: 'Мне холодно',
    spokenText: 'Мне холодно',
    // Подходящего символа "холодно" в наборе Mulberry Symbols нет.
    pictogramBuilder: (size) => SnowflakePictogram(size: size * 0.68),
  ),
  PecsCardData(
    id: 'dont_understand',
    category: 'Очень важные карточки',
    label: 'Я не понимаю',
    spokenText: 'Я не понимаю',
    pictogramBuilder: _svg('dont_understand.svg'),
  ),
  PecsCardData(
    id: 'want_to_leave',
    category: 'Очень важные карточки',
    label: 'Я хочу уйти',
    spokenText: 'Я хочу уйти',
    pictogramBuilder: _svg('want_to_leave.svg'),
  ),

  // Люди
  PecsCardData(
    id: 'mom',
    category: 'Люди',
    label: 'Мама',
    spokenText: 'Мама',
    pictogramBuilder: _svg('mom.svg'),
  ),
  PecsCardData(
    id: 'dad',
    category: 'Люди',
    label: 'Папа',
    spokenText: 'Папа',
    pictogramBuilder: _svg('dad.svg'),
  ),
  PecsCardData(
    id: 'grandma',
    category: 'Люди',
    label: 'Бабушка',
    spokenText: 'Бабушка',
    pictogramBuilder: _svg('grandma.svg'),
  ),
  PecsCardData(
    id: 'grandpa',
    category: 'Люди',
    label: 'Дедушка',
    spokenText: 'Дедушка',
    pictogramBuilder: _svg('grandpa.svg'),
  ),
  PecsCardData(
    id: 'teacher',
    category: 'Люди',
    label: 'Учитель',
    spokenText: 'Учитель',
    pictogramBuilder: _svg('teacher.svg'),
  ),
  PecsCardData(
    id: 'friend',
    category: 'Люди',
    label: 'Друг',
    spokenText: 'Друг',
    // Подходящего символа "друг" в наборе Mulberry Symbols нет.
    pictogramBuilder: _icon(Icons.people, _peopleColor),
  ),
];

List<PecsCardData> pecsCardsByCategory(String category) =>
    kPecsCards.where((c) => c.category == category).toList();
