import 'base.model.dart';
import 'base.repository.dart';
import 'base.validation.dart';

abstract class BaseService<E extends BaseModel, R extends BaseRepository<E>, V extends BaseValidation<E, R>> {
  final R repository;
  final V validation;

  BaseService({required this.repository, required this.validation});

  Future<E> create(E entity) async {
    await validation.validateFieldCreate(entity);
    await validation.validateRulesCreate(entity);

    final id = await repository.insert(entity);
    return cloneModelWithId(entity, id);
  }

  Future<E> update(E entity) async {
    await validation.validateFieldUpdate(entity);
    await validation.validateRulesUpdate(entity);

    await repository.update(entity);
    return entity;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
  }

  Future<List<E>> listar() async {
    return await repository.findAll();
  }

  E cloneModelWithId(E model, int id);
}
