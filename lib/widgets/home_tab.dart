// lib/widgets/home_tab.dart

import 'package:flutter/material.dart';
import '../games/game_models.dart';
import '../games/games_flow_screen.dart';
import '../games/journey_titles_sheet.dart';
import '../l10n/strings.dart';
import '../board/board_screen.dart';
import '../parent/pin_screens.dart';
import '../settings_screen.dart';
import '../state/app_state.dart';
import 'aila_hello.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _getUserDisplayName(S s, AppState appState) {
    final name = appState.activeProfile?.name ?? '';
    return name.isEmpty ? s.defaultUserName : name;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final userName = _getUserDisplayName(s, appState);
    final steps = gameStepsFor(context);
    final completedCount = steps
        .where((step) => appState.isGameCompleted(step.id))
        .length;
    final totalGames = steps.length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFDF3E4), Color(0xFFFCE9D2)],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: HomeConstellationPainter()),
          ),
          const Positioned(
            top: 120,
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.cloud, size: 30, color: Color(0xFFB8A9DE)),
            ),
          ),
          const Positioned(
            top: 260,
            right: 20,
            child: Opacity(
              opacity: 0.28,
              child: Icon(Icons.cloud, size: 34, color: Color(0xFFB8A9DE)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Шапка не прокручивается: «Настройки» всегда под рукой.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.person,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.profileSnackbar)),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          openParentArea(
                            context,
                            (context) => const SettingsScreen(),
                          );
                        },
                        child: Column(
                          children: [
                            const _CircleIconButton(
                              icon: Icons.settings,
                              onTap: null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.settingsTitle,
                              style: TextStyle(
                                color: const Color(0xFF331A47).withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          s.greeting(userName),
                          style: const TextStyle(
                            color: Color(0xFF331A47),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.readyForToday,
                          style: TextStyle(
                            color: const Color(0xFF331A47).withOpacity(0.55),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Айла машет рядом с облачком, поменьше прежней картинки: на телефоне доска
                        // и игры должны помещаться на первом экране без прокрутки.
                        Row(
                          children: [
                            const AilaHello(size: 120),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF331A47,
                                      ).withOpacity(0.08),
                                      offset: const Offset(0, 6),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  s.startJourneyCard,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF331A47),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _PecsCard(
                          title: s.boardTitle,
                          subtitle: s.pecsSubtitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BoardScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _DarkActionButton(
                          text: s.startJourneyButton,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const GamesFlowScreen(startIndex: 0),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => showJourneyTitlesSheet(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF331A47,
                                    ).withOpacity(0.08),
                                    offset: const Offset(0, 6),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF0D5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Color(0xFFE0A93E),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.journeyOfDay,
                                          style: const TextStyle(
                                            color: Color(0xFF331A47),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          s.activitiesCount(
                                            completedCount,
                                            totalGames,
                                          ),
                                          style: TextStyle(
                                            color: const Color(
                                              0xFF331A47,
                                            ).withOpacity(0.5),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _ProgressBadge(
                                    completed: completedCount,
                                    total: totalGames,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
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
          child: Icon(icon, color: const Color(0xFF331A47), size: 22),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBadge({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final done = total > 0 && completed >= total;
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            strokeWidth: 3,
            backgroundColor: const Color(0xFFE3DCEC),
            valueColor: AlwaysStoppedAnimation(
              done ? const Color(0xFF6EA34F) : const Color(0xFFE0A93E),
            ),
          ),
          if (done) const Icon(Icons.check, color: Color(0xFF6EA34F), size: 16),
        ],
      ),
    );
  }
}

class _DarkActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DarkActionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF331A47),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.3),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PecsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PecsCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.08),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFE0A93E),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF331A47),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF331A47).withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF331A47),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeConstellationPainter extends CustomPainter {
  final List<List<Offset>> _clusters;
  final List<Offset> _sparkles;

  HomeConstellationPainter()
    : _clusters = [
        [
          const Offset(0.05, 0.02),
          const Offset(0.13, 0.005),
          const Offset(0.16, 0.05),
          const Offset(0.07, 0.07),
        ],
        [
          const Offset(0.84, 0.02),
          const Offset(0.93, 0.05),
          const Offset(0.87, 0.09),
        ],
        [
          const Offset(0.9, 0.24),
          const Offset(0.97, 0.28),
          const Offset(0.92, 0.32),
        ],
        [
          const Offset(0.03, 0.6),
          const Offset(0.1, 0.57),
          const Offset(0.13, 0.63),
          const Offset(0.06, 0.66),
        ],
        [
          const Offset(0.82, 0.68),
          const Offset(0.92, 0.65),
          const Offset(0.95, 0.72),
          const Offset(0.86, 0.75),
        ],
      ],
      _sparkles = [
        const Offset(0.2, 0.01),
        const Offset(0.72, 0.04),
        const Offset(0.02, 0.18),
        const Offset(0.94, 0.22),
        const Offset(0.06, 0.5),
        const Offset(0.9, 0.45),
        const Offset(0.2, 0.72),
        const Offset(0.78, 0.7),
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFE0A93E).withOpacity(0.22)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFE0A93E).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final cluster in _clusters) {
      final points = cluster
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();

      for (var i = 0; i < points.length; i++) {
        final next = points[(i + 1) % points.length];
        canvas.drawLine(points[i], next, linePaint);
      }

      for (final p in points) {
        canvas.drawCircle(p, 2.0, dotPaint);
      }
    }

    final sparklePaint = Paint()
      ..color = const Color(0xFFE0A93E).withOpacity(0.28)
      ..style = PaintingStyle.fill;

    for (final s in _sparkles) {
      _drawSparkle(
        canvas,
        Offset(s.dx * size.width, s.dy * size.height),
        6,
        sparklePaint,
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    final rInner = r * 0.28;

    path.moveTo(center.dx, center.dy - r);
    path.quadraticBezierTo(
      center.dx + rInner,
      center.dy - rInner,
      center.dx + r,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx + rInner,
      center.dy + rInner,
      center.dx,
      center.dy + r,
    );
    path.quadraticBezierTo(
      center.dx - rInner,
      center.dy + rInner,
      center.dx - r,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx - rInner,
      center.dy - rInner,
      center.dx,
      center.dy - r,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
