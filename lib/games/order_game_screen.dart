// lib/games/order_game_screen.dart

import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_shell.dart';

class OrderGameScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final VoidCallback onComplete;

  const OrderGameScreen({
    super.key,
    required this.step,
    required this.total,
    required this.onComplete,
  });

  @override
  State<OrderGameScreen> createState() => _OrderGameScreenState();
}

class _OrderGameScreenState extends State<OrderGameScreen> {
  late List<OrderItemData?> _slots;
  late List<OrderItemData> _pool;
  bool _solved = false;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _slots = List.filled(widget.step.orderItems.length, null);
    _pool = List.of(widget.step.orderItems)..shuffle();
  }

  void _placeInSlot(int slotIndex, OrderItemData item) {
    if (_slots[slotIndex] != null) return;
    setState(() {
      _slots[slotIndex] = item;
      _pool.remove(item);
      _wrong = false;
    });
    if (_slots.every((s) => s != null)) {
      _check();
    }
  }

  void _removeFromSlot(int slotIndex) {
    final item = _slots[slotIndex];
    if (item == null) return;
    setState(() {
      _slots[slotIndex] = null;
      _pool.add(item);
      _wrong = false;
    });
  }

  void _check() {
    final correct = List.generate(
      widget.step.orderItems.length,
      (i) => _slots[i] == widget.step.orderItems[i],
    ).every((v) => v);
    if (correct) {
      setState(() => _solved = true);
    } else {
      setState(() => _wrong = true);
    }
  }

  void _reset() {
    setState(() {
      _slots = List.filled(widget.step.orderItems.length, null);
      _pool = List.of(widget.step.orderItems)..shuffle();
      _wrong = false;
    });
  }

  Widget _thumb(OrderItemData item, double size) {
    if (item.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          item.imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (item.pictogramBuilder != null) {
      return item.pictogramBuilder!(size);
    }
    return const SizedBox.shrink();
  }

  Widget _chip(OrderItemData item) {
    return Container(
      width: 84,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF331A47).withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _thumb(item, 60),
          const SizedBox(height: 4),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF331A47)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final hasReference = step.referenceItems.isNotEmpty;

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
          if (hasReference) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEF9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Смотри внимательно',
                    style: TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: step.referenceItems.map(_chip).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Теперь повтори последовательность',
            style: TextStyle(
              color: Color(0xFF331A47),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_slots.length, (i) {
              final item = _slots[i];
              return DragTarget<OrderItemData>(
                onWillAcceptWithDetails: (details) => _slots[i] == null,
                onAcceptWithDetails: (details) => _placeInSlot(i, details.data),
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: item != null ? () => _removeFromSlot(i) : null,
                    child: Container(
                      width: 84,
                      height: 100,
                      decoration: BoxDecoration(
                        color: item != null
                            ? Colors.white
                            : const Color(0xFFFAF0EA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? const Color(0xFF7A6C99)
                              : const Color(0xFFE3DCEC),
                          width: 1.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: item != null
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _thumb(item, 56),
                                  Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 9, color: Color(0xFF331A47)),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: const Color(0xFF331A47).withOpacity(0.3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _pool
                .map((item) => Draggable<OrderItemData>(
                      data: item,
                      feedback: Opacity(opacity: 0.85, child: _chip(item)),
                      childWhenDragging: Opacity(opacity: 0.3, child: _chip(item)),
                      child: _chip(item),
                    ))
                .toList(),
          ),
          if (_wrong) ...[
            const SizedBox(height: 16),
            Text(
              'Попробуй ещё раз',
              style: TextStyle(
                color: const Color(0xFF331A47).withOpacity(0.55),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _reset,
              child: const Text('Сбросить'),
            ),
          ],
        ],
      ),
    );
  }
}
