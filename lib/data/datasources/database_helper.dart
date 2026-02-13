import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'package:phr/data/models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("notes.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute("""
     CREATE TABLE notes (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       title TEXT,
       text TEXT,
       tableData TEXT,
       viewMode TEXT,
       files TEXT,
       audio TEXT,
       date TEXT
     )
    """);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {}
  Future<int> insertNote(NoteModel note) async {
    final db = await instance.database;

    final data = note.toMap()..remove("id");

    return await db.insert("notes", data);
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.database;

    return await db.update(
      "notes",
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;

    return await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await instance.database;

    final result = await db.query("notes", orderBy: "id DESC");

    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await instance.database;

    final res = await db.query("notes", where: "id = ?", whereArgs: [id]);

    if (res.isEmpty) return null;

    return NoteModel.fromMap(res.first);
  }
}
