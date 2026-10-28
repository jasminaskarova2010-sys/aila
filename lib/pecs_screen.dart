// lib/pecs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'pecs/pecs_data.dart';

class PecsScreen extends StatefulWidget {
  const PecsScreen({super.key});

  @override
  State<PecsScreen> createState() => _PecsScreenState();
}

class _PecsScreenState extends State<PecsScreen> {
  final FlutterTts _tts = FlutterTts();
  final List<PecsCardData> _sentence = [];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('ru-RU');
    _tts.setSpeechRate(0.42);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _addCard(PecsCardData card) {
    setState(() => _sentence.add(card));
    _speak(card.spokenText);
  }

  void _removeAt(int index) {
    setState(() => _sentence.removeAt(index));
  }

  void _clear() {
    setState(() => _sentence.clear());
  }

  void _say() {
    if (_sentence.isEmpty) return;
    final phrase = _sentence.map((c) => c.spokenText).join(', ');
    _speak(phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).pop(),
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
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF331A47), size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Карточки PECS',
                          style: TextStyle(
                            color: Color(0xFF331A47),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Нажми на карточку, чтобы её озвучить',
                          style: TextStyle(
                            color: Color(0xFF9B8FAE),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 74),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3DCEC), width: 1.4),
                ),
                child: _sentence.isEmpty
                    ? Center(
                        child: Text(
                          'Составленная фраза появится здесь',
                          style: TextStyle(
                            color: const Color(0xFF331A47).withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_sentence.length, (i) {
                          final card = _sentence[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _removeAt(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF0D5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                card.label,
                                style: const TextStyle(
                                  color: Color(0xFF331A47),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sentence.isEmpty ? null : _clear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Color(0xFFE3DCEC)),
                      ),
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF331A47)),
                      label: const Text('Очистить',
                          style: TextStyle(color: Color(0xFF331A47))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _sentence.isEmpty ? null : _say,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF331A47),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up, size: 18, color: Colors.white),
                      label: const Text('Сказать фразу',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: kPecsCategoryOrder.length,
                itemBuilder: (context, i) {
                  final categoryName = kPecsCategoryOrder[i];
                  final info = kPecsCategoryInfo[categoryName]!;
                  final cards = pecsCardsByCategory(categoryName);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: const TextStyle(
                            color: Color(0xFF331A47),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: cards
                              .map((card) => PecsCardTile(
                                    card: card,
                                    background: info.background,
                                    onTap: () => _addCard(card),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Иконки: Mulberry Symbols (CC BY-SA 4.0), © Steve Lee',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF331A47).withOpacity(0.35),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PecsCardTile extends StatelessWidget {
  final PecsCardData card;
  final Color background;
  final VoidCallback onTap;

  const PecsCardTile({
    super.key,
    required this.card,
    required this.background,
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
          width: 104,
          height: 128,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: card.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(card.image!, fit: BoxFit.contain),
                        )
                      : card.pictogramBuilder(72),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xFF331A47),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
