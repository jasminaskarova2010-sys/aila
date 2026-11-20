// lib/support_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/strings.dart';
import 'support_contacts.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _copyToClipboard(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final contacts = <Widget>[
      if (kSupportPhone1.isNotEmpty)
        _ContactRow(
          icon: Icons.phone,
          label: s.phone1Label,
          value: kSupportPhone1,
          onTap: () =>
              _copyToClipboard(context, kSupportPhone1, s.numberCopied),
        ),
      if (kSupportPhone2.isNotEmpty)
        _ContactRow(
          icon: Icons.phone,
          label: s.phone2Label,
          value: kSupportPhone2,
          onTap: () =>
              _copyToClipboard(context, kSupportPhone2, s.numberCopied),
        ),
      if (kSupportEmail.isNotEmpty)
        _ContactRow(
          icon: Icons.email,
          label: s.emailLabel,
          value: kSupportEmail,
          onTap: () => _copyToClipboard(context, kSupportEmail, s.emailCopied),
        ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF331A47),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                s.supportTitle,
                style: const TextStyle(
                  color: Color(0xFF331A47),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.supportSubtitle,
                style: const TextStyle(color: Color(0xFF9B8FAE), fontSize: 15),
              ),
              const SizedBox(height: 24),
              if (contacts.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Column(
                    children: [
                      for (final (i, row) in contacts.indexed) ...[
                        if (i > 0)
                          const Divider(height: 1, color: Color(0xFFEDE6DC)),
                        row,
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EEF9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8677A5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.supportTip,
                        style: const TextStyle(
                          color: Color(0xFF331A47),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF7A6C99),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: const Color(0xFF331A47).withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF331A47),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
