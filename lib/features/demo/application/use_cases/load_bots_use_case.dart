import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_repository_provider.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/repositories/i_demo_repository.dart';

/// Caso de uso para cargar bots (remoto primero, luego local).
/// Al abrir el demo intenta cargar desde Supabase; si hay datos los sincroniza a local.
class LoadBotsUseCase {
  final IDemoRepository _repository;

  LoadBotsUseCase(this._repository);

  /// Carga solo desde almacenamiento local (síncrono).
  List<DemoBotEntity> execute() {
    return _repository.loadBots();
  }

  /// Carga intentando primero Supabase; si hay bots los guarda en local y los retorna.
  /// Si remoto falla o está vacío, usa la carga local. Así persisten al cerrar/abrir la web.
  Future<List<DemoBotEntity>> executePreferRemote() async {
    return _repository.loadBotsPreferRemote();
  }
}

/// Provider del caso de uso de cargar bots.
final loadBotsUseCaseProvider = Provider<LoadBotsUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  return LoadBotsUseCase(repository);
});
