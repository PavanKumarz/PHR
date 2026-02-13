import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HealthDatabase {
  static final HealthDatabase instance = HealthDatabase._init();
  static Database? _database;

  HealthDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("health.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        value TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertRecord(String type, String value, DateTime date) async {
    final db = await database;
    await db.insert("health_records", {
      "type": type,
      "value": value,
      "date": date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecords(String type) async {
    final db = await database;
    return await db.query(
      "health_records",
      where: "type = ?",
      whereArgs: [type],
      orderBy: "date DESC",
    );
  }
}
