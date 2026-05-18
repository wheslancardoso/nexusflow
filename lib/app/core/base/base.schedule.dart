import 'dart:async';
import 'base.model.dart';
import 'base.repository.dart';
import 'base.provider.dart';

abstract class BaseSchedule<E extends BaseModel, R extends BaseRepository<E>, P extends BaseProvider<E>> {
  final R repository;
  final P provider;
  final String featureName;
  final Duration syncInterval;

  Timer? _syncTimer;
  bool _isRunning = false;

  BaseSchedule({
    required this.repository,
    required this.provider,
    required this.featureName,
    this.syncInterval = const Duration(minutes: 5),
  });

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;
    _syncTimer = Timer.periodic(syncInterval, (_) => syncNow());
    print('🔄 $featureName Schedule iniciado (${syncInterval.inMinutes}min)');
  }

  void stop() {
    _syncTimer?.cancel();
    _isRunning = false;
    print('⏹️ $featureName Schedule parado');
  }

  Future<void> syncNow() async {
    try {
      await uploadPendingChanges();
      await downloadUpdates();
      print('✅ $featureName sincronizado com sucesso');
    } catch (e) {
      print('❌ Erro na sincronização $featureName: $e');
    }
  }

  Future<void> uploadPendingChanges() async {
    final pendingItems = await repository.findAllPendingSync();
    for (final item in pendingItems) {
      try {
        final isValid = await provider.validateBeforeSync(item);
        if (!isValid) continue;

        await provider.syncToCloud(item);
        item.markAsSynced();
        await repository.update(item);
      } catch (e) {
        print('❌ Erro ao enviar ${item.id}: $e');
      }
    }
  }

  Future<void> downloadUpdates() async {
    try {
      final cloudItems = await provider.fetchFromCloud();
      for (final item in cloudItems) {
        final existing = await repository.findById(item.id!);
        if (existing == null) {
          item.markAsSynced();
          await repository.insert(item);
        } else {
          final resolved = await resolveConflict(existing, item);
          await repository.update(resolved);
        }
      }
    } catch (e) {
      print('❌ Erro ao baixar atualizações: $e');
    }
  }

  Future<E> resolveConflict(E local, E remote);
}
