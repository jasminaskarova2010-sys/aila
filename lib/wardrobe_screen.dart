// lib/wardrobe_screen.dart

import 'package:flutter/material.dart';
import 'l10n/strings.dart';
import 'state/app_state.dart';
import 'settings_screen.dart';
import 'parent/pin_screens.dart';
import 'wardrobe/wardrobe_items.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String? _pendingId;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final pendingId = _pendingId ?? appState.equippedOutfitId;
    final pendingItem = findWardrobeItem(pendingId);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFFDF3E4),
                    Color(0xFFFCE9D2),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 56),
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.star,
                            iconColor: const Color(0xFFE0A93E),
                            value: '${appState.stars}',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          _CircleIconButton(
                            icon: Icons.settings,
                            onTap: () {
                              openParentArea(
                                context,
                                (context) => const SettingsScreen(),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.settingsTitle,
                            style: TextStyle(
                              color: const Color(0xFF331A47).withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF331A47).withOpacity(0.06),
                          offset: const Offset(0, 6),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFF331A47),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.checkroom,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.wardrobeTitle,
                                style: const TextStyle(
                                  color: Color(0xFF331A47),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.wardrobeSubtitle,
                                style: TextStyle(
                                  color: const Color(0xFF331A47).withOpacity(0.55),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.cloud,
                            color: Color(0xFFB8A9DE), size: 28),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (pendingItem?.color ??
                                        const Color(0xFFFDF0D5))
                                    .withOpacity(0.25),
                              ),
                            ),
                            Image.asset('assets/star_mascot.png',
                                width: 150, fit: BoxFit.contain),
                            if (pendingItem != null)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: pendingItem.color, width: 2),
                                  ),
                                  child: Text(pendingItem.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF331A47).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _pendingId = appState.equippedOutfitId),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(color: Color(0xFFE3DCEC)),
                          ),
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFF331A47), size: 18),
                          label: Text(s.wardrobeReset,
                              style: TextStyle(color: Color(0xFF331A47))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            appState.equip(pendingId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.wardrobeSaved)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF331A47),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                          label: Text(s.saveButton,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: kWardrobeItems.map((item) {
                      final owned = appState.isOwned(item.id);
                      final selected = pendingId == item.id;
                      return _WardrobeCard(
                        item: item,
                        owned: owned,
                        selected: selected,
                        onTap: () {
                          if (owned) {
                            setState(() => _pendingId = item.id);
                            return;
                          }
                          final bought = appState.purchase(item.id, item.price);
                          if (bought) {
                            setState(() => _pendingId = item.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(s.wardrobeNotEnoughStars)),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeCard extends StatelessWidget {
  final WardrobeItem item;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  const _WardrobeCard({
    required this.item,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF8677A5) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).wardrobeItemName(item.id),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE0A93E), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        owned ? S.of(context).wardrobeOwned : '${item.price}',
                        style: const TextStyle(
                          color: Color(0xFF331A47),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6EA34F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF331A47), size: 20),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF331A47).withOpacity(0.06),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF331A47),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
