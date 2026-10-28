// lib/info_screen.dart

import 'package:flutter/material.dart';
import 'l10n/strings.dart';
import 'state/app_state.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.star,
                        iconColor: const Color(0xFFE0A93E),
                        value: '${appState.stars}',
                      ),
                    ],
                  ),
                  _CircleIconButton(
                    icon: Icons.settings,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF331A47),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_outline,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.infoTitle,
                                  style: const TextStyle(
                                    color: Color(0xFF331A47),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.infoSubtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF9B8FAE),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFEDE6DC)),
                      const SizedBox(height: 16),
                      _InfoSection(
                        title: s.infoHowItWorksTitle,
                        body: s.infoHowItWorksBody,
                      ),
                      const SizedBox(height: 20),
                      _InfoSection(
                        title: s.infoAiStarTitle,
                        body: s.infoAiStarBody,
                      ),
                      const SizedBox(height: 20),
                      _InfoSection(
                        title: s.infoRewardsTitle,
                        body: s.infoRewardsBody,
                      ),
                      const SizedBox(height: 20),
                      _InfoSection(
                        title: s.infoSpecialistsTitle,
                        body: s.infoSpecialistsBody,
                      ),
                      const SizedBox(height: 20),
                      _InfoNoticeCard(
                        icon: Icons.error_outline,
                        iconBackground: const Color(0xFFF8E9C8),
                        iconColor: const Color(0xFFC98A1F),
                        background: const Color(0xFFFCF1DC),
                        title: s.infoDisclaimerTitle,
                        body: s.infoDisclaimerBody,
                      ),
                      const SizedBox(height: 12),
                      _InfoNoticeCard(
                        icon: Icons.favorite,
                        iconBackground: const Color(0xFFE3DCF2),
                        iconColor: const Color(0xFF8677A5),
                        background: const Color(0xFFF2EEF9),
                        title: s.infoImportantTitle,
                        body: s.infoImportantBody,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String body;

  const _InfoSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF331A47),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            color: const Color(0xFF331A47).withOpacity(0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InfoNoticeCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color background;
  final String title;
  final String body;

  const _InfoNoticeCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF331A47),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: const Color(0xFF331A47).withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
