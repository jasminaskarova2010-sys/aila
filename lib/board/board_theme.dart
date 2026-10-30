// lib/board/board_theme.dart

import 'package:flutter/material.dart';

import 'board_words.dart';

/// Цвета доски в одном месте: мягкие пастельные рамки по типу слова (П12).
class BoardTheme {
  static const background = Color(0xFFFAF0EA);
  static const ink = Color(0xFF331A47);
  static const muted = Color(0xFF9B8FAE);

  static const people = Color(0xFFF2D98B);
  static const actions = Color(0xFFAEDAB4);
  static const objects = Color(0xFFF6C99E);
  static const descriptions = Color(0xFFAED6EE);
  static const social = Color(0xFFF2C2D2);
  static const questions = Color(0xFFCFC3EA);
  static const feelings = Color(0xFFB9CFEE);
  static const starters = Color(0xFFF2C2D2);

  static Color frameFor(BoardWord word) {
    switch (word.category) {
      case BoardCategory.people:
        return people;
      case BoardCategory.actions:
        return actions;
      case BoardCategory.descriptions:
        return descriptions;
      case BoardCategory.feelings:
        return feelings;
      case BoardCategory.home:
        return social;
      case BoardCategory.starters:
        return starters;
      case BoardCategory.food:
      case BoardCategory.drinks:
      case BoardCategory.toys:
      case BoardCategory.places:
        return objects;
    }
  }
}
