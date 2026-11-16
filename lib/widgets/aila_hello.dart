// lib/widgets/aila_hello.dart

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Айла машет и подмигивает: анимация из видео с убранным фоном
/// (`assets/aila_hello.png`, APNG; собирается `tool/cutout_video.swift`).
///
/// Анимация проигрывается один раз, когда экран открылся, и ещё раз по нажатию
/// на Айлу. Постоянного движения нет (П12). Если на устройстве выключены
/// анимации, Айла стоит на месте.
class AilaHello extends StatefulWidget {
  final double size;

  const AilaHello({super.key, required this.size});

  @override
  State<AilaHello> createState() => _AilaHelloState();
}

class _AilaHelloState extends State<AilaHello> {
  static const _asset = 'assets/aila_hello.png';

  ui.Codec? _codec;
  ui.Image? _frame;
  Timer? _timer;
  bool _playing = false;
  int _framesLeft = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load(_asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      if (!mounted) {
        codec.dispose();
        return;
      }
      _codec = codec;
      _play();
    } catch (_) {
      // Остаётся обычная картинка Айлы.
    }
  }

  void _play() {
    final codec = _codec;
    if (codec == null || _playing) return;
    _playing = true;
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _framesLeft = still ? 1 : codec.frameCount;
    _showNext();
  }

  Future<void> _showNext() async {
    final codec = _codec;
    if (codec == null) return;
    final info = await codec.getNextFrame();
    if (!mounted) {
      info.image.dispose();
      return;
    }
    final old = _frame;
    setState(() => _frame = info.image);
    old?.dispose();
    _framesLeft--;
    if (_framesLeft <= 0) {
      _playing = false;
      return;
    }
    _timer = Timer(info.duration, _showNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frame?.dispose();
    _codec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    return GestureDetector(
      onTap: _play,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: frame == null
            ? Image.asset('assets/star_mascot.png', fit: BoxFit.contain)
            : RawImage(image: frame, fit: BoxFit.contain),
      ),
    );
  }
}
