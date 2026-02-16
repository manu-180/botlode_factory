import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_repository_provider.dart';
import '../../domain/repositories/i_demo_repository.dart';

/// Caso de uso para eliminar un bot.
/// Encapsula la lógica de eliminación tanto local como remota.
class DeleteBotUseCase {
  final IDemoRepository _repository;

  DeleteBotUseCase(this._repository);

  /// Ejecuta la eliminación de un bot.
  /// Retorna true si se eliminó correctamente.
  Future<bool> execute(String botId) async {
    return await _repository.deleteBot(botId);
  }
}

/// Provider del caso de uso de eliminar bot.
final deleteBotUseCaseProvider = Provider<DeleteBotUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  return DeleteBotUseCase(repository);
});
