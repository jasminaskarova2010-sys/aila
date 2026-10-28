// lib/login_screen.dart — обновлённая логика Google Sign-In

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'create_account_screen.dart';
import 'l10n/strings.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TapGestureRecognizer _signUpRecognizer;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showEmailFields = false;

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateAccountScreen(),
          ),
        );
      };
  }

  @override
  void dispose() {
    _signUpRecognizer.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToMainScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

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
              painter: LoginConstellationPainter(),
            ),
          ),
          const Positioned(
            top: 340,
            left: 18,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.cloud, size: 30, color: Color(0xFFB8A9DE)),
            ),
          ),
          const Positioned(
            bottom: 240,
            right: 20,
            child: Opacity(
              opacity: 0.28,
              child: Icon(Icons.cloud, size: 34, color: Color(0xFFE7B7C9)),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            s.loginTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF331A47),
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _LoginAuthButton(
                            leading: const Icon(
                              Icons.apple,
                              size: 26,
                              color: Colors.black,
                            ),
                            text: s.signInWithApple,
                            onTap: _goToMainScreen,
                          ),
                          const SizedBox(height: 16),
                          _LoginAuthButton(
                            leading: const _LoginGoogleGPlaceholder(),
                            text: s.signInWithGoogle,
                            onTap: _goToMainScreen,
                          ),
                          const SizedBox(height: 16),
                          _LoginAuthButton(
                            leading: null,
                            text: s.continueWithEmail,
                            onTap: () {
                              setState(() {
                                _showEmailFields = !_showEmailFields;
                              });
                            },
                          ),
                          if (_showEmailFields) ...[
                            const SizedBox(height: 20),
                            _LoginRoundedTextField(
                              controller: _emailController,
                              hintText: s.emailHint,
                              obscureText: false,
                            ),
                            const SizedBox(height: 16),
                            _LoginRoundedTextField(
                              controller: _passwordController,
                              hintText: s.passwordHint,
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            _LoginAuthButton(
                              leading: null,
                              text: s.logInButton,
                              backgroundColor: const Color(0xFF331A47),
                              textColor: Colors.white,
                              onTap: _goToMainScreen,
                            ),
                          ],
                          const SizedBox(height: 48),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF331A47),
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(text: s.dontHaveAccount),
                                TextSpan(
                                  text: s.signUp,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  recognizer: _signUpRecognizer,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LoginDot(color: const Color(0xFFE2CB87)),
                              const SizedBox(width: 8),
                              _LoginDot(color: const Color(0xFF331A47)),
                              const SizedBox(width: 8),
                              _LoginDot(color: const Color(0xFFE2CB87)),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginAuthButton extends StatelessWidget {
  final Widget? leading;
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  const _LoginAuthButton({
    required this.leading,
    required this.text,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1A1A1A),
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF331A47).withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (leading != null)
                Positioned(
                  left: 0,
                  child: leading!,
                ),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginGoogleGPlaceholder extends StatelessWidget {
  const _LoginGoogleGPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}

class _LoginRoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const _LoginRoundedTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: Color(0xFF331A47),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9B8FAE),
          fontSize: 16,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF331A47),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF331A47),
            width: 1.8,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF331A47),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _LoginDot extends StatelessWidget {
  final Color color;

  const _LoginDot({required this.color});

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

class LoginConstellationPainter extends CustomPainter {
  final List<List<Offset>> _clusters;
  final List<Offset> _sparkles;

  LoginConstellationPainter()
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
