import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/repositories/i_demo_repository.dart';

/// Caso de uso para persistir bots con control de concurrencia
class PersistBotsUseCase {
  final IDemoRepository _repository;
  bool _isPersisting = false;

  PersistBotsUseCase(this._repository);

  /// Persiste la lista de bots con control de concurrencia
  /// Retorna true si la persistencia fue exitosa, false si ya había una operación en curso
  Future<bool> execute(List<DemoBotEntity> bots) async {
    // Evitar múltiples llamadas simultáneas
    if (_isPersisting) return false;
    
    try {
      _isPersisting = true;
      await _repository.saveBots(bots);
      return true;
    } finally {
      _isPersisting = false;
    }
  }

  /// Indica si hay una operación de persistencia en curso
  bool get isPersisting => _isPersisting;
}
