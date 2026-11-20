// lib/games/game_pictograms.dart
//
// Простые векторные иллюстрации предметов (не emoji) для игр — используются,
// когда реального фото предмета нет, но абстрактная иллюстрация не мешает
// однозначному пониманию задания (в отличие от людей/эмоций/соц. ситуаций,
// для которых нужно настоящее фото — там используется MissingPhotoPlaceholder).

import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';

double _h(double w, double f) => w * f;

class BallPictogram extends StatelessWidget {
  final double size;
  const BallPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BallPainter());
  }
}

class _BallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
    final linePaint = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..strokeWidth = size.width * 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r, linePaint);
    final pentagon = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      final p = Offset(
        center.dx + r * 0.42 * cos(angle),
        center.dy + r * 0.42 * sin(angle),
      );
      if (i == 0) {
        pentagon.moveTo(p.dx, p.dy);
      } else {
        pentagon.lineTo(p.dx, p.dy);
      }
    }
    pentagon.close();
    canvas.drawPath(pentagon, Paint()..color = const Color(0xFF2E2E2E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TeddyBearPictogram extends StatelessWidget {
  final double size;
  const TeddyBearPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _TeddyPainter());
  }
}

class _TeddyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final furPaint = Paint()..color = const Color(0xFFC08A57);
    canvas.drawCircle(Offset(w * 0.28, _h(w, 0.22)), w * 0.13, furPaint);
    canvas.drawCircle(Offset(w * 0.72, _h(w, 0.22)), w * 0.13, furPaint);
    canvas.drawCircle(Offset(w * 0.5, _h(w, 0.36)), w * 0.28, furPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, _h(w, 0.72)),
        width: w * 0.62,
        height: w * 0.5,
      ),
      furPaint,
    );
    final earInner = Paint()..color = const Color(0xFFE7C9A3);
    canvas.drawCircle(Offset(w * 0.28, _h(w, 0.22)), w * 0.06, earInner);
    canvas.drawCircle(Offset(w * 0.72, _h(w, 0.22)), w * 0.06, earInner);
    final snoutPaint = Paint()..color = const Color(0xFFE7C9A3);
    canvas.drawCircle(Offset(w * 0.5, _h(w, 0.4)), w * 0.1, snoutPaint);
    final facePaint = Paint()..color = const Color(0xFF5A3E28);
    canvas.drawCircle(Offset(w * 0.42, _h(w, 0.34)), w * 0.02, facePaint);
    canvas.drawCircle(Offset(w * 0.58, _h(w, 0.34)), w * 0.02, facePaint);
    canvas.drawCircle(Offset(w * 0.5, _h(w, 0.41)), w * 0.018, facePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GrapesPictogram extends StatelessWidget {
  final double size;
  const GrapesPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GrapesPainter());
  }
}

class _GrapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final grapePaint = Paint()..color = const Color(0xFF7B5FA8);
    final positions = [
      Offset(w * 0.5, _h(w, 0.28)),
      Offset(w * 0.36, _h(w, 0.42)),
      Offset(w * 0.64, _h(w, 0.42)),
      Offset(w * 0.28, _h(w, 0.58)),
      Offset(w * 0.5, _h(w, 0.58)),
      Offset(w * 0.72, _h(w, 0.58)),
      Offset(w * 0.4, _h(w, 0.74)),
      Offset(w * 0.6, _h(w, 0.74)),
    ];
    for (final p in positions) {
      canvas.drawCircle(p, w * 0.12, grapePaint);
    }
    final stemPaint = Paint()
      ..color = const Color(0xFF6EA34F)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.5, _h(w, 0.12)),
      Offset(w * 0.5, _h(w, 0.26)),
      stemPaint,
    );
    final leafPaint = Paint()..color = const Color(0xFF6EA34F);
    final leaf = Path()
      ..moveTo(w * 0.5, _h(w, 0.16))
      ..quadraticBezierTo(w * 0.68, _h(w, 0.08), w * 0.62, _h(w, 0.24))
      ..quadraticBezierTo(w * 0.55, _h(w, 0.2), w * 0.5, _h(w, 0.16))
      ..close();
    canvas.drawPath(leaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CarPictogram extends StatelessWidget {
  final double size;
  const CarPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _CarPainter());
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bodyPaint = Paint()..color = const Color(0xFFD9524A);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, _h(w, 0.42), w * 0.84, _h(w, 0.28)),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(body, bodyPaint);
    final roof = Path()
      ..moveTo(w * 0.24, _h(w, 0.42))
      ..lineTo(w * 0.34, _h(w, 0.24))
      ..lineTo(w * 0.66, _h(w, 0.24))
      ..lineTo(w * 0.76, _h(w, 0.42))
      ..close();
    canvas.drawPath(roof, bodyPaint);
    final windowPaint = Paint()..color = const Color(0xFFDCEEF5);
    final window = Path()
      ..moveTo(w * 0.32, _h(w, 0.4))
      ..lineTo(w * 0.38, _h(w, 0.28))
      ..lineTo(w * 0.62, _h(w, 0.28))
      ..lineTo(w * 0.68, _h(w, 0.4))
      ..close();
    canvas.drawPath(window, windowPaint);
    final wheelPaint = Paint()..color = const Color(0xFF2E2E2E);
    canvas.drawCircle(Offset(w * 0.28, _h(w, 0.74)), w * 0.09, wheelPaint);
    canvas.drawCircle(Offset(w * 0.72, _h(w, 0.74)), w * 0.09, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BookPictogram extends StatelessWidget {
  final double size;
  const BookPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BookPainter());
  }
}

class _BookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final coverPaint = Paint()..color = const Color(0xFF4A7FBF);
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, _h(w, 0.16), w * 0.68, _h(w, 0.68)),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(cover, coverPaint);
    final pagePaint = Paint()..color = Colors.white;
    final page = Rect.fromLTWH(w * 0.22, _h(w, 0.22), w * 0.56, _h(w, 0.56));
    canvas.drawRect(page, pagePaint);
    final linePaint = Paint()
      ..color = const Color(0xFFB3ACC0)
      ..strokeWidth = w * 0.025;
    for (var i = 0; i < 3; i++) {
      final y = _h(w, 0.34) + i * w * 0.12;
      canvas.drawLine(Offset(w * 0.3, y), Offset(w * 0.7, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlanePictogram extends StatelessWidget {
  final double size;
  const PlanePictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _PlanePainter());
  }
}

class _PlanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()..color = const Color(0xFF6E93C4);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, _h(w, 0.14), w * 0.12, _h(w, 0.62)),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(body, paint);
    final wing = Path()
      ..moveTo(w * 0.5, _h(w, 0.42))
      ..lineTo(w * 0.14, _h(w, 0.6))
      ..lineTo(w * 0.5, _h(w, 0.54))
      ..close();
    canvas.drawPath(wing, paint);
    final wing2 = Path()
      ..moveTo(w * 0.5, _h(w, 0.42))
      ..lineTo(w * 0.86, _h(w, 0.6))
      ..lineTo(w * 0.5, _h(w, 0.54))
      ..close();
    canvas.drawPath(wing2, paint);
    final tail = Path()
      ..moveTo(w * 0.44, _h(w, 0.18))
      ..lineTo(w * 0.32, _h(w, 0.1))
      ..lineTo(w * 0.5, _h(w, 0.22))
      ..close();
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BalloonPictogram extends StatelessWidget {
  final double size;
  const BalloonPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BalloonPainter());
  }
}

class _BalloonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()..color = const Color(0xFFE0A93E);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, _h(w, 0.36)),
        width: w * 0.56,
        height: w * 0.62,
      ),
      paint,
    );
    final stringPaint = Paint()
      ..color = const Color(0xFF7A6C99)
      ..strokeWidth = w * 0.025
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.5, _h(w, 0.66))
      ..quadraticBezierTo(w * 0.42, _h(w, 0.78), w * 0.5, _h(w, 0.88));
    canvas.drawPath(path, stringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BirdPictogram extends StatelessWidget {
  final double size;
  const BirdPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BirdPainter());
  }
}

class _BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bodyPaint = Paint()..color = const Color(0xFF6E93C4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.48, _h(w, 0.52)),
        width: w * 0.56,
        height: w * 0.4,
      ),
      bodyPaint,
    );
    canvas.drawCircle(Offset(w * 0.74, _h(w, 0.36)), w * 0.16, bodyPaint);
    final beakPaint = Paint()..color = const Color(0xFFE0A93E);
    final beak = Path()
      ..moveTo(w * 0.88, _h(w, 0.36))
      ..lineTo(w * 0.98, _h(w, 0.4))
      ..lineTo(w * 0.88, _h(w, 0.42))
      ..close();
    canvas.drawPath(beak, beakPaint);
    final wingPaint = Paint()..color = const Color(0xFF4A7FBF);
    final wing = Path()
      ..moveTo(w * 0.42, _h(w, 0.5))
      ..quadraticBezierTo(w * 0.2, _h(w, 0.5), w * 0.24, _h(w, 0.68))
      ..quadraticBezierTo(w * 0.36, _h(w, 0.62), w * 0.44, _h(w, 0.58))
      ..close();
    canvas.drawPath(wing, wingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
