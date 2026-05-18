import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import 'base.model.dart';

abstract class BaseRepository<E extends BaseModel> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  String get tableName;

  Future<int> insert(E item) async {
    final db = await dbHelper.database;
    final map = item.toMap();
    // Remove ID field if it's null to let SQLite generate an autoincrement ID
    if (map['id'] == null) {
      map.remove('id');
    }
    return await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(E item) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      {'ativo': 0, 'is_sync': 0}, // Soft delete aligns with offline-first!
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<E>> findAll() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'ativo = ?',
      whereArgs: [1],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<E?> findById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'id = ? AND ativo = ?',
      whereArgs: [id, 1],
    );
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  Future<List<E>> findAllPendingSync() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'is_sync = ? AND ativo = ?',
      whereArgs: [0, 1],
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  E fromMap(Map<String, dynamic> map);
}
