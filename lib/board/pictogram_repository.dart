// lib/board/pictogram_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'board_words.dart';
import 'parent_media.dart';

enum PictogramSet { mulberry, arasaac }

/// Набор картинок всей доски. Одна настройка: поменяйте на
/// [PictogramSet.arasaac], и доска покажет все 60 картинок ARASAAC.
///
/// Mulberry (CC BY-SA 4.0) выбрала владелица как основной набор. Слов, которых
/// в нём нет, показываются из ARASAAC (CC BY-NC-SA, только некоммерческое
/// использование): если приложение станет платным, их надо заменить.
const PictogramSet kPictogramSet = PictogramSet.mulberry;

/// Единственное место, которое знает, откуда берётся картинка слова.
class PictogramRepository {
  /// Слово → файл в assets/pecs_symbols/. Слов, которых здесь нет, в Mulberry
  /// не нашлось (см. assets/pictograms/arasaac/manifest.json).
  static const Map<String, String> _mulberryFiles = {
    'i_want': 'want.svg',
    'i_see': 'see.svg',
    'i_hear': 'hear.svg',
    'this_is': 'this.svg',
    'yes': 'yes.svg',
    'no': 'no.svg',
    'help': 'help.svg',
    'more': 'more.svg',
    'done': 'done.svg',
    'break': 'break.svg',
    'hello': 'hello.svg',
    'water': 'water.svg',
    'juice': 'juice.svg',
    'milk': 'milk.svg',
    'apple': 'apple.svg',
    'banana': 'banana.svg',
    'cookie': 'cookie.svg',
    'bread': 'bread.svg',
    'porridge': 'porridge.svg',
    'ice_cream': 'ice_cream.svg',
    'ball': 'ball.svg',
    'toy_car': 'toy_car.svg',
    'blocks': 'blocks.svg',
    'bubbles': 'bubbles.svg',
    'book': 'read.svg',
    'draw': 'draw.svg',
    'music': 'music.svg',
    'eat': 'eat.svg',
    'drink': 'drink.svg',
    'play': 'play.svg',
    'go': 'walk.svg',
    'sleep': 'sleep.svg',
    'wash_hands': 'wash_hands.svg',
    'toilet': 'toilet.svg',
    'open': 'open.svg',
    'mom': 'mom.svg',
    'dad': 'dad.svg',
    'grandma': 'grandma.svg',
    'grandpa': 'grandpa.svg',
    'brother': 'brother.svg',
    'sister': 'sister.svg',
    'good': 'good.svg',
    'bad': 'bad.svg',
    'tired': 'tired.svg',
    'sad': 'sad.svg',
    'angry': 'angry.svg',
    'scared': 'scared.svg',
    'big': 'big.svg',
    'small': 'small.svg',
    'red': 'red.svg',
    'blue': 'blue.svg',
    'yellow': 'yellow.svg',
    'green': 'green.svg',
  };

  static String assetPath(String wordId, {PictogramSet set = kPictogramSet}) {
    final mulberry = _mulberryFiles[wordId];
    if (set == PictogramSet.mulberry && mulberry != null) {
      return 'assets/pecs_symbols/$mulberry';
    }
    return 'assets/pictograms/arasaac/$wordId.png';
  }

  static Widget image(BoardWord word, double size) {
    if (word.imageFile != null) {
      final file = ParentMedia.file(word.imageFile);
      if (file == null) return _missing(size);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _missing(size),
        ),
      );
    }
    final path = assetPath(word.id);
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, width: size, height: size);
    }
    return Image.asset(path, width: size, height: size, fit: BoxFit.contain);
  }

  static Widget _missing(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFF2EEF9),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
