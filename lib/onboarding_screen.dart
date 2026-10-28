// lib/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'l10n/strings.dart';
import 'parent/profile_form_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
              painter: ConstellationPainter(),
            ),
          ),
          const Positioned(
            top: 90,
            left: 16,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.cloud, size: 30, color: Color(0xFFB8A9DE)),
            ),
          ),
          const Positioned(
            bottom: 220,
            right: 20,
            child: Opacity(
              opacity: 0.28,
              child: Icon(Icons.cloud, size: 34, color: Color(0xFFE7B7C9)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: s.onboardingPrefix,
                          style: const TextStyle(color: Color(0xFF331A47)),
                        ),
                        const TextSpan(
                          text: 'Aila',
                          style: TextStyle(
                            color: Color(0xFFB89849),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFB89849),
                            decorationThickness: 2.5,
                          ),
                        ),
                        TextSpan(
                          text: s.onboardingSuffix,
                          style: const TextStyle(color: Color(0xFF331A47)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  Image.asset(
                    'assets/star_mascot.png',
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 3),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProfileFormScreen(firstRun: true),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF331A47).withOpacity(0.15),
                              offset: const Offset(0, 8),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Text(
                          s.onboardingGetStarted,
                          style: const TextStyle(
                            color: Color(0xFF331A47),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(color: const Color(0xFFE2CB87)),
                      const SizedBox(width: 8),
                      _Dot(color: const Color(0xFF331A47)),
                      const SizedBox(width: 8),
                      _Dot(color: const Color(0xFFE2CB87)),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ConstellationPainter extends CustomPainter {
  final List<List<Offset>> _clusters;
  final List<Offset> _sparkles;

  ConstellationPainter()
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
            const Offset(0.03, 0.32),
            const Offset(0.1, 0.29),
            const Offset(0.13, 0.35),
            const Offset(0.06, 0.38),
          ],
          [
            const Offset(0.04, 0.86),
            const Offset(0.12, 0.83),
            const Offset(0.15, 0.9),
            const Offset(0.08, 0.93),
          ],
          [
            const Offset(0.82, 0.87),
            const Offset(0.92, 0.84),
            const Offset(0.95, 0.91),
            const Offset(0.86, 0.94),
          ],
        ],
        _sparkles = [
          const Offset(0.2, 0.01),
          const Offset(0.72, 0.04),
          const Offset(0.02, 0.18),
          const Offset(0.94, 0.22),
          const Offset(0.06, 0.55),
          const Offset(0.9, 0.5),
          const Offset(0.2, 0.75),
          const Offset(0.78, 0.78),
          const Offset(0.1, 0.97),
          const Offset(0.88, 0.98),
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
        center.dx + rInner, center.dy - rInner, center.dx + r, center.dy);
    path.quadraticBezierTo(
        center.dx + rInner, center.dy + rInner, center.dx, center.dy + r);
    path.quadraticBezierTo(
        center.dx - rInner, center.dy + rInner, center.dx - r, center.dy);
    path.quadraticBezierTo(
        center.dx - rInner, center.dy - rInner, center.dx, center.dy - r);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}