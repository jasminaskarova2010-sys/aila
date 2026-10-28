// lib/games/speak_game_screen.dart

import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_shell.dart';

class SpeakGameScreen extends StatefulWidget {
  final GameStep step;
  final int total;
  final VoidCallback onComplete;

  const SpeakGameScreen({
    super.key,
    required this.step,
    required this.total,
    required this.onComplete,
  });

  @override
  State<SpeakGameScreen> createState() => _SpeakGameScreenState();
}

class _SpeakGameScreenState extends State<SpeakGameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _recording = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleMicTap() {
    if (_recording || _solved) return;
    setState(() => _recording = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _solved = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
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
          GamePromptCard(
            imagePath: step.promptImagePath,
            pictogramBuilder: step.promptPictogramBuilder,
            placeholderNote: step.promptPlaceholderNote,
            speech: step.speakPhrase,
            onPlaySpeech: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Озвучка появится позже')),
              );
            },
          ),
          const Text(
            'Теперь твоя очередь!',
            style: TextStyle(
              color: Color(0xFF331A47),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _recording ? 'Слушаю...' : 'Нажми на микрофон и скажи фразу.',
            style: TextStyle(color: const Color(0xFF331A47).withOpacity(0.6)),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _handleMicTap,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = _recording
                    ? 1.0 + (_pulseController.value * 0.12)
                    : 1.0;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _solved
                      ? const Color(0xFF6EA34F)
                      : const Color(0xFF331A47),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF331A47).withOpacity(0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  _solved ? Icons.check : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
