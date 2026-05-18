import 'log.model.dart';
import 'log.repository.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  static LogService get instance => _instance;

  LogService._internal();

  final LogRepository _repository = LogRepository();

  Future<void> initialize() async {
    await _repository.cleanupOldLogs(30);
  }

  Future<void> error(String source, String operation, String message, {String? metadata}) async {
    final entry = LogEntry(
      level: 'error',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
    );
    await _repository.logError(entry);
  }

  Future<void> warning(String source, String operation, String message, {String? metadata}) async {
    final entry = LogEntry(
      level: 'warning',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
    );
    await _repository.insert(entry);
  }

  Future<void> info(String source, String operation, String message, {String? metadata}) async {
    final entry = LogEntry(
      level: 'info',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
    );
    await _repository.insert(entry);
  }

  Future<void> debug(String source, String operation, String message, {String? metadata}) async {
    final entry = LogEntry(
      level: 'debug',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
    );
    await _repository.insert(entry);
  }
}
