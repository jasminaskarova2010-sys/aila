// lib/games/missing_photo_placeholder.dart
//
// Показывается вместо контента, для которого пока нет подходящего реального
// фото и который нельзя корректно заменить абстрактной иллюстрацией (люди,
// эмоции, социальные ситуации). Явно сигнализирует "здесь нужен реальный
// снимок", а не подменяет его случайной картинкой.

import 'package:flutter/material.dart';

class MissingPhotoPlaceholder extends StatelessWidget {
  final String note;
  final double size;

  const MissingPhotoPlaceholder({
    super.key,
    required this.note,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEF9),
        borderRadius: BorderRadius.circular(size * 0.16),
        border: Border.all(color: const Color(0xFFE3DCEC), width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: const Color(0xFF9B8FAE),
            size: size * 0.34,
          ),
          SizedBox(height: size * 0.04),
          Text(
            note,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF9B8FAE),
              fontSize: size * 0.085,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
