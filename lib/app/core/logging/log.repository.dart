import '../base/base.repository.dart';
import 'log.model.dart';

class LogRepository extends BaseRepository<LogEntry> {
  @override
  String get tableName => 'system_logs';

  @override
  LogEntry fromMap(Map<String, dynamic> map) {
    return LogEntry.fromMap(map);
  }

  Future<void> logError(LogEntry entry) async {
    await insert(entry);
  }

  Future<List<LogEntry>> findByLevel(String level) async {
    final db = await dbHelper.database;
    final results = await db.query(
      tableName,
      where: 'level = ?',
      whereArgs: [level],
    );
    return results.map((e) => LogEntry.fromMap(e)).toList();
  }

  Future<List<LogEntry>> findRecent(int hours) async {
    final db = await dbHelper.database;
    final threshold = DateTime.now().subtract(Duration(hours: hours)).toIso8601String();
    final results = await db.query(
      tableName,
      where: 'created_at >= ?',
      whereArgs: [threshold],
    );
    return results.map((e) => LogEntry.fromMap(e)).toList();
  }

  Future<void> cleanupOldLogs(int days) async {
    final db = await dbHelper.database;
    final threshold = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    await db.delete(
      tableName,
      where: 'created_at < ?',
      whereArgs: [threshold],
    );
  }
}
