// lib/parent/profile_form_screen.dart

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../survey/survey_screen.dart';
import '../widgets/primary_button.dart';
import 'pin_screens.dart';

const List<int> kProfileAges = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const Map<AppLanguage, String> kLanguageNames = {
  AppLanguage.ru: 'Русский',
  AppLanguage.kk: 'Қазақша',
  AppLanguage.en: 'English',
};

/// Создание или изменение профиля ребёнка.
/// [firstRun] — первый запуск: после сохранения задаётся PIN родителя.
/// [editing] — изменить существующий профиль; иначе создаётся новый.
class ProfileFormScreen extends StatefulWidget {
  final bool firstRun;
  final ChildProfile? editing;

  const ProfileFormScreen({super.key, this.firstRun = false, this.editing});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _nameController = TextEditingController();
  int? _age;
  AppLanguage? _language;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _nameController.text = editing.name;
      _age = editing.age;
      _language = editing.language;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _language ??= AppLocaleScope.of(context).language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectLanguage(AppLanguage language) {
    setState(() => _language = language);
    // При первом запуске сразу показываем приложение на выбранном языке.
    if (widget.firstRun) AppLocaleScope.of(context).setLanguage(language);
  }

  void _save() {
    final appState = AppStateScope.of(context);
    final editing = widget.editing;
    if (editing != null) {
      appState.updateProfile(
        editing.id,
        name: _nameController.text,
        age: _age!,
        language: _language!,
      );
      Navigator.of(context).pop();
      return;
    }
    appState.addProfile(
      name: _nameController.text,
      age: _age!,
      language: _language!,
    );
    if (!widget.firstRun) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SurveyScreen()),
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            appState.hasPin
                ? const SurveyScreen(firstRun: true)
                : const PinSetupScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final String title;
    if (widget.editing != null) {
      title = s.profileEditTitle;
    } else if (widget.firstRun) {
      title = s.profileTitle;
    } else {
      title = s.profileNewTitle;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF331A47),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.profileSubtitle,
                    style: TextStyle(
                      color: const Color(0xFF331A47).withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FieldLabel(s.profileNameLabel),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: s.profileNameHint,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(s.profileAgeLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final age in kProfileAges)
                        _ChoiceChip(
                          label: '$age',
                          selected: _age == age,
                          onTap: () => setState(() => _age = age),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(s.sectionLanguage),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final entry in kLanguageNames.entries)
                        _ChoiceChip(
                          label: entry.value,
                          selected: _language == entry.key,
                          onTap: () => _selectLanguage(entry.key),
                        ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: widget.firstRun ? s.continueButton : s.saveButton,
                    onTap: _age == null || _language == null ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF331A47),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF331A47) : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF331A47),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
