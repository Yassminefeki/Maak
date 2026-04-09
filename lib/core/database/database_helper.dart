import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/procedure.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ✅ Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('maak.db');
    return _database!;
  }

  // ✅ Initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ✅ CREATE TABLE (YOUR SQL HERE ✔️)
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE procedures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        steps TEXT,
        required_documents TEXT,
        cost TEXT,
        time_required TEXT,
        where_to_go TEXT,
        important_notes TEXT
      )
    ''');
  }
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;

    final result = await db.query('profil', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  // ✅ INSERT DEFAULT DATA
  Future<void> insertDefaultProcedures() async {
    final db = await database;

    await db.insert('procedures', {
      'key': 'lost_cin',
      'title': 'فقدت بطاقة التعريف',
      'description': 'دليل كامل لاستبدال بطاقة التعريف الوطنية',
      'steps':
          '1. الذهاب إلى أقرب مركز شرطة||2. تقديم شكوى فقدان||3. التوجه إلى البلدية||4. دفع الرسوم||5. استلام البطاقة الجديدة',
      'required_documents':
          'صورة شمسية||نسخة من بطاقة قديمة (إن وجدت)||شهادة إقامة||وصل دفع',
      'cost': '15 دينار',
      'time_required': '7 إلى 15 يوم',
      'where_to_go': 'مركز الشرطة + البلدية',
      'important_notes': 'يجب الإبلاغ فوراً لتفادي الاستعمال السيء',
    });
  }

  // ✅ GET PROCEDURE
  Future<Procedure?> getProcedure(String key) async {
    final db = await database;

    final maps = await db.query(
      'procedures',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return Procedure.fromMap(maps.first);
    }
    return null;
  }
}