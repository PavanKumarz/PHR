import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:phr/data/models/note_model.dart';

enum PdfExportType { noteOnly, tableOnly, noteAndTable }

class ExportService {
  static Future<void> savePDF(NoteModel note, PdfExportType type) async {
    final bytes = await _buildPdf(note, type);

    await FilePicker.platform.saveFile(
      dialogTitle: "Save PDF",
      fileName:
          "${note.title.isEmpty ? 'record' : note.title}_${DateTime.now().millisecondsSinceEpoch}.pdf",
      type: FileType.custom,
      allowedExtensions: ["pdf"],
      bytes: bytes,
    );
  }

  static Future<void> sharePDF(NoteModel note, PdfExportType type) async {
    final bytes = await _buildPdf(note, type);

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${note.title}.pdf");

    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<Uint8List> _buildPdf(NoteModel note, PdfExportType type) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Text(
              note.title.isEmpty ? "Untitled Record" : note.title,
              style: pw.TextStyle(
                font: font,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 6));
          widgets.add(
            pw.Text(
              "Date: ${note.date}",
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          );

          widgets.add(pw.Divider());

          if (type == PdfExportType.noteOnly ||
              type == PdfExportType.noteAndTable) {
            final text = _plainTextFromDelta(note.text);
            if (text.trim().isNotEmpty) {
              widgets.add(
                pw.Text(text, style: pw.TextStyle(font: font, fontSize: 14)),
              );
              widgets.add(pw.SizedBox(height: 20));
            }
          }

          if (type == PdfExportType.tableOnly ||
              type == PdfExportType.noteAndTable) {
            widgets.addAll(_buildTable(note, font));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildTable(NoteModel note, pw.Font font) {
    try {
      final decoded = jsonDecode(note.tableData);
      final List columns = decoded['columns'] ?? [];
      final List rows = decoded['rows'] ?? [];

      if (columns.isEmpty) return [];

      final List<List<String>> data = [];

      data.add(columns.map((c) => c.toString()).toList());

      for (final r in rows) {
        final cells = Map<String, dynamic>.from(r['cells'] ?? {});
        data.add(columns.map((c) => cells[c]?.toString() ?? '').toList());
      }

      return [
        pw.Text(
          "Table",
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: data.first,
          data: data.skip(1).toList(),
          headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ];
    } catch (_) {
      return [];
    }
  }

  static String _plainTextFromDelta(String deltaJson) {
    try {
      final decoded = jsonDecode(deltaJson) as List;
      return decoded.map((e) => e['insert']).whereType<String>().join();
    } catch (_) {
      return deltaJson;
    }
  }
}
