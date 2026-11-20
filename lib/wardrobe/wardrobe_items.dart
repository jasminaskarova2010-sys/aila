// lib/wardrobe/wardrobe_items.dart

/// Вкладка гардероба.
enum WardrobeCategory { hats, glasses, headphones, bows, headbands, crowns }

/// Место на Айле: в каждом месте надет один предмет. Шапка и корона не
/// надеваются вместе, очки и маска сна тоже.
enum WardrobeSlot { top, ears, face, bow }

/// Аксессуар Айлы. Картинка вырезана скриптом `tool/cut_items.swift`.
/// `cx`, `cy` — центр предмета на Айле, `width` — ширина, всё в долях ширины
/// картинки Айлы (`aila_smile.png`), `rotation` — поворот в градусах.
/// Название на языке профиля: `S.wardrobeItemName(id)`.
class WardrobeItem {
  final String id;
  final WardrobeCategory category;
  final WardrobeSlot slot;
  final int price;
  final double cx;
  final double cy;
  final double width;
  final double rotation;

  const WardrobeItem({
    required this.id,
    required this.category,
    required this.slot,
    required this.price,
    required this.cx,
    required this.cy,
    required this.width,
    this.rotation = 0,
  });

  String get asset => 'assets/wardrobe/$id.png';

  /// Порядок отрисовки: дужка наушников под шапкой, очки поверх всего.
  int get layer {
    switch (slot) {
      case WardrobeSlot.ears:
        return 0;
      case WardrobeSlot.top:
        return 1;
      case WardrobeSlot.bow:
        return 2;
      case WardrobeSlot.face:
        return 3;
    }
  }
}

// Цены из макета гардероба. Звёзды: 50 за задание, 8 заданий в день.
const List<WardrobeItem> kWardrobeItems = [
  // Шапки
  WardrobeItem(
    id: 'hat_bucket',
    category: WardrobeCategory.hats,
    slot: WardrobeSlot.top,
    price: 150,
    cx: 0.47,
    cy: 0.19,
    width: 0.62,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'hat_beret',
    category: WardrobeCategory.hats,
    slot: WardrobeSlot.top,
    price: 150,
    cx: 0.47,
    cy: 0.19,
    width: 0.6,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'hat_beanie',
    category: WardrobeCategory.hats,
    slot: WardrobeSlot.top,
    price: 140,
    cx: 0.47,
    cy: 0.18,
    width: 0.55,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'hat_cap',
    category: WardrobeCategory.hats,
    slot: WardrobeSlot.top,
    price: 130,
    cx: 0.47,
    cy: 0.19,
    width: 0.62,
    rotation: -8,
  ),
  // Очки
  WardrobeItem(
    id: 'glasses_flower',
    category: WardrobeCategory.glasses,
    slot: WardrobeSlot.face,
    price: 100,
    cx: 0.52,
    cy: 0.49,
    width: 0.54,
    rotation: -11,
  ),
  WardrobeItem(
    id: 'glasses_black',
    category: WardrobeCategory.glasses,
    slot: WardrobeSlot.face,
    price: 140,
    cx: 0.52,
    cy: 0.49,
    width: 0.54,
    rotation: -11,
  ),
  WardrobeItem(
    id: 'glasses_heart',
    category: WardrobeCategory.glasses,
    slot: WardrobeSlot.face,
    price: 110,
    cx: 0.52,
    cy: 0.49,
    width: 0.54,
    rotation: -11,
  ),
  WardrobeItem(
    id: 'glasses_round',
    category: WardrobeCategory.glasses,
    slot: WardrobeSlot.face,
    price: 120,
    cx: 0.52,
    cy: 0.49,
    width: 0.54,
    rotation: -11,
  ),
  // Наушники
  WardrobeItem(
    id: 'phones_purple',
    category: WardrobeCategory.headphones,
    slot: WardrobeSlot.ears,
    price: 120,
    cx: 0.50,
    cy: 0.43,
    width: 0.94,
  ),
  WardrobeItem(
    id: 'phones_cat',
    category: WardrobeCategory.headphones,
    slot: WardrobeSlot.ears,
    price: 130,
    cx: 0.50,
    cy: 0.43,
    width: 0.94,
  ),
  WardrobeItem(
    id: 'phones_blue',
    category: WardrobeCategory.headphones,
    slot: WardrobeSlot.ears,
    price: 130,
    cx: 0.50,
    cy: 0.43,
    width: 0.94,
  ),
  WardrobeItem(
    id: 'phones_cream',
    category: WardrobeCategory.headphones,
    slot: WardrobeSlot.ears,
    price: 140,
    cx: 0.50,
    cy: 0.43,
    width: 0.94,
  ),
  // Банты
  WardrobeItem(
    id: 'bow_purple',
    category: WardrobeCategory.bows,
    slot: WardrobeSlot.bow,
    price: 80,
    cx: 0.73,
    cy: 0.20,
    width: 0.34,
    rotation: 12,
  ),
  WardrobeItem(
    id: 'bow_pink',
    category: WardrobeCategory.bows,
    slot: WardrobeSlot.bow,
    price: 80,
    cx: 0.73,
    cy: 0.20,
    width: 0.34,
    rotation: 12,
  ),
  WardrobeItem(
    id: 'bow_cream',
    category: WardrobeCategory.bows,
    slot: WardrobeSlot.bow,
    price: 90,
    cx: 0.73,
    cy: 0.20,
    width: 0.34,
    rotation: 12,
  ),
  WardrobeItem(
    id: 'bow_plaid',
    category: WardrobeCategory.bows,
    slot: WardrobeSlot.bow,
    price: 100,
    cx: 0.73,
    cy: 0.20,
    width: 0.34,
    rotation: 12,
  ),
  WardrobeItem(
    id: 'star_clip',
    category: WardrobeCategory.bows,
    slot: WardrobeSlot.bow,
    price: 70,
    cx: 0.29,
    cy: 0.23,
    width: 0.22,
    rotation: -20,
  ),
  // Ободки
  WardrobeItem(
    id: 'band_cat',
    category: WardrobeCategory.headbands,
    slot: WardrobeSlot.top,
    price: 160,
    cx: 0.47,
    cy: 0.18,
    width: 0.62,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'band_heart',
    category: WardrobeCategory.headbands,
    slot: WardrobeSlot.top,
    price: 110,
    cx: 0.47,
    cy: 0.17,
    width: 0.55,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'band_flowers',
    category: WardrobeCategory.headbands,
    slot: WardrobeSlot.top,
    price: 180,
    cx: 0.47,
    cy: 0.24,
    width: 0.62,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'band_bunny',
    category: WardrobeCategory.headbands,
    slot: WardrobeSlot.top,
    price: 160,
    cx: 0.47,
    cy: 0.15,
    width: 0.55,
    rotation: -8,
  ),
  // Короны и другое
  WardrobeItem(
    id: 'crown_gold',
    category: WardrobeCategory.crowns,
    slot: WardrobeSlot.top,
    price: 200,
    cx: 0.47,
    cy: 0.17,
    width: 0.43,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'tiara',
    category: WardrobeCategory.crowns,
    slot: WardrobeSlot.top,
    price: 190,
    cx: 0.47,
    cy: 0.18,
    width: 0.5,
    rotation: -8,
  ),
  WardrobeItem(
    id: 'sleep_mask',
    category: WardrobeCategory.crowns,
    slot: WardrobeSlot.face,
    price: 90,
    cx: 0.52,
    cy: 0.49,
    width: 0.56,
    rotation: -11,
  ),
];

WardrobeItem? findWardrobeItem(String id) {
  for (final item in kWardrobeItems) {
    if (item.id == id) return item;
  }
  return null;
}

/// Образ без повторов в одном месте: если два предмета претендуют на одно место,
/// остаётся последний. Неизвестные номера (старых сохранений) отбрасываются.
List<String> normalizeLook(Iterable<String> ids) {
  final bySlot = <WardrobeSlot, String>{};
  for (final id in ids) {
    final item = findWardrobeItem(id);
    if (item != null) bySlot[item.slot] = id;
  }
  return bySlot.values.toList();
}
