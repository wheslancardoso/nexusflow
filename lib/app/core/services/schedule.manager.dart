import '../base/base.schedule.dart';
import '../../modules/usuarios/data/usuario.schedule.dart';
import '../../modules/clientes/data/cliente.schedule.dart';

class ScheduleManager {
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;
  ScheduleManager._internal();

  final List<BaseSchedule> _schedules = [];

  Future<void> initialize() async {
    _schedules.addAll([
      UsuarioSchedule(),
      ClienteSchedule(),
    ]);

    for (final schedule in _schedules) {
      await schedule.start();
    }

    print('🚀 ScheduleManager inicializado com ${_schedules.length} schedules');
  }

  Future<void> stopAll() async {
    for (final schedule in _schedules) {
      schedule.stop();
    }
    print('⏹️ Todos os schedules foram parados');
  }

  Future<void> syncAll() async {
    for (final schedule in _schedules) {
      await schedule.syncNow();
    }
  }

  Future<void> syncFeature(String name) async {
    for (final schedule in _schedules) {
      if (schedule.featureName.toLowerCase() == name.toLowerCase()) {
        await schedule.syncNow();
      }
    }
  }

  Map<String, dynamic> getStatus() {
    return {
      'schedules': _schedules.map((s) => s.featureName).toList(),
    };
  }

  List<String> getRegisteredFeatures() {
    return _schedules.map((s) => s.featureName).toList();
  }
}
