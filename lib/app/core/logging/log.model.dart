import '../base/base.model.dart';

class LogEntry extends BaseModel {
  final String level;
  final String source;
  final String operation;
  final String message;
  final String? metadata;
  final DateTime? timestamp;

  LogEntry({
    super.id,
    required this.level,
    required this.source,
    required this.operation,
    required this.message,
    this.metadata,
    this.timestamp,
    super.isSync = 0,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'level': level,
      'source': source,
      'operation': operation,
      'message': message,
      'metadata': metadata,
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'is_sync': isSync,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as int?,
      level: map['level'] as String,
      source: map['source'] as String,
      operation: map['operation'] as String,
      message: map['message'] as String,
      metadata: map['metadata'] as String?,
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) : null,
      isSync: map['is_sync'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  @override
  LogEntry copyWith({
    int? id,
    String? level,
    String? source,
    String? operation,
    String? message,
    String? metadata,
    DateTime? timestamp,
    int? isSync,
    DateTime? createdAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      level: level ?? this.level,
      source: source ?? this.source,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      isSync: isSync ?? this.isSync,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
