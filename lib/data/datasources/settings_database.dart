import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

class SettingsDatabase {
  static final SettingsDatabase instance = SettingsDatabase._init();

  static Database? _database;

  SettingsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("settings.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;

    await db.insert("settings", {
      "key": key,
      "value": value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;

    final result = await db.query(
      "settings",
      where: "key = ?",

      whereArgs: [key],
    );

    if (result.isEmpty) return null;

    return result.first["value"] as String?;
  }
}
