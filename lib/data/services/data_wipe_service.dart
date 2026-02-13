import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataWipeService {
  static Future<void> deleteAllDatabases() async {
    final dbPath = await getDatabasesPath();

    final databases = [
      "notes.db",
      "health.db",
      "settings.db",
      "medical_cards.db",
    ];

    for (final db in databases) {
      final path = "$dbPath/$db";
      if (await File(path).exists()) {
        await deleteDatabase(path);
      }
    }
  }

  static Future<void> deleteAllFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    if (dir.existsSync()) {
      for (final entity in dir.listSync()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    }
  }

  static Future<void> wipeEverything() async {
    await deleteAllDatabases();
    await deleteAllFiles();
  }
}
