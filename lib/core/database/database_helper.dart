import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('adminprocess.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        cin TEXT NOT NULL,
        address TEXT NOT NULL,
        dob TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertProfile(UserProfile profile) async {
    final db = await instance.database;
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getProfile() async {
    final db = await instance.database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<int> updateProfile(UserProfile profile) async {
    final db = await instance.database;
    return await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }
}
