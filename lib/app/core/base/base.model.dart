import 'dart:convert';

abstract class BaseModel {
  int? id;
  int isSync; // 0 = pendente, 1 = sincronizado
  DateTime? createdAt;

  BaseModel({
    this.id,
    this.isSync = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap();
  String toJson() => json.encode(toMap());
  BaseModel copyWith();

  bool get isPendingSync => isSync == 0;
  bool get isSynchronized => isSync == 1;

  void markAsSynced() => isSync = 1;
  void markAsPending() => isSync = 0;
}
