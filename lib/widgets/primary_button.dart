// lib/widgets/primary_button.dart

import 'package:flutter/material.dart';

/// Крупная скруглённая кнопка в стиле приложения. Если [onTap] == null,
/// кнопка приглушена и не нажимается.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background = filled
        ? (enabled ? const Color(0xFF331A47) : const Color(0xFFB3ACC0))
        : Colors.white;
    final foreground = filled ? Colors.white : const Color(0xFF331A47);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF331A47,
                ).withOpacity(enabled && filled ? 0.25 : 0.08),
                offset: const Offset(0, 6),
                blurRadius: 14,
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
