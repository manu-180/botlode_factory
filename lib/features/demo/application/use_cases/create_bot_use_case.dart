import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../data/repositories/demo_repository_provider.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/repositories/i_demo_repository.dart';
import '../../domain/value_objects/bot_color.dart';
import 'bot_validation_result.dart';

/// Resultado de la creación de un bot.
class CreateBotResult {
  final DemoBotEntity bot;
  final bool isSyncedWithRemote;

  const CreateBotResult({
    required this.bot,
    required this.isSyncedWithRemote,
  });
}

/// Excepción de validación con tipo específico
class BotValidationException implements Exception {
  final String message;
  final BotValidationErrorType errorType;

  BotValidationException(this.message, this.errorType);

  @override
  String toString() => message;
}

/// Caso de uso para crear un nuevo bot.
/// Encapsula la lógica de negocio de creación, incluyendo:
/// - Validación de datos de entrada
/// - Generación de ID local
/// - Creación de la entidad
/// - Sincronización opcional con el repositorio remoto
class CreateBotUseCase {
  final IDemoRepository _repository;
  int _localIdCounter = 0;

  CreateBotUseCase(this._repository) {
    _localIdCounter = _repository.loadCounter();
  }

  /// Ejecuta la creación de un bot.
  /// Crea un bot SOLO si Supabase está disponible (NO modo offline).
  Future<CreateBotResult> execute({
    required String name,
    required String prompt,
    required BotColor color,
  }) async {
    LoggerService.startOperation('CREACIÓN DE BOT', tag: 'CreateBotUseCase');
    
    // Validación de negocio
    final validation = _validateBotData(name, prompt);
    if (!validation.isValid) {
      throw BotValidationException(
        validation.errorMessage!,
        validation.errorType!,
      );
    }

    LoggerService.success('Validación pasada - Nombre: $name', tag: 'CreateBotUseCase');

    // CRÍTICO: Verificar Supabase PRIMERO (antes de crear nada)
    if (_repository.isLoading) {
      LoggerService.warning('Supabase está inicializándose', tag: 'CreateBotUseCase');
      throw Exception('Supabase está inicializándose. Por favor espera unos segundos e intenta de nuevo.');
    }
    
    if (!_repository.isAvailable) {
      LoggerService.error('Supabase NO está disponible', tag: 'CreateBotUseCase');
      throw Exception('Supabase no está conectado. Por favor recarga la página.');
    }

    LoggerService.success('Supabase disponible - procediendo', tag: 'CreateBotUseCase');

    // Crear bot temporal con IDs generados para enviar a Supabase
    final tempBot = DemoBotEntity.withGeneratedIds(
      id: 'temp_id', // ID temporal que será reemplazado por el UUID de Supabase
      name: name.trim(),
      prompt: prompt.trim(),
      color: color,
      createdAt: DateTime.now(),
    );

    LoggerService.info('Enviando bot a Supabase - Session: ${tempBot.sessionId}', tag: 'CreateBotUseCase');
    
    final remoteBot = await _repository.createBot(tempBot);
    
    if (remoteBot == null) {
      LoggerService.error('Supabase retornó NULL - La inserción falló', tag: 'CreateBotUseCase');
      throw Exception('No se pudo crear el bot en Supabase. Verifica los permisos de la tabla.');
    }
    
    LoggerService.endOperationSuccess('CREACIÓN DE BOT - ID: ${remoteBot.id}', tag: 'CreateBotUseCase');
    
    return CreateBotResult(
      bot: remoteBot,
      isSyncedWithRemote: true,
    );
  }

  /// Valida los datos de entrada del bot
  BotValidationResult _validateBotData(String name, String prompt) {
    // Validar nombre vacío
    if (name.trim().isEmpty) {
      return const BotValidationResult.error(
        errorMessage: 'El nombre del bot es requerido',
        errorType: BotValidationErrorType.nameEmpty,
      );
    }

    // Validar nombre muy corto
    if (name.trim().length < 3) {
      return const BotValidationResult.error(
        errorMessage: 'El nombre debe tener al menos 3 caracteres',
        errorType: BotValidationErrorType.nameTooShort,
      );
    }

    // Validar prompt vacío
    if (prompt.trim().isEmpty) {
      return const BotValidationResult.error(
        errorMessage: 'La personalidad del bot es esencial para su funcionamiento',
        errorType: BotValidationErrorType.promptEmpty,
      );
    }

    // Validar prompt muy corto
    if (prompt.trim().length < 10) {
      return const BotValidationResult.error(
        errorMessage: 'La personalidad requiere más detalle para crear un bot efectivo',
        errorType: BotValidationErrorType.promptTooShort,
      );
    }

    return const BotValidationResult.success();
  }

  /// Reinicia el contador de IDs locales.
  Future<void> resetCounter() async {
    _localIdCounter = 0;
    await _repository.saveCounter(_localIdCounter);
  }
}

/// Provider del caso de uso de crear bot.
final createBotUseCaseProvider = Provider<CreateBotUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  return CreateBotUseCase(repository);
});
