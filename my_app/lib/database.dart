import 'package:path/path.dart';
import 'note.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class DatabaseService {
  static sqflite.Database? _database;
  static const String _dbName = 'notes.db';
  static const String _tableName = 'notes';
  static bool _isInitialized = false;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    await _initializeDatabaseFactory();
    
    _database = await _initDatabase();
    _isInitialized = true;
    return _database!;
  }

  Future<void> _initializeDatabaseFactory() async {
    // Инициализация database factory для desktop платформ
    if (!_isInitialized) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _isInitialized = true;
    }
  }

  Future<sqflite.Database> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      
      final path = join(databasePath, _dbName);

      final db = await databaseFactory.openDatabase(
        path,
        options: sqflite.OpenDatabaseOptions(
          version: 1,
          onCreate: _createDatabase,
        ),
      );
      return db;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getDatabasesPath() async {
    return '.';
  }

  Future<void> _createDatabase(sqflite.Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> insertNote(Note note) async {
    try {
      final db = await database;
      final id = await db.insert(_tableName, note.toMap());
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getNotes() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      
      final notes = List.generate(maps.length, (i) {
        final note = Note.fromMap(maps[i]);
        return note;
      });
      
      return notes;
    } catch (e) {
      return [];
    }
  }

  Future<int> updateNote(Note note) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteNote(int id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}