// lib/parent/today_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../board/board_theme.dart';
import '../journal/journal.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';
import 'specialist_report.dart';

/// Экран «Сегодня»: сколько ребёнок говорил с помощью доски. Числа считаются по
/// журналу на устройстве, отчётом родитель делится сам.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  Future<void> _share(BuildContext context, List<JournalEntry> entries) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    try {
      final csv = journalToCsv(
        entries,
        headers: s.csvHeaders,
        phaseChangeLabel: s.csvPhaseChange,
        phraseLabel: s.csvPhrase,
        answerLabel: s.csvAnswer,
        spontaneousLabel: s.csvSpontaneous,
      );
      final now = DateTime.now();
      final date = now.toIso8601String().substring(0, 10);
      final XFile shared;
      if (kIsWeb) {
        // В браузере нет папок: файл отдаётся из памяти.
        shared = XFile.fromData(
          utf8.encode(csv),
          name: 'aila_report_$date.csv',
          mimeType: 'text/csv',
        );
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/aila_report_$date.csv');
        await file.writeAsString(csv);
        shared = XFile(file.path, mimeType: 'text/csv');
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [shared],
          subject: s.todayShare,
          // На iPad меню «Поделиться» привязывается к месту на экране.
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      debugPrint('Не удалось поделиться отчётом: $e');
      messenger.showSnackBar(SnackBar(content: Text(s.todayShareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appState = AppStateScope.of(context);
    final entries = appState.journalEntries;
    final now = DateTime.now();
    final today = countToday(entries, now);
    final week = countWeek(entries, now);
    return Scaffold(
      backgroundColor: BoardTheme.background,
      appBar: AppBar(
        backgroundColor: BoardTheme.background,
        elevation: 0,
        foregroundColor: BoardTheme.ink,
        title: Text(
          s.todayTitle,
          style: const TextStyle(
            color: BoardTheme.ink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _Period(title: s.todayDay, counts: today),
          const SizedBox(height: 16),
          _Period(title: s.todayWeek, counts: week),
          const SizedBox(height: 16),
          _WeekChart(counts: phrasesPerDay(entries, now), now: now),
          const SizedBox(height: 16),
          _TopPhrases(
            phrases: topPhrases(
              entries,
              DateTime(now.year, now.month, now.day - 6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.todayExplanation,
            style: const TextStyle(
              color: BoardTheme.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: s.reportButton,
            onTap: () => shareSpecialistReport(context),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: s.todayShare,
            filled: false,
            onTap: entries.isEmpty ? null : () => _share(context, entries),
          ),
          if (entries.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              s.todayEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BoardTheme.muted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// Столбики: сколько фраз в каждый из 7 дней, сегодня тёмным.
class _WeekChart extends StatelessWidget {
  final List<int> counts;
  final DateTime now;

  const _WeekChart({required this.counts, required this.now});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final top = counts.fold<int>(0, (a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.todayChartTitle,
            style: const TextStyle(
              color: BoardTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < counts.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${counts[i]}',
                            style: const TextStyle(
                              color: BoardTheme.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: top == 0 ? 4 : 4 + 80 * counts[i] / top,
                            decoration: BoxDecoration(
                              color: i == counts.length - 1
                                  ? BoardTheme.ink
                                  : const Color(0xFFCFC3EA),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.weekdayShort(
                              now
                                  .subtract(
                                    Duration(days: counts.length - 1 - i),
                                  )
                                  .weekday,
                            ),
                            style: const TextStyle(
                              color: BoardTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

class _TopPhrases extends StatelessWidget {
  final List<MapEntry<String, int>> phrases;

  const _TopPhrases({required this.phrases});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (phrases.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.todayTopPhrases,
            style: const TextStyle(
              color: BoardTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in phrases)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${p.key} · ${p.value}',
                    style: const TextStyle(
                      color: Color(0xFF6A3A00),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Period extends StatelessWidget {
  final String title;
  final JournalCounts counts;

  const _Period({required this.title, required this.counts});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BoardTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Number(
                  key: ValueKey('$title spontaneous'),
                  value: counts.spontaneous,
                  label: s.todaySpontaneous,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Number(
                  key: ValueKey('$title multi'),
                  value: counts.multiCard,
                  label: s.todayMultiCard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Number extends StatelessWidget {
  final int value;
  final String label;

  const _Number({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: BoardTheme.ink,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: BoardTheme.muted, fontSize: 13),
        ),
      ],
    );
  }
}
