// lib/games/categorize_game_screen.dart

import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_shell.dart';

class CategorizeGameScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final VoidCallback onComplete;

  const CategorizeGameScreen({
    super.key,
    required this.step,
    required this.total,
    required this.onComplete,
  });

  @override
  State<CategorizeGameScreen> createState() => _CategorizeGameScreenState();
}

class _CategorizeGameScreenState extends State<CategorizeGameScreen> {
  late List<CategorizeItemData> _pool;
  int _inA = 0;
  int _inB = 0;
  bool _solved = false;
  CategorizeItemData? _rejectedItem;

  @override
  void initState() {
    super.initState();
    _pool = List.of(widget.step.categorizeItems)..shuffle();
  }

  void _drop(CategorizeItemData item, bool basketA) {
    final correct = item.belongsToA == basketA;
    if (!correct) {
      setState(() => _rejectedItem = item);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _rejectedItem = null);
      });
      return;
    }
    setState(() {
      _pool.remove(item);
      if (basketA) {
        _inA++;
      } else {
        _inB++;
      }
      if (_pool.isEmpty) _solved = true;
    });
  }

  Widget _basket({
    required String label,
    required Widget Function(double size)? pictogramBuilder,
    required int count,
    required int totalForBasket,
    required bool isA,
    required Color color,
  }) {
    return Expanded(
      child: DragTarget<CategorizeItemData>(
        onAcceptWithDetails: (details) => _drop(details.data, isA),
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: candidateData.isNotEmpty ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (pictogramBuilder != null) pictogramBuilder(30),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.inbox_outlined, color: color, size: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count / $totalForBasket',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final totalA = step.categorizeItems.where((i) => i.belongsToA).length;
    final totalB = step.categorizeItems.length - totalA;

    return GameShell(
      index: step.index,
      total: widget.total,
      title: step.title,
      subtitle: step.subtitle,
      solved: _solved,
      feedbackTitle: step.successTitle,
      feedbackBody: step.successBody,
      onContinue: widget.onComplete,
      content: Column(
        children: [
          Row(
            children: [
              _basket(
                label: step.categoryALabel,
                pictogramBuilder: step.categoryAPictogramBuilder,
                count: _inA,
                totalForBasket: totalA,
                isA: true,
                color: const Color(0xFF6EA34F),
              ),
              const SizedBox(width: 14),
              _basket(
                label: step.categoryBLabel,
                pictogramBuilder: step.categoryBPictogramBuilder,
                count: _inB,
                totalForBasket: totalB,
                isA: false,
                color: const Color(0xFF4A7FBF),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _pool.map((item) {
              final rejected = _rejectedItem == item;
              final card = AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rejected ? const Color(0xFFFBE1DF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF331A47).withOpacity(0.08),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: item.pictogramBuilder(40),
              );
              return Draggable<CategorizeItemData>(
                data: item,
                feedback: Opacity(opacity: 0.85, child: card),
                childWhenDragging: Opacity(opacity: 0.3, child: card),
                child: card,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
