import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phr/data/datasources/database_helper.dart';

class ExportBackupPage extends StatefulWidget {
  const ExportBackupPage({super.key});

  @override
  State<ExportBackupPage> createState() => _ExportBackupPageState();
}

class _ExportBackupPageState extends State<ExportBackupPage> {
  bool exporting = false;
  String message = "";

  Future<void> exportBackup() async {
    setState(() {
      exporting = true;
      message = "";
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(p.join(tempDir.path, "phr_backup"));

      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);

      final db = await DatabaseHelper.instance.database;
      await File(db.path).copy(p.join(backupDir.path, "notes.db"));

      final notes = await DatabaseHelper.instance.getNotes();

      final notesText = StringBuffer();
      notesText.writeln("PHR NOTES BACKUP");
      notesText.writeln("Generated: ${DateTime.now()}");
      notesText.writeln("=" * 40);
      notesText.writeln();

      for (int i = 0; i < notes.length; i++) {
        final note = notes[i];

        notesText.writeln("Note ${i + 1}");
        notesText.writeln(
          "Title : ${note.title.isEmpty ? '(No Title)' : note.title}",
        );
        notesText.writeln("Date  : ${note.date}");
        notesText.writeln("Mode  : ${note.viewMode}");
        notesText.writeln("\nCONTENT:");
        notesText.writeln(note.text);
        notesText.writeln("\n${"-" * 40}\n");
      }

      await File(
        p.join(backupDir.path, "notes_readable.txt"),
      ).writeAsString(notesText.toString());

      final csv = StringBuffer();
      csv.writeln("Title,Date,Row");

      for (final note in notes) {
        if (note.viewMode == "table") {
          final rows = note.text.split('\n');
          for (final row in rows) {
            csv.writeln(
              '"${note.title.replaceAll('"', '""')}","${note.date}","${row.replaceAll('"', '""')}"',
            );
          }
        }
      }

      await File(
        p.join(backupDir.path, "tables.csv"),
      ).writeAsString(csv.toString());

      final filesDir = Directory(p.join(backupDir.path, "files"));
      final audioDir = Directory(p.join(backupDir.path, "audio"));
      await filesDir.create();
      await audioDir.create();

      int fileIndex = 0;
      int audioIndex = 0;

      for (final note in notes) {
        for (final filePath in note.files) {
          final file = File(filePath);
          if (await file.exists()) {
            await file.copy(
              p.join(
                filesDir.path,
                "file_${fileIndex++}_${p.basename(filePath)}",
              ),
            );
          }
        }

        for (final audioPath in note.audio) {
          final audio = File(audioPath);
          if (await audio.exists()) {
            await audio.copy(
              p.join(
                audioDir.path,
                "audio_${audioIndex++}_${p.basename(audioPath)}",
              ),
            );
          }
        }
      }

      final manifest = {
        "app": "PHR",
        "version": "1.0.0",
        "created_at": DateTime.now().toIso8601String(),
        "notes_count": notes.length,
        "files_count": fileIndex,
        "audio_count": audioIndex,
      };

      await File(
        p.join(backupDir.path, "manifest.json"),
      ).writeAsString(jsonEncode(manifest));

      final zipPath = p.join(
        tempDir.path,
        "phr_backup_${DateTime.now().millisecondsSinceEpoch}.zip",
      );

      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addDirectory(backupDir);
      encoder.close();

      final zipBytes = await File(zipPath).readAsBytes();

      final saved = await FilePicker.platform.saveFile(
        dialogTitle: "Save PHR Backup",
        fileName: p.basename(zipPath),
        bytes: zipBytes,
      );

      message = saved != null
          ? "Backup exported successfully ✔"
          : "Export cancelled";
    } catch (e) {
      message = "Export failed: $e";
    }

    setState(() => exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Backup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.backup, size: 90, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Export all your personal health records.\n"
              "Notes are readable, tables open in Excel.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            exporting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: exportBackup,
                    icon: const Icon(Icons.download),
                    label: const Text("Export Backup"),
                  ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: message.contains("failed") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
