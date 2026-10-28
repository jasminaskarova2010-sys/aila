// lib/pecs/pictograms.dart
//
// Простые векторные пиктограммы (не эмодзи, не фото) для карточек PECS —
// нарисованы вручную через CustomPainter в едином плоском стиле, пока нет
// готовых иллюстраций. Поле image в PecsCardData позволит позже заменить их
// на настоящие assets без изменения структуры данных.

import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';

enum FaceMood { happy, good, sad, angry, scared, tired, sick, pain }

class FacePictogram extends StatelessWidget {
  final FaceMood mood;
  final double size;

  const FacePictogram({super.key, required this.mood, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FacePainter(mood),
    );
  }
}

class _FacePainter extends CustomPainter {
  final FaceMood mood;
  _FacePainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.82;

    final facePaint = Paint()..color = const Color(0xFFFFD98A);
    canvas.drawCircle(center, r, facePaint);

    final linePaint = Paint()
      ..color = const Color(0xFF7A5A2A)
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final eyeDy = -r * 0.18;
    final eyeDx = r * 0.34;
    final leftEye = Offset(center.dx - eyeDx, center.dy + eyeDy);
    final rightEye = Offset(center.dx + eyeDx, center.dy + eyeDy);
    final eyeR = size.width * 0.045;

    switch (mood) {
      case FaceMood.happy:
      case FaceMood.good:
        canvas.drawCircle(leftEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawCircle(rightEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.22),
          width: r * (mood == FaceMood.happy ? 1.0 : 0.7),
          height: r * (mood == FaceMood.happy ? 0.9 : 0.5),
        );
        canvas.drawArc(mouthRect, 0.15, 2.85, false, linePaint);
        break;

      case FaceMood.sad:
        canvas.drawCircle(leftEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawCircle(rightEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        final tearPaint = Paint()..color = const Color(0xFF7FB2E0);
        canvas.drawCircle(
          Offset(rightEye.dx + eyeR * 0.6, rightEye.dy + eyeR * 2.4),
          eyeR * 0.7,
          tearPaint,
        );
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.52),
          width: r * 0.9,
          height: r * 0.7,
        );
        canvas.drawArc(mouthRect, 3.5, 2.6, false, linePaint);
        break;

      case FaceMood.angry:
        canvas.drawCircle(leftEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawCircle(rightEye, eyeR, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawLine(
          Offset(leftEye.dx - eyeR * 1.6, leftEye.dy - eyeR * 2.2),
          Offset(leftEye.dx + eyeR * 1.2, leftEye.dy - eyeR * 0.8),
          linePaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx + eyeR * 1.6, rightEye.dy - eyeR * 2.2),
          Offset(rightEye.dx - eyeR * 1.2, rightEye.dy - eyeR * 0.8),
          linePaint,
        );
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.6),
          width: r * 0.8,
          height: r * 0.5,
        );
        canvas.drawArc(mouthRect, 3.6, 2.3, false, linePaint);
        break;

      case FaceMood.scared:
        canvas.drawCircle(leftEye, eyeR * 1.6, Paint()..color = Colors.white);
        canvas.drawCircle(rightEye, eyeR * 1.6, Paint()..color = Colors.white);
        canvas.drawCircle(leftEye, eyeR * 0.8, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawCircle(rightEye, eyeR * 0.8, Paint()..color = const Color(0xFF7A5A2A));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + r * 0.4),
            width: r * 0.4,
            height: r * 0.5,
          ),
          Paint()..color = const Color(0xFF7A5A2A),
        );
        break;

      case FaceMood.tired:
        canvas.drawLine(
          Offset(leftEye.dx - eyeR * 1.4, leftEye.dy),
          Offset(leftEye.dx + eyeR * 1.4, leftEye.dy),
          linePaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx - eyeR * 1.4, rightEye.dy),
          Offset(rightEye.dx + eyeR * 1.4, rightEye.dy),
          linePaint,
        );
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.45),
          width: r * 0.55,
          height: r * 0.3,
        );
        canvas.drawArc(mouthRect, 3.7, 1.9, false, linePaint);
        break;

      case FaceMood.sick:
        canvas.drawLine(
          Offset(leftEye.dx - eyeR * 1.2, leftEye.dy - eyeR),
          Offset(leftEye.dx + eyeR * 1.2, leftEye.dy + eyeR),
          linePaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx - eyeR * 1.2, rightEye.dy - eyeR),
          Offset(rightEye.dx + eyeR * 1.2, rightEye.dy + eyeR),
          linePaint,
        );
        final path = Path()
          ..moveTo(center.dx - r * 0.4, center.dy + r * 0.45)
          ..quadraticBezierTo(center.dx - r * 0.2, center.dy + r * 0.3,
              center.dx, center.dy + r * 0.45)
          ..quadraticBezierTo(center.dx + r * 0.2, center.dy + r * 0.6,
              center.dx + r * 0.4, center.dy + r * 0.45);
        canvas.drawPath(path, linePaint);
        break;

      case FaceMood.pain:
        canvas.drawLine(
          Offset(leftEye.dx - eyeR * 1.4, leftEye.dy + eyeR),
          Offset(leftEye.dx + eyeR * 1.4, leftEye.dy - eyeR),
          linePaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx - eyeR * 1.4, rightEye.dy - eyeR),
          Offset(rightEye.dx + eyeR * 1.4, rightEye.dy + eyeR),
          linePaint,
        );
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.4),
          width: r * 0.5,
          height: r * 0.6,
        );
        canvas.drawOval(mouthRect, Paint()..color = const Color(0xFF7A5A2A));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.mood != mood;
}

class ApplePictogram extends StatelessWidget {
  final double size;
  const ApplePictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _ApplePainter());
  }
}

class _ApplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bodyPaint = Paint()..color = const Color(0xFFE0524A);
    final path = Path()
      ..moveTo(w * 0.5, h(w, 0.28))
      ..cubicTo(w * 0.15, h(w, 0.2), w * 0.05, h(w, 0.55), w * 0.22, h(w, 0.78))
      ..cubicTo(w * 0.32, h(w, 0.92), w * 0.42, h(w, 0.92), w * 0.5, h(w, 0.84))
      ..cubicTo(w * 0.58, h(w, 0.92), w * 0.68, h(w, 0.92), w * 0.78, h(w, 0.78))
      ..cubicTo(w * 0.95, h(w, 0.55), w * 0.85, h(w, 0.2), w * 0.5, h(w, 0.28))
      ..close();
    canvas.drawPath(path, bodyPaint);

    final stemPaint = Paint()
      ..color = const Color(0xFF7A5A2A)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.5, h(w, 0.28)), Offset(w * 0.55, h(w, 0.12)), stemPaint);

    final leafPaint = Paint()..color = const Color(0xFF6EA34F);
    final leaf = Path()
      ..moveTo(w * 0.55, h(w, 0.16))
      ..quadraticBezierTo(w * 0.75, h(w, 0.1), w * 0.72, h(w, 0.26))
      ..quadraticBezierTo(w * 0.6, h(w, 0.26), w * 0.55, h(w, 0.16))
      ..close();
    canvas.drawPath(leaf, leafPaint);
  }

  double h(double w, double f) => w * f;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BananaPictogram extends StatelessWidget {
  final double size;
  const BananaPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BananaPainter());
  }
}

class _BananaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()..color = const Color(0xFFE7C443);
    final path = Path()
      ..moveTo(w * 0.28, h(w, 0.82))
      ..cubicTo(w * 0.1, h(w, 0.6), w * 0.15, h(w, 0.25), w * 0.42, h(w, 0.15))
      ..cubicTo(w * 0.5, h(w, 0.12), w * 0.58, h(w, 0.14), w * 0.62, h(w, 0.2))
      ..cubicTo(w * 0.45, h(w, 0.24), w * 0.32, h(w, 0.5), w * 0.44, h(w, 0.74))
      ..cubicTo(w * 0.55, h(w, 0.9), w * 0.72, h(w, 0.88), w * 0.82, h(w, 0.74))
      ..cubicTo(w * 0.8, h(w, 0.85), w * 0.68, h(w, 0.92), w * 0.55, h(w, 0.9))
      ..cubicTo(w * 0.42, h(w, 0.89), w * 0.32, h(w, 0.87), w * 0.28, h(w, 0.82))
      ..close();
    canvas.drawPath(path, paint);

    final tipPaint = Paint()..color = const Color(0xFF7A5A2A);
    canvas.drawCircle(Offset(w * 0.42, h(w, 0.16)), w * 0.03, tipPaint);
  }

  double h(double w, double f) => w * f;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SunPictogram extends StatelessWidget {
  final double size;
  const SunPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _SunPainter());
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.26;
    final rayPaint = Paint()
      ..color = const Color(0xFFE0A93E)
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final start = Offset(
        center.dx + (r * 1.3) * cos(angle),
        center.dy + (r * 1.3) * sin(angle),
      );
      final end = Offset(
        center.dx + (r * 1.9) * cos(angle),
        center.dy + (r * 1.9) * sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF4C04E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SnowflakePictogram extends StatelessWidget {
  final double size;
  const SnowflakePictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _SnowflakePainter());
  }
}

class _SnowflakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.34;
    final paint = Paint()
      ..color = const Color(0xFF6EA9D6)
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final angle = (i / 3) * pi;
      final dx = r * cos(angle);
      final dy = r * sin(angle);
      canvas.drawLine(
        Offset(center.dx - dx, center.dy - dy),
        Offset(center.dx + dx, center.dy + dy),
        paint,
      );
    }
    canvas.drawCircle(center, size.width * 0.06, Paint()..color = const Color(0xFF6EA9D6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoudSoundPictogram extends StatelessWidget {
  final double size;
  const LoudSoundPictogram({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.hearing, size: size * 0.62, color: const Color(0xFF7A6C99)),
        Positioned(
          right: size * 0.02,
          top: size * 0.08,
          child: CustomPaint(
            size: Size(size * 0.4, size * 0.4),
            painter: _SoundWavesPainter(),
          ),
        ),
      ],
    );
  }
}

class _SoundWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0A93E)
      ..strokeWidth = size.width * 0.09
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final origin = Offset(0, size.height / 2);
    for (var i = 1; i <= 3; i++) {
      final r = size.width * 0.28 * i;
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: r),
        -0.7,
        1.4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
