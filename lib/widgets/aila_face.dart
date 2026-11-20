// lib/widgets/aila_face.dart

import 'package:flutter/material.dart';

/// Выражения Айлы (`assets/aila/*.png`, вырезаны скриптом
/// `tool/cut_sheet.swift`). Каждое показывается в своём месте, а не наугад.
enum AilaMood {
  smile('aila_smile'),
  wink('aila_wink2'),
  joy('aila_joy'),
  peek('aila_peek'),
  worried('aila_worried'),
  hug('aila_hug'),
  surprised('aila_surprised'),
  sleep('aila_sleep'),
  angry('aila_angry'),
  shy('aila_shy'),
  excited('aila_excited'),
  content('aila_content');

  final String file;

  const AilaMood(this.file);

  String get asset => 'assets/aila/$file.png';
}

class AilaFace extends StatelessWidget {
  final AilaMood mood;
  final double size;

  const AilaFace(this.mood, {super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      mood.asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Для программ чтения с экрана Айла просто картинка.
      excludeFromSemantics: true,
    );
  }
}
