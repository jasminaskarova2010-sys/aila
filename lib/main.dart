// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_language.dart';
import 'onboarding_screen.dart';
import 'state/app_state.dart';

void main() async {
  // Обязательная привязка Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase с обработкой возможных ошибок
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Ошибка инициализации Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleController _localeController = LocaleController();
  final AppState _appState = AppState();

  @override
  void dispose() {
    _localeController.dispose();
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: AppStateScope(
        state: _appState,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: OnboardingScreen(),
        ),
      ),
    );
  }
}