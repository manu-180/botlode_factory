import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_repository_provider.dart';
import '../../domain/repositories/i_demo_repository.dart';

/// Caso de uso para limpiar todos los bots y datos del demo.
/// Encapsula la lógica de limpieza completa de datos locales.
class ClearAllBotsUseCase {
  final IDemoRepository _repository;

  ClearAllBotsUseCase(this._repository);

  /// Ejecuta la limpieza de todos los datos del demo.
  /// Elimina todos los bots y reinicia el contador.
  Future<void> execute() async {
    await _repository.clearAll();
  }
}

/// Provider del caso de uso de limpiar todos los bots.
final clearAllBotsUseCaseProvider = Provider<ClearAllBotsUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  return ClearAllBotsUseCase(repository);
});
