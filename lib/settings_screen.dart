// lib/settings_screen.dart

import 'package:flutter/material.dart';
import 'board/parent_media.dart';
import 'info_screen.dart';
import 'l10n/app_language.dart';
import 'l10n/strings.dart';
import 'onboarding_screen.dart';
import 'parent/board_settings_screen.dart';
import 'parent/pin_screens.dart';
import 'parent/print_cards.dart';
import 'parent/today_screen.dart';
import 'parent/profile_form_screen.dart';
import 'state/app_state.dart';
import 'survey/survey_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _deleteProfile(BuildContext context, ChildProfile profile) async {
    final s = S.of(context);
    final name = profile.name.isEmpty ? s.unnamedChild : profile.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFAF0EA),
        title: Text(s.deleteProfileTitle(name)),
        content: Text(s.deleteProfileBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final appState = AppStateScope.of(context);
    final removed = appState.deleteProfile(profile.id);
    if (removed != null) {
      ParentMedia.deleteFiles([
        for (final card in removed.parentCards) ...[
          card.imageFile,
          card.audioFile,
        ],
      ]);
    }
    if (!appState.hasProfile) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final activeProfile = appState.activeProfile;
    final language = activeProfile?.language ?? AppLocaleScope.of(context).language;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.info_outline,
                    onTap: () {
                      _push(context, const InfoScreen());
                    },
                  ),
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.star,
                        iconColor: const Color(0xFFE0A93E),
                        value: '${appState.stars}',
                      ),
                    ],
                  ),
                  _CircleIconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF331A47).withOpacity(0.06),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF331A47),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.settingsTitle,
                            style: const TextStyle(
                              color: Color(0xFF331A47),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.settingsSubtitle,
                            style: TextStyle(
                              color: const Color(0xFF331A47).withOpacity(0.55),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.cloud,
                        color: Color(0xFFB8A9DE), size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (activeProfile != null) ...[
                _SectionTitle(s.tipTitle),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EEF9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.phaseTip(activeProfile.boardPhase),
                    style: const TextStyle(
                      color: Color(0xFF331A47),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _NavigationRow(
                      icon: Icons.insights_outlined,
                      label: s.todayTitle,
                      onTap: () => _push(context, const TodayScreen()),
                    ),
                    const _RowDivider(),
                    _NavigationRow(
                      icon: Icons.checklist_rounded,
                      label: appState.isSurveyDue()
                          ? s.surveyRepeat
                          : s.surveyOpen,
                      onTap: () => _push(context, const SurveyScreen()),
                    ),
                    const _RowDivider(),
                    _NavigationRow(
                      icon: Icons.print_outlined,
                      label: s.printCards,
                      onTap: () => printBaseCards(context),
                    ),
                    const _RowDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.self_improvement,
                            color: Color(0xFF331A47),
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              s.breakAfterLabel,
                              style: const TextStyle(
                                color: Color(0xFF331A47),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          for (final count in const [3, 4, 5])
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: ChoiceChip(
                                label: Text('$count'),
                                selected: activeProfile.breakAfterTasks == count,
                                onSelected: (_) =>
                                    appState.setBreakAfterTasks(count),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
              _SectionTitle(s.sectionGeneral),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _ToggleRow(
                    icon: Icons.volume_up,
                    label: s.sound,
                    value: appState.soundEnabled,
                    onChanged: appState.setSoundEnabled,
                  ),
                  const _RowDivider(),
                  _ToggleRow(
                    icon: Icons.music_note,
                    label: s.music,
                    value: appState.musicEnabled,
                    onChanged: appState.setMusicEnabled,
                  ),
                  const _RowDivider(),
                  _ToggleRow(
                    icon: Icons.vibration,
                    label: s.vibration,
                    value: appState.vibrationEnabled,
                    onChanged: appState.setVibrationEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(s.sectionProfiles),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  for (final profile in appState.profiles) ...[
                    _ProfileRow(
                      name: profile.name.isEmpty ? s.unnamedChild : profile.name,
                      details: s.profileAge(profile.age),
                      selected: profile.id == activeProfile?.id,
                      onTap: () => appState.switchProfile(profile.id),
                    ),
                    const _RowDivider(),
                  ],
                  if (activeProfile != null) ...[
                    _NavigationRow(
                      icon: Icons.edit_outlined,
                      label: s.editProfile,
                      onTap: () => _push(
                        context,
                        ProfileFormScreen(editing: activeProfile),
                      ),
                    ),
                    const _RowDivider(),
                  ],
                  _NavigationRow(
                    icon: Icons.person_add_alt,
                    label: s.addProfile,
                    onTap: () => _push(context, const ProfileFormScreen()),
                  ),
                  const _RowDivider(),
                  if (activeProfile != null) ...[
                    _NavigationRow(
                      icon: Icons.delete_outline,
                      label: s.deleteProfile,
                      onTap: () => _deleteProfile(context, activeProfile),
                    ),
                    const _RowDivider(),
                  ],
                  _NavigationRow(
                    icon: Icons.grid_view_rounded,
                    label: s.boardTitle,
                    onTap: () => _push(context, const BoardSettingsScreen()),
                  ),
                  const _RowDivider(),
                  _NavigationRow(
                    icon: Icons.lock_outline,
                    label: s.changePin,
                    onTap: () =>
                        _push(context, const PinSetupScreen(isReset: true)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(s.sectionLanguage),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _LanguageRow(
                    label: 'Русский',
                    selected: language == AppLanguage.ru,
                    onTap: () => appState.setLanguage(AppLanguage.ru),
                  ),
                  const _RowDivider(),
                  _LanguageRow(
                    label: 'English',
                    selected: language == AppLanguage.en,
                    onTap: () => appState.setLanguage(AppLanguage.en),
                  ),
                  const _RowDivider(),
                  _LanguageRow(
                    label: 'Қазақша',
                    selected: language == AppLanguage.kk,
                    onTap: () => appState.setLanguage(AppLanguage.kk),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(s.sectionOther),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _NavigationRow(
                    icon: Icons.help_outline,
                    label: s.supportRow,
                    onTap: () {
                      _push(context, const SupportScreen());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF331A47).withOpacity(0.06),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF331A47),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF331A47),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF331A47).withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: const Color(0xFF331A47).withOpacity(0.08),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF331A47), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF331A47),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF7A6C99),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFF7A6C99)
                    : const Color(0xFFB3ACC0),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF331A47),
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String name;
  final String details;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.name,
    required this.details,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color:
                    selected ? const Color(0xFF7A6C99) : const Color(0xFFB3ACC0),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF331A47),
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                details,
                style: TextStyle(
                  color: const Color(0xFF331A47).withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF331A47);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
