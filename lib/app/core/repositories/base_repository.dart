import '../models/base.model.dart';

abstract class BaseRepository<T extends BaseModel> {
  // SQLite Local Operations
  Future<int> saveLocal(T model);
  Future<List<T>> getAllLocal();
  Future<T?> getByIdLocal(String id);
  Future<int> deleteLocal(String id);
  Future<int> updateLocal(T model);

  // API Remote Operations
  Future<T> saveRemote(T model);
  Future<List<T>> getAllRemote();
  Future<T?> getByIdRemote(String id);
  Future<void> deleteRemote(String id);
  
  // Sync Logic
  Future<void> sync();
}
