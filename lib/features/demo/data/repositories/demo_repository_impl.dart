import 'package:uuid/uuid.dart';

import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/repositories/i_demo_repository.dart';
import '../data_sources/demo_local_data_source.dart';
import '../data_sources/demo_remote_data_source.dart';
import '../models/demo_bot_model.dart';

/// Implementación concreta del repositorio de demo.
/// Coordina entre el data source remoto (Supabase) y el local (SharedPreferences).
class DemoRepositoryImpl implements IDemoRepository {
  final IDemoRemoteDataSource _remoteDataSource;
  final IDemoLocalDataSource _localDataSource;

  DemoRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  bool get isAvailable => _remoteDataSource.isAvailable;
  
  @override
  bool get isLoading => _remoteDataSource.isLoading;

  @override
  Future<DemoBotEntity?> createBot(DemoBotEntity bot) async {
    final model = DemoBotModel.fromEntity(bot);
    
    // Intentar crear en remoto si está disponible
    if (_remoteDataSource.isAvailable) {
      final remoteBot = await _remoteDataSource.createBot(model);
      if (remoteBot != null) {
        return remoteBot.toEntity();
      }
    }

    // Si no hay remoto o falla (ej. 401 RLS), retornar bot con ID local marcado.
    // Luego el envío de mensajes puede convertirlo a temp_id para evitar 500 por bot inexistente.
    final uniqueId = const Uuid().v4();
    return bot.copyWith(id: 'local_temp_$uniqueId');
  }

  @override
  Future<BotMessageResponse?> sendMessage({
    required String botId,
    required String message,
    required String sessionId,
    required String chatId,
    String? botName,
    String? systemPrompt,
  }) async {
    final response = await _remoteDataSource.sendMessage(
      botId: botId,
      message: message,
      sessionId: sessionId,
      chatId: chatId,
      botName: botName,
      systemPrompt: systemPrompt,
    );
    
    if (response == null) return null;
    
    return BotMessageResponse(
      message: response.reply,
      mood: response.mood,
    );
  }

  @override
  Future<bool> deleteBot(String botId) async {
    // Eliminar del remoto si está disponible
    if (_remoteDataSource.isAvailable) {
      await _remoteDataSource.deleteBot(botId);
    }
    
    // La eliminación local se manejará al guardar la lista actualizada
    return true;
  }

  @override
  Future<List<DemoBotEntity>> getBots() async {
    if (_remoteDataSource.isAvailable) {
      final remoteBots = await _remoteDataSource.getBots();
      return remoteBots.map((model) => model.toEntity()).toList();
    }
    
    return [];
  }

  @override
  Future<DemoBotEntity?> getBotById(String id) async {
    if (_remoteDataSource.isAvailable) {
      final remoteBot = await _remoteDataSource.getBotById(id);
      return remoteBot?.toEntity();
    }
    
    return null;
  }

  @override
  List<DemoBotEntity> loadBots() {
    final localBots = _localDataSource.loadBots();
    return localBots.map((model) {
      var entity = model.toEntity();
      // Migrar IDs legacy temp_id a formato local único para evitar colisiones de selección.
      if (entity.id == 'temp_id') {
        entity = entity.copyWith(id: 'local_temp_${const Uuid().v4()}');
      }
      // Bots cargados desde JSON antiguo pueden tener sessionId/chatId vacíos; rellenar para evitar error en botlode-brain.
      if (entity.sessionId.isEmpty || entity.chatId.isEmpty) {
        entity = entity.copyWith(
          sessionId: entity.sessionId.isEmpty ? const Uuid().v4() : entity.sessionId,
          chatId: entity.chatId.isEmpty ? const Uuid().v4() : entity.chatId,
        );
      }
      return entity;
    }).toList();
  }

  @override
  Future<List<DemoBotEntity>> loadBotsPreferRemote() async {
    if (_remoteDataSource.isAvailable) {
      try {
        final remoteBots = await _remoteDataSource.getBots();
        if (remoteBots.isNotEmpty) {
          final entities = remoteBots.map((m) => m.toEntity()).toList();
          await saveBots(entities);
          return entities;
        }
      } catch (e) {
        // Si falla remoto, continuar y usar local
      }
    }
    return loadBots();
  }

  @override
  Future<void> saveBots(List<DemoBotEntity> bots) async {
    final models = bots.map((bot) => DemoBotModel.fromEntity(bot)).toList();
    await _localDataSource.saveBots(models);
  }

  @override
  int loadCounter() {
    return _localDataSource.loadCounter();
  }

  @override
  Future<void> saveCounter(int counter) async {
    await _localDataSource.saveCounter(counter);
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
