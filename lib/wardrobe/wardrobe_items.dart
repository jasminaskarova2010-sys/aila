// lib/wardrobe/wardrobe_items.dart

import 'package:flutter/material.dart';

/// Наряд Айлы. Название на языке профиля — `S.wardrobeItemName(id)`.
class WardrobeItem {
  final String id;
  final String emoji;
  final int price;
  final Color color;

  const WardrobeItem({
    required this.id,
    required this.emoji,
    required this.price,
    required this.color,
  });
}

const List<WardrobeItem> kWardrobeItems = [
  WardrobeItem(
    id: 'hoodie_purple',
    emoji: '🧥',
    price: 800,
    color: Color(0xFFB8A9DE),
  ),
  WardrobeItem(
    id: 'tshirt_white',
    emoji: '👕',
    price: 500,
    color: Color(0xFFEDE6DC),
  ),
  WardrobeItem(
    id: 'dress_pink',
    emoji: '👗',
    price: 1200,
    color: Color(0xFFE7B7C9),
  ),
  WardrobeItem(
    id: 'dragon_green',
    emoji: '🐉',
    price: 1500,
    color: Color(0xFF9CC28B),
  ),
  WardrobeItem(
    id: 'sweater_yellow',
    emoji: '🧶',
    price: 600,
    color: Color(0xFFE0A93E),
  ),
  WardrobeItem(
    id: 'overalls_blue',
    emoji: '👖',
    price: 900,
    color: Color(0xFF7FA6D6),
  ),
  WardrobeItem(
    id: 'sailor',
    emoji: '⚓',
    price: 1300,
    color: Color(0xFF6E93C4),
  ),
  WardrobeItem(
    id: 'royal_cape',
    emoji: '👑',
    price: 2000,
    color: Color(0xFF8677A5),
  ),
];

WardrobeItem? findWardrobeItem(String id) {
  for (final item in kWardrobeItems) {
    if (item.id == id) return item;
  }
  return null;
}
