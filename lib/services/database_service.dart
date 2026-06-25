// SQLite persistence for the PDF generation history.

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/pdf_export.dart';

class DatabaseService {
  static const _dbName = 'photo_to_pdf.db';
  static const _table = 'pdf_history';
  static Database? _db;

  /// Lazily open (and create) the database.
  static Future<Database> _database() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            file_name TEXT NOT NULL,
            file_path TEXT NOT NULL,
            image_count INTEGER NOT NULL,
            file_size INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Insert a new PDF record.
  static Future<void> insert(PdfExport export) async {
    final db = await _database();
    await db.insert(
      _table,
      export.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all records, newest first.
  static Future<List<PdfExport>> getAll() async {
    final db = await _database();
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(PdfExport.fromMap).toList();
  }

  /// Delete a record by id.
  static Future<void> delete(String id) async {
    final db = await _database();
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
