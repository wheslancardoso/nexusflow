import 'base.model.dart';
import 'base.repository.dart';

abstract class BaseValidation<E extends BaseModel, R extends BaseRepository<E>> {
  Future<void> validateFieldCreate(E entity);
  Future<void> validateRulesCreate(E entity);
  Future<void> validateFieldUpdate(E entity);
  Future<void> validateRulesUpdate(E entity);
}
