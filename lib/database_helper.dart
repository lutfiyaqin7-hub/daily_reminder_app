import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // =====================================================
  // 1. DATABASE INSTANCE
  // =====================================================

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('daily_reminder.db');

    return _database!;
  }

  // =====================================================
  // 2. MEMBUAT DATABASE
  // =====================================================

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // =====================================================
  // 3. MEMBUAT TABEL ACTIVITIES
  // =====================================================

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Pribadi',
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // =====================================================
  // 4. MIGRASI DATABASE
  // =====================================================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE activities
        ADD COLUMN category TEXT NOT NULL DEFAULT 'Kuliah'
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE activities
        ADD COLUMN user_id TEXT
      ''');

      // Menghapus data agenda lama
      await db.delete('activities');
    }
  }

  // =====================================================
  // 5. MENAMBAHKAN AGENDA
  // =====================================================

  Future<int> insertActivity(String userId, Map<String, dynamic> row) async {
    final db = await database;

    if (userId.isEmpty) {
      throw Exception('User ID tidak ditemukan.');
    }

    return await db.insert('activities', {
      ...row,
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // =====================================================
  // 6. MENGAMBIL AGENDA BERDASARKAN USER ID
  // =====================================================

  Future<List<Map<String, dynamic>>> getActivities(String userId) async {
    final db = await database;

    if (userId.isEmpty) {
      return [];
    }

    return await db.query(
      'activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // =====================================================
  // 7. MENGHAPUS AGENDA
  // =====================================================

  Future<int> deleteActivity(int id, String userId) async {
    final db = await database;

    return await db.delete(
      'activities',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // =====================================================
  // 8. MENGUBAH STATUS AGENDA
  // =====================================================

  Future<int> updateActivity(int id, int isActive, String userId) async {
    final db = await database;

    return await db.update(
      'activities',
      {'is_active': isActive},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // =====================================================
  // 9. MENGHITUNG JUMLAH AGENDA
  // =====================================================

  Future<int> countActivities(String userId) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM activities WHERE user_id = ?',
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =====================================================
  // 10. MENUTUP DATABASE
  // =====================================================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
