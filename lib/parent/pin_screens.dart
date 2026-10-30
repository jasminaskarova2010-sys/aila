// lib/parent/pin_screens.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../survey/survey_screen.dart';

const int kPinLength = 4;

/// Открывает экран для взрослых (настройки, родительский раздел, ссылки)
/// только после ввода PIN родителя.
Future<void> openParentArea(BuildContext context, WidgetBuilder builder) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PinEntryScreen(onUnlocked: builder)),
  );
}

/// Задать PIN. При первом запуске после этого открывается опрос родителя;
/// при сбросе или смене PIN экран закрывается с результатом `true`.
class PinSetupScreen extends StatefulWidget {
  final bool isReset;

  const PinSetupScreen({super.key, this.isReset = false});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _firstPin;
  bool _mismatch = false;
  int _padGeneration = 0;

  void _handlePin(String pin) {
    if (_firstPin == null) {
      setState(() {
        _firstPin = pin;
        _mismatch = false;
        _padGeneration++;
      });
      return;
    }
    if (pin != _firstPin) {
      setState(() {
        _firstPin = null;
        _mismatch = true;
        _padGeneration++;
      });
      return;
    }
    AppStateScope.of(context).setPin(pin);
    if (widget.isReset) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SurveyScreen(firstRun: true)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final String message;
    if (_mismatch) {
      message = s.pinMismatch;
    } else if (_firstPin == null) {
      message = s.pinSetupBody;
    } else {
      message = s.pinConfirmBody;
    }
    return _PinScaffold(
      showBack: widget.isReset,
      title: s.pinSetupTitle,
      message: message,
      child: PinPad(key: ValueKey(_padGeneration), onCompleted: _handlePin),
    );
  }
}

/// Ввод PIN перед экраном для взрослых. При верном PIN заменяется
/// экраном [onUnlocked].
class PinEntryScreen extends StatefulWidget {
  final WidgetBuilder onUnlocked;

  const PinEntryScreen({super.key, required this.onUnlocked});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  bool _wrong = false;
  int _padGeneration = 0;

  void _unlock() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: widget.onUnlocked));
  }

  void _handlePin(String pin) {
    if (AppStateScope.of(context).checkPin(pin)) {
      _unlock();
      return;
    }
    setState(() {
      _wrong = true;
      _padGeneration++;
    });
  }

  Future<void> _handleForgot() async {
    final solved = await showDialog<bool>(
      context: context,
      builder: (_) => const _ResetChallengeDialog(),
    );
    if (solved != true || !mounted) return;
    final pinSet = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PinSetupScreen(isReset: true)),
    );
    if (pinSet == true && mounted) _unlock();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _PinScaffold(
      showBack: true,
      title: s.pinEntryTitle,
      message: _wrong ? s.pinWrong : s.pinEntryBody,
      footer: TextButton(
        onPressed: _handleForgot,
        child: Text(
          s.pinForgot,
          style: const TextStyle(
            color: Color(0xFF7A6C99),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: PinPad(key: ValueKey(_padGeneration), onCompleted: _handlePin),
    );
  }
}

/// Простой пример на умножение: защита от ребёнка, а не от взрослого.
class _ResetChallengeDialog extends StatefulWidget {
  const _ResetChallengeDialog();

  @override
  State<_ResetChallengeDialog> createState() => _ResetChallengeDialogState();
}

class _ResetChallengeDialogState extends State<_ResetChallengeDialog> {
  final _random = Random();
  final _controller = TextEditingController();
  late int _a;
  late int _b;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _newExample();
  }

  void _newExample() {
    _a = 12 + _random.nextInt(28);
    _b = 3 + _random.nextInt(7);
    _controller.clear();
  }

  void _check() {
    if (int.tryParse(_controller.text.trim()) == _a * _b) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _wrong = true;
      _newExample();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFFFAF0EA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        s.pinResetTitle,
        style: const TextStyle(
          color: Color(0xFF331A47),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_wrong) ...[
            Text(
              s.pinResetWrong,
              style: TextStyle(color: const Color(0xFF331A47).withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            s.pinResetQuestion(_a, _b),
            style: const TextStyle(
              color: Color(0xFF331A47),
              fontSize: 17,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              hintText: s.answerHint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancelButton),
        ),
        TextButton(
          onPressed: _check,
          child: Text(
            s.checkButton,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _PinScaffold extends StatelessWidget {
  final bool showBack;
  final String title;
  final String message;
  final Widget child;
  final Widget? footer;

  const _PinScaffold({
    required this.showBack,
    required this.title,
    required this.message,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF331A47),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF7A6C99),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 66,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF331A47).withOpacity(0.65),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  child,
                  if (footer != null) ...[const SizedBox(height: 12), footer!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Четыре точки и цифровая клавиатура. На компьютере можно вводить цифры
/// и с обычной клавиатуры.
class PinPad extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  const PinPad({super.key, required this.onCompleted});

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _entered = '';

  void _addDigit(String digit) {
    if (_entered.length >= kPinLength) return;
    setState(() => _entered += digit);
    if (_entered.length == kPinLength) {
      final pin = _entered;
      // Короткая пауза, чтобы последняя точка успела закраситься.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) widget.onCompleted(pin);
      });
    }
  }

  void _removeDigit() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _removeDigit();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char != null && RegExp(r'^[0-9]$').hasMatch(char)) {
      _addDigit(char);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < kPinLength; i++)
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _entered.length
                        ? const Color(0xFF331A47)
                        : Colors.white,
                    border: Border.all(color: const Color(0xFFB3ACC0)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '<'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final key in row)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _PadKey(
                        label: key,
                        onTap: key.isEmpty
                            ? null
                            : (key == '<'
                                  ? _removeDigit
                                  : () => _addDigit(key)),
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

class _PadKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox(width: 72, height: 72);
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: label == '<'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFF331A47),
                    size: 24,
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
