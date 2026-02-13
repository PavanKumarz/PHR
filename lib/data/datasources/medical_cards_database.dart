import 'package:path/path.dart';
import 'package:phr/data/models/medical_card_model.dart';
import 'package:sqflite/sqflite.dart';

class MedicalCardsDatabase {
  static final MedicalCardsDatabase instance = MedicalCardsDatabase._init();
  static Database? _database;

  MedicalCardsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("medical_cards.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medical_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        image_path TEXT,
        date TEXT
      )
    ''');
  }

  Future<int> insertCard(MedicalCardModel card) async {
    final db = await database;
    return await db.insert("medical_cards", card.toMap());
  }

  Future<List<MedicalCardModel>> getCards() async {
    final db = await database;
    final res = await db.query("medical_cards", orderBy: "id DESC");
    return res.map((e) => MedicalCardModel.fromMap(e)).toList();
  }

  Future<void> deleteCard(int id) async {
    final db = await database;
    await db.delete("medical_cards", where: "id = ?", whereArgs: [id]);
  }
}
