// lib/parent/print_cards.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../board/pictogram_repository.dart';
import '../l10n/app_language.dart';
import '../l10n/board_labels.dart';
import '../l10n/strings.dart';

/// 12 базовых карточек для занятий с напечатанным набором.
const List<String> kPrintCardIds = [
  'water', 'eat', 'toilet', 'help',
  'mom', 'dad', 'ball', 'book',
  'more', 'done', 'yes', 'no',
];

/// Лист A4: 3 × 4 крупные карточки с рамкой, по которой удобно резать. Шрифт
/// лежит в приложении, поэтому PDF собирается без интернета (П8).
Future<Uint8List> buildBaseCardsPdf(AppLanguage language) async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

  final images = <pw.Widget>[];
  for (final id in kPrintCardIds) {
    final path = PictogramRepository.assetPath(id);
    if (path.endsWith('.svg')) {
      images.add(pw.SvgImage(svg: await rootBundle.loadString(path)));
    } else {
      final bytes = await rootBundle.load(path);
      images.add(pw.Image(pw.MemoryImage(bytes.buffer.asUint8List())));
    }
  }

  final pdf = pw.Document(title: 'Aila', theme: pw.ThemeData.withFont(base: regular, bold: bold));
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(1.2 * PdfPageFormat.cm),
      build: (context) => pw.Column(
        children: [
          pw.Expanded(
            child: pw.GridView(
              crossAxisCount: 3,
              childAspectRatio: 1.17,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (var i = 0; i < kPrintCardIds.length; i++)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey500, width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Expanded(child: pw.Center(child: images[i])),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          boardWordLabel(kPrintCardIds[i], language),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Mulberry Symbols © Steve Lee, CC BY-SA 4.0',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );
  return pdf.save();
}

/// Открывает окно печати, где набор можно напечатать или сохранить как PDF.
Future<void> printBaseCards(BuildContext context) async {
  final s = S.of(context);
  final language = s.lang;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await Printing.layoutPdf(
      name: s.printCards,
      onLayout: (_) => buildBaseCardsPdf(language),
    );
  } catch (e) {
    debugPrint('Не удалось открыть печать: $e');
    messenger.showSnackBar(SnackBar(content: Text(s.printFailed)));
  }
}
