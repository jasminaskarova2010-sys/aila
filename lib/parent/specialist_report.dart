// lib/parent/specialist_report.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../journal/journal.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../survey/survey_data.dart';

/// Документ для специалиста: фаза, ответы опроса, фразы за 4 недели.
/// Имени ребёнка в нём нет: родитель вписывает его сам, если хочет (П7).
Future<Uint8List> buildSpecialistReport(
  S s,
  ChildProfile profile,
  List<JournalEntry> entries,
  DateTime now,
) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
  );
  const ink = PdfColor.fromInt(0xFF331A47);
  const muted = PdfColor.fromInt(0xFF6B5D82);
  const line = PdfColor.fromInt(0xFFE3DAEE);

  String date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: ink,
      ),
    ),
  );

  pw.Widget row(String a, String b) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 190,
          child: pw.Text(a, style: const pw.TextStyle(color: muted)),
        ),
        pw.Expanded(child: pw.Text(b)),
      ],
    ),
  );

  // Четыре недели, от старой к текущей.
  final today = DateTime(now.year, now.month, now.day);
  final weeks = <List<String>>[];
  for (var w = 3; w >= 0; w--) {
    final end = today.subtract(Duration(days: 7 * w - 1));
    final start = end.subtract(const Duration(days: 7));
    final inWeek = entries.where(
      (e) =>
          !e.isPhaseChange && !e.time.isBefore(start) && e.time.isBefore(end),
    );
    weeks.add([
      '${date(start)} – ${date(end.subtract(const Duration(days: 1)))}',
      '${inWeek.length}',
      '${inWeek.where((e) => !e.isAnswer).length}',
      '${inWeek.where((e) => e.cards >= 2).length}',
      '${inWeek.where((e) => e.isAnswer).length}',
    ]);
  }
  final top = topPhrases(
    entries,
    today.subtract(const Duration(days: 27)),
    limit: 5,
  );
  final phaseChanges = entries.where((e) => e.isPhaseChange).toList();

  final doc = pw.Document(
    title: s.reportTitle,
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Text(
          s.reportTitle,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: ink,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          s.reportCreated(date(now)),
          style: const pw.TextStyle(color: muted),
        ),
        heading(s.reportChild),
        row(s.reportName, '______________________'),
        row(s.profileAgeLabel, '${profile.age}'),
        row(s.reportLanguage, s.languageName(profile.language)),
        row(s.reportPhase, s.boardPhaseName(profile.boardPhase)),
        row('', s.phaseLearning(profile.boardPhase)),
        heading(s.surveyTitle),
        if (profile.lastSurveyAt == null)
          pw.Text(s.reportNoSurvey, style: const pw.TextStyle(color: muted))
        else ...[
          pw.Text(
            s.reportSurveyDate(date(profile.lastSurveyAt!)),
            style: const pw.TextStyle(color: muted),
          ),
          pw.SizedBox(height: 4),
          for (var i = 0; i < profile.surveyAnswers.length; i++)
            row(
              '${i + 1}. ${s.surveyQuestion(i)}',
              s.surveyAnswer(profile.surveyAnswers[i]),
            ),
          if (profile.surveyAnswers.length < kSurveyQuestionCount)
            pw.Text(
              s.reportSurveyShort,
              style: const pw.TextStyle(color: muted),
            ),
        ],
        heading(s.reportWeeks),
        pw.TableHelper.fromTextArray(
          headers: [
            s.reportWeek,
            s.reportAll,
            s.todaySpontaneous,
            s.todayMultiCard,
            s.reportAnswers,
          ],
          data: weeks,
          border: pw.TableBorder.all(color: line),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: ink,
            fontSize: 10,
          ),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        heading(s.reportTopPhrases),
        if (top.isEmpty)
          pw.Text(s.todayEmpty, style: const pw.TextStyle(color: muted))
        else
          for (final p in top) row('${p.value} ×', p.key),
        if (phaseChanges.isNotEmpty) ...[
          heading(s.reportPhaseChanges),
          for (final e in phaseChanges)
            row(date(e.time), s.boardPhaseName(e.phase)),
        ],
        pw.SizedBox(height: 18),
        pw.Text(
          s.reportDisclaimer,
          style: const pw.TextStyle(color: muted, fontSize: 9),
        ),
      ],
    ),
  );
  return doc.save();
}

/// Собирает документ и открывает системное меню «Поделиться».
Future<void> shareSpecialistReport(BuildContext context) async {
  final s = S.of(context);
  final appState = AppStateScope.of(context);
  final profile = appState.activeProfile;
  if (profile == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject() as RenderBox?;
  try {
    final now = DateTime.now();
    final bytes = await buildSpecialistReport(
      s,
      profile,
      appState.journalEntries,
      now,
    );
    final name =
        'aila_specialist_${now.toIso8601String().substring(0, 10)}.pdf';
    final XFile shared;
    if (kIsWeb) {
      // В браузере нет папок: файл отдаётся из памяти.
      shared = XFile.fromData(bytes, name: name, mimeType: 'application/pdf');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(bytes);
      shared = XFile(file.path, mimeType: 'application/pdf');
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [shared],
        subject: s.reportTitle,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  } catch (e) {
    debugPrint('Не удалось собрать документ: $e');
    messenger.showSnackBar(SnackBar(content: Text(s.todayShareFailed)));
  }
}
