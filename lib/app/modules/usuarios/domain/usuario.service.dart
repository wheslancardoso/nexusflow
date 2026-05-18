import '../../../core/base/base.service.dart';
import '../data/usuario.model.dart';
import '../data/usuario.repository.dart';
import 'usuario.validation.dart';

class UsuarioService extends BaseService<Usuario, UsuarioRepository, UsuarioValidation> {
  UsuarioService({
    required UsuarioRepository repository,
    required UsuarioValidation validation,
  }) : super(repository: repository, validation: validation);

  @override
  Usuario cloneModelWithId(Usuario model, int id) {
    return model.copyWith(id: id);
  }
}
