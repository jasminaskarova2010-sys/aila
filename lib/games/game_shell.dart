// lib/games/game_shell.dart

import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../parent/pin_screens.dart';
import '../settings_screen.dart';
import '../state/app_state.dart';
import 'game_audio.dart';
import '../widgets/aila_face.dart';
import '../widgets/aila_hello.dart';
import 'missing_photo_placeholder.dart';

class GameShell extends StatelessWidget {
  final int index;
  final int total;
  final String title;
  final String subtitle;
  final Widget content;
  final bool solved;
  final String feedbackTitle;
  final String feedbackBody;
  final VoidCallback onContinue;

  const GameShell({
    super.key,
    required this.index,
    required this.total,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.solved,
    required this.feedbackTitle,
    required this.feedbackBody,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
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
          const Positioned(
            top: 90,
            right: 24,
            child: Opacity(
              opacity: 0.5,
              child: Text('🚀', style: TextStyle(fontSize: 26)),
            ),
          ),
          const Positioned(
            top: 140,
            left: 20,
            child: Opacity(
              opacity: 0.4,
              child: Text('☁️', style: TextStyle(fontSize: 26)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              '$index / $total',
                              style: TextStyle(
                                color: const Color(0xFF331A47).withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: index / total,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE3DCEC),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF331A47),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CircleIconButton(
                        icon: Icons.settings,
                        onTap: () {
                          openParentArea(
                            context,
                            (context) => const SettingsScreen(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF331A47),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF331A47).withOpacity(0.6),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        content,
                      ],
                    ),
                  ),
                ),
                // Закреплено внизу: на телефоне под карточками «Продолжить»
                // оказывалось бы за краем экрана.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: solved
                      ? Padding(
                          key: const ValueKey('solved'),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: _FeedbackBar(
                            index: index,
                            title: feedbackTitle,
                            body: feedbackBody,
                            onContinue: onContinue,
                          ),
                        )
                      : const SizedBox(key: ValueKey('unsolved')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Айла хвалит по-разному: радуется, подмигивает, обнимает сердечко, машет.
/// Выбор зависит от номера задания, а не от случая: так предсказуемее (П4).
class _AilaPraise extends StatelessWidget {
  final int index;

  const _AilaPraise({required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index % 6) {
      case 0:
        return const AilaFace(AilaMood.excited, size: 80);
      case 1:
        return const AilaHello(size: 80);
      case 2:
        return const AilaFace(AilaMood.joy, size: 80);
      case 3:
        return const AilaFace(AilaMood.content, size: 80);
      case 4:
        return Image.asset(
          'assets/aila_wink.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        );
      default:
        return const AilaFace(AilaMood.hug, size: 80);
    }
  }
}

class _FeedbackBar extends StatefulWidget {
  /// Номер задания на экране: от него зависит, как Айла хвалит.
  final int index;
  final String title;
  final String body;
  final VoidCallback onContinue;

  const _FeedbackBar({
    required this.index,
    required this.title,
    required this.body,
    required this.onContinue,
  });

  @override
  State<_FeedbackBar> createState() => _FeedbackBarState();
}

class _FeedbackBarState extends State<_FeedbackBar> {
  bool _celebrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_celebrated) return;
    _celebrated = true;
    final appState = AppStateScope.of(context);
    GameAudio.instance.success(
      sound: appState.soundEnabled,
      vibration: appState.vibrationEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AilaPraise(index: widget.index),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F1DE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF4C7A3A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: const TextStyle(
                        color: Color(0xFF331A47),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: widget.onContinue,
            child: Container(
              width: double.infinity,
              height: 56,
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
                  Text(
                    S.of(context).continueButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
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

class GamePromptCard extends StatelessWidget {
  final String? imagePath;
  final Widget Function(double size)? pictogramBuilder;
  final String? placeholderNote;
  final String? caption;
  final String? speech;
  final VoidCallback? onPlaySpeech;

  const GamePromptCard({
    super.key,
    this.imagePath,
    this.pictogramBuilder,
    this.placeholderNote,
    this.caption,
    this.speech,
    this.onPlaySpeech,
  });

  @override
  Widget build(BuildContext context) {
    final hasVisual =
        imagePath != null ||
        pictogramBuilder != null ||
        placeholderNote != null;
    if (!hasVisual && speech == null) return const SizedBox.shrink();
    return Column(
      children: [
        if (hasVisual)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: imagePath != null ? 220 : 140,
              alignment: Alignment.center,
              color: const Color(0xFFF2EEF9),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : (pictogramBuilder != null
                        ? pictogramBuilder!(84)
                        : MissingPhotoPlaceholder(
                            note: placeholderNote!,
                            size: 120,
                          )),
            ),
          ),
        if (caption != null) ...[
          const SizedBox(height: 12),
          Text(
            caption!,
            style: const TextStyle(
              color: Color(0xFF331A47),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (speech != null) ...[
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onPlaySpeech,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF331A47).withOpacity(0.06),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, color: Color(0xFF331A47)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        speech!,
                        style: const TextStyle(
                          color: Color(0xFF331A47),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
