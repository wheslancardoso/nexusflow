import 'schedule.manager.dart';
import '../logging/log.service.dart';

class SyncSystemInitializer {
  static Future<void> initialize() async {
    await LogService.instance.initialize();
    await ScheduleManager.instance.initialize();
  }

  static Future<void> forceSyncAll() async {
    await ScheduleManager.instance.syncAll();
  }

  static Future<void> syncFeature(String name) async {
    await ScheduleManager.instance.syncFeature(name);
  }
}
