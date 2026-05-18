import '../http/app_client.dart';
import '../logging/log.service.dart';
import 'base.model.dart';

abstract class BaseProvider<E extends BaseModel> {
  final AppClient client = AppClient.instance;
  final LogService logger = LogService.instance;

  String get endpoint;

  Map<String, dynamic> toExternalFormat(E entity);
  E fromExternalFormat(Map<String, dynamic> data);

  Future<void> syncToCloud(E entity) async {
    try {
      final data = toExternalFormat(entity);
      if (entity.id != null) {
        await client.put('$endpoint/${entity.id}', data: data);
      } else {
        await client.post(endpoint, data: data);
      }
      await logger.info('BaseProvider', 'syncToCloud', 'Entidade sincronizada com sucesso');
    } catch (e) {
      await logger.error('BaseProvider', 'syncToCloud', 'Erro ao sincronizar: $e');
      rethrow;
    }
  }

  Future<List<E>> fetchFromCloud() async {
    try {
      final response = await client.get(endpoint);
      final List<dynamic> data = response.data;
      return data.map((item) => fromExternalFormat(item)).toList();
    } catch (e) {
      await logger.error('BaseProvider', 'fetchFromCloud', 'Erro ao buscar dados: $e');
      rethrow;
    }
  }

  Future<bool> validateBeforeSync(E entity);
}
