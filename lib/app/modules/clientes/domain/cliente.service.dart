import '../../../core/base/base.service.dart';
import '../cliente.model.dart';
import '../data/cliente.repository.dart';
import 'cliente.validation.dart';

class ClienteService extends BaseService<Cliente, ClienteRepository, ClienteValidation> {
  ClienteService({
    required ClienteRepository repository,
    required ClienteValidation validation,
  }) : super(repository: repository, validation: validation);

  @override
  Cliente cloneModelWithId(Cliente model, int id) {
    return model.copyWith(id: id);
  }
}
