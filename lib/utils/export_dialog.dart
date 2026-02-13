import 'package:flutter/material.dart';
import 'package:phr/data/services/export_service.dart';

Future<PdfExportType?> showPdfExportDialog(BuildContext context) {
  return showDialog<PdfExportType>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text("Export as PDF"),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, PdfExportType.noteOnly),
          child: const Text(" Note only"),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, PdfExportType.tableOnly),
          child: const Text(" Table only"),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, PdfExportType.noteAndTable),
          child: const Text("Note + Table"),
        ),
      ],
    ),
  );
}
