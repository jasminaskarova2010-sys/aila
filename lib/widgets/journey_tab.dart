// lib/widgets/journey_tab.dart

import 'package:flutter/material.dart';
import '../games/games_flow_screen.dart';
import '../games/journey_titles_sheet.dart';
import '../l10n/strings.dart';
import '../settings_screen.dart';
import '../state/app_state.dart';

class JourneyTab extends StatefulWidget {
  const JourneyTab({super.key});

  @override
  State<JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<JourneyTab> {
  final ScrollController _scrollController = ScrollController();

  static const List<Offset> _nodePositions = [
    Offset(0.50, 0.03),
    Offset(0.32, 0.16),
    Offset(0.26, 0.29),
    Offset(0.34, 0.42),
    Offset(0.50, 0.53),
    Offset(0.32, 0.66),
    Offset(0.26, 0.79),
    Offset(0.34, 0.92),
  ];

  static const double _pathHeight = 1000;

  static IconData _iconFor(int i) {
    switch (i % 4) {
      case 1:
        return Icons.auto_stories;
      case 3:
        return Icons.card_giftcard;
      default:
        return Icons.star;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _openGame(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamesFlowScreen(startIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
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
          Positioned.fill(
            child: CustomPaint(
              painter: JourneyConstellationPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.star,
                            iconColor: const Color(0xFFE0A93E),
                            value: '${appState.stars}',
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.diamond,
                            iconColor: const Color(0xFF8677A5),
                            value: '5653',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          _CircleIconButton(
                            icon: Icons.settings,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showJourneyTitlesSheet(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF331A47).withOpacity(0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.journeySection,
                                style: TextStyle(
                                  color:
                                      const Color(0xFF331A47).withOpacity(0.7),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.reorder,
                                color: const Color(0xFF331A47).withOpacity(0.6)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 24, bottom: 40),
                        child: SizedBox(
                          height: _pathHeight,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size =
                                  Size(constraints.maxWidth, _pathHeight);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _JourneyPathPainter(
                                          nodes: _nodePositions),
                                    ),
                                  ),
                                  for (var i = 0;
                                      i < _nodePositions.length;
                                      i++)
                                    _buildNode(context, size, i),
                                  Positioned(
                                    right: 20,
                                    top: _nodePositions[1].dy * _pathHeight - 30,
                                    child: const _AilaReadingBadge(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: _CircleIconButton(
                          icon: Icons.arrow_upward,
                          onTap: _scrollToTop,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context, Size size, int index) {
    final fraction = _nodePositions[index];
    final center = Offset(fraction.dx * size.width, fraction.dy * size.height);

    return Positioned(
      left: center.dx - 30,
      top: center.dy - 30,
      child: _JourneyNode(
        icon: _iconFor(index),
        current: index == 0,
        onTap: () => _openGame(context, index),
      ),
    );
  }
}

class _AilaReadingBadge extends StatelessWidget {
  const _AilaReadingBadge();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/star_mascot.png', width: 90, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.star, color: Color(0xFFE3DCEC), size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyNode extends StatelessWidget {
  final IconData icon;
  final bool current;
  final VoidCallback onTap;

  const _JourneyNode({
    required this.icon,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(34),
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: current
                ? Border.all(color: const Color(0xFFE0A93E), width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: (current ? const Color(0xFFE0A93E) : const Color(0xFF331A47))
                    .withOpacity(current ? 0.45 : 0.08),
                offset: const Offset(0, 4),
                blurRadius: current ? 20 : 10,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: current ? const Color(0xFFE0A93E) : const Color(0xFF7A6C99),
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _JourneyPathPainter extends CustomPainter {
  final List<Offset> nodes;

  _JourneyPathPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    final points = nodes
        .map((n) => Offset(n.dx * size.width, n.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final shadowPaint = Paint()
      ..color = const Color(0xFF331A47).withOpacity(0.05)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    final ribbonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, ribbonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class JourneyConstellationPainter extends CustomPainter {
  final List<Offset> _sparkles;

  JourneyConstellationPainter()
      : _sparkles = [
          const Offset(0.1, 0.06),
          const Offset(0.85, 0.1),
          const Offset(0.9, 0.35),
          const Offset(0.08, 0.45),
          const Offset(0.88, 0.6),
          const Offset(0.12, 0.7),
          const Offset(0.8, 0.85),
        ];

  @override
  void paint(Canvas canvas, Size size) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFE0A93E).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    for (final s in _sparkles) {
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        2.5,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
