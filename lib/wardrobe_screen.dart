// lib/wardrobe_screen.dart

import 'package:flutter/material.dart';

import 'l10n/strings.dart';
import 'parent/pin_screens.dart';
import 'settings_screen.dart';
import 'state/app_state.dart';
import 'wardrobe/wardrobe_items.dart';
import 'widgets/aila_with_items.dart';

/// Гардероб Айлы: примерка аксессуаров, покупка за звёзды, сохранённый образ.
/// Нажатие на предмет надевает его на Айлу «на пробу», а покупается и
/// сохраняется образ целиком кнопкой внизу.
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  static const _ink = Color(0xFF331A47);

  List<String>? _look;
  WardrobeCategory? _category;

  void _toggle(WardrobeItem item, List<String> look) {
    final next = look.contains(item.id)
        ? look.where((id) => id != item.id).toList()
        : normalizeLook([...look, item.id]);
    setState(() => _look = next);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final saved = appState.equippedItemIds;
    final look = _look ?? saved;
    final shown = [
      for (final item in kWardrobeItems)
        if (_category == null || item.category == _category) item,
    ];
    final toBuy = [
      for (final id in look)
        if (!appState.isOwned(id) && findWardrobeItem(id) != null)
          findWardrobeItem(id)!,
    ];
    final cost = toBuy.fold<int>(0, (sum, item) => sum + item.price);
    final changed = !_sameLook(look, saved);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFDF3E4), Color(0xFFFCE9D2)],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 56),
                      _StatPill(value: '${appState.stars}'),
                      Column(
                        children: [
                          _CircleIconButton(
                            icon: Icons.settings,
                            onTap: () => openParentArea(
                              context,
                              (context) => const SettingsScreen(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.settingsTitle,
                            style: TextStyle(
                              color: _ink.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      s.wardrobeTitle,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      s.wardrobeSubtitle,
                      style: TextStyle(
                        color: _ink.withOpacity(0.55),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Preview(look: look),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: s.wardrobeAll,
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final category in WardrobeCategory.values)
                          _CategoryChip(
                            label: s.wardrobeCategory(category),
                            selected: _category == category,
                            onTap: () => setState(() => _category = category),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final item in shown)
                        _ItemTile(
                          item: item,
                          owned: appState.isOwned(item.id),
                          tried: look.contains(item.id),
                          onTap: () => _toggle(item, look),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: look.isEmpty && saved.isEmpty
                              ? null
                              : () => setState(() => _look = const []),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(color: Color(0xFFE3DCEC)),
                          ),
                          child: Text(
                            s.wardrobeTakeOff,
                            style: const TextStyle(color: _ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: toBuy.isEmpty && !changed
                              ? null
                              : () => _confirm(context, look, toBuy, cost),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ink,
                            disabledBackgroundColor: const Color(0xFFB3ACC0),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            toBuy.isEmpty
                                ? s.wardrobeSaveLook
                                : s.wardrobeBuy(cost),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameLook(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  void _confirm(
    BuildContext context,
    List<String> look,
    List<WardrobeItem> toBuy,
    int cost,
  ) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (cost > appState.stars) {
      messenger.showSnackBar(SnackBar(content: Text(s.wardrobeNotEnoughStars)));
      return;
    }
    for (final item in toBuy) {
      appState.purchase(item.id, item.price);
    }
    appState.setLook(look);
    setState(() => _look = null);
    messenger.showSnackBar(SnackBar(content: Text(s.wardrobeSaved)));
  }
}

class _Preview extends StatelessWidget {
  final List<String> look;

  const _Preview({required this.look});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF331A47).withOpacity(0.06),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Подставка под Айлой.
          Positioned(
            bottom: 26,
            child: Container(
              width: 210,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEF9),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            child: AilaWithItems(itemIds: look, size: 250),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFE3DAEE),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(
          color: Color(0xFF331A47),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final WardrobeItem item;
  final bool owned;
  final bool tried;
  final VoidCallback onTap;

  const _ItemTile({
    required this.item,
    required this.owned,
    required this.tried,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: tried ? const Color(0xFF331A47) : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 64,
                height: 52,
                child: Image.asset(
                  item.asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                child: Text(
                  s.wardrobeItemName(item.id),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF331A47),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (owned)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF5E9B45),
                      size: 15,
                    )
                  else
                    const Icon(Icons.star, color: Color(0xFFE0A93E), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    owned ? s.wardrobeOwned : '${item.price}',
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
  final String value;

  const _StatPill({required this.value});

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
          const Icon(Icons.star, color: Color(0xFFE0A93E), size: 16),
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
