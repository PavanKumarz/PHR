import 'dart:convert';
import 'package:phr/data/models/note_model.dart';

String buildNotePreview(NoteModel note) {
  if (note.viewMode != 'table') {
    return note.text.trim();
  }

  try {
    final decoded = jsonDecode(note.tableData);
    final List cols = decoded['columns'] ?? [];
    final List rows = decoded['rows'] ?? [];

    if (cols.isEmpty) return "Table (empty)";

    final header = cols.join(" | ");

    if (rows.isEmpty) return "Table: $header";

    final cells = rows.first['cells'] as Map<String, dynamic>;
    final values = cols.map((c) => cells[c] ?? '').join(" | ");

    return "Table: $header\n• $values";
  } catch (_) {
    return "Table data";
  }
}
