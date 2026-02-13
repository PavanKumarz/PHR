import 'dart:convert';

class NoteModel {
  final int? id;
  final String title;
  final String text; // Quill JSON
  final String tableData; // JSON array
  final String viewMode; // "text" | "table"
  final List<String> files;
  final List<String> audio;
  final String date;

  NoteModel({
    this.id,
    required this.title,
    required this.text,
    required this.tableData,
    required this.viewMode,
    required this.files,
    required this.audio,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'text': text,
    'tableData': tableData,
    'viewMode': viewMode,
    'files': jsonEncode(files),
    'audio': jsonEncode(audio),
    'date': date,
  };

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      tableData: map['tableData'] ?? '[]',
      viewMode: map['viewMode'] ?? 'text',
      files: List<String>.from(jsonDecode(map['files'] ?? '[]')),
      audio: List<String>.from(jsonDecode(map['audio'] ?? '[]')),
      date: map['date'] ?? '',
    );
  }
}
