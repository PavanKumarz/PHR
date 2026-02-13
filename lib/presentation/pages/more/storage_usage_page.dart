import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:phr/data/datasources/database_helper.dart';
import 'package:phr/data/models/note_model.dart';

class StorageUsagePage extends StatefulWidget {
  const StorageUsagePage({super.key});

  @override
  State<StorageUsagePage> createState() => _StorageUsagePageState();
}

class _StorageUsagePageState extends State<StorageUsagePage> {
  int dbSize = 0;
  int filesSize = 0;
  int audioSize = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    calculateStorage();
  }

  Future<void> calculateStorage() async {
    dbSize = await _getDatabaseSize();
    await _calculateNotesMediaSize();

    setState(() => loading = false);
  }

  Future<int> _getDatabaseSize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "notes.db");

    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<void> _calculateNotesMediaSize() async {
    filesSize = 0;
    audioSize = 0;

    final notes = await DatabaseHelper.instance.getNotes();

    for (NoteModel note in notes) {
      for (String path in note.files) {
        final file = File(path);
        if (await file.exists()) {
          filesSize += await file.length();
        }
      }

      for (String path in note.audio) {
        final file = File(path);
        if (await file.exists()) {
          audioSize += await file.length();
        }
      }
    }
  }

  String formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    double kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(2)} KB";
    double mb = kb / 1024;
    return "${mb.toStringAsFixed(2)} MB";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = dbSize + filesSize + audioSize;

    return Scaffold(
      appBar: AppBar(title: const Text("Storage Usage")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(
            title: "Database Size",
            subtitle: "Notes, settings, metadata",
            icon: Icons.storage,
            size: dbSize,
          ),

          _item(
            title: "Documents",
            subtitle: "Files attached to notes",
            icon: Icons.insert_drive_file,
            size: filesSize,
          ),

          _item(
            title: "Audio Notes",
            subtitle: "Voice recordings",
            icon: Icons.mic,
            size: audioSize,
          ),

          const SizedBox(height: 20),
          Divider(),
          const SizedBox(height: 20),

          _item(
            title: "Total Storage Used",
            subtitle: "All app data combined",
            icon: Icons.folder,
            size: total,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String title,
    required String subtitle,
    required IconData icon,
    required int size,
    bool bold = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800]),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 18 : 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          formatSize(size),
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: Colors.blue[700],
          ),
        ),
      ),
    );
  }
}
