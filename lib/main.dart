// lib/main.dart

import 'package:flutter/material.dart';
import 'board/parent_media.dart';
import 'l10n/app_language.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'parent/pin_screens.dart';
import 'state/app_state.dart';

void main() async {
  // Обязательная привязка Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем сохранённые профили, звёзды и настройки с устройства
  final appState = await AppState.load();
  await ParentMedia.init();

  runApp(MyApp(appState: appState));
}

class MyApp extends StatefulWidget {
  final AppState appState;

  const MyApp({super.key, required this.appState});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleController _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _syncLanguage();
    widget.appState.addListener(_syncLanguage);
  }

  // Язык интерфейса всегда совпадает с языком текущего профиля ребёнка.
  void _syncLanguage() {
    final profile = widget.appState.activeProfile;
    if (profile != null) _localeController.setLanguage(profile.language);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_syncLanguage);
    _localeController.dispose();
    widget.appState.dispose();
    super.dispose();
  }

  Widget _initialScreen() {
    final appState = widget.appState;
    if (!appState.hasProfile) return const OnboardingScreen();
    if (!appState.hasPin) return const PinSetupScreen();
    return const MainScreen();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: AppStateScope(
        state: widget.appState,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _initialScreen(),
        ),
      ),
    );
  }
}
