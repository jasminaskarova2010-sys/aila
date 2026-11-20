// lib/widgets/aila_with_items.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wardrobe/wardrobe_items.dart';

/// Айла в аксессуарах. Предметы стоят в долях размера картинки, поэтому образ
/// выглядит одинаково при любом размере.
class AilaWithItems extends StatelessWidget {
  final List<String> itemIds;
  final double size;

  const AilaWithItems({super.key, required this.itemIds, required this.size});

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final id in itemIds)
        if (findWardrobeItem(id) case final item?) item,
    ]..sort((a, b) => a.layer - b.layer);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/aila/aila_smile.png',
              fit: BoxFit.contain,
            ),
          ),
          for (final item in items)
            Positioned(
              left: item.cx * size,
              top: item.cy * size,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.rotate(
                  angle: item.rotation * math.pi / 180,
                  child: SizedBox(
                    width: item.width * size,
                    child: Image.asset(
                      item.asset,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
