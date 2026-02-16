import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../application/use_cases/clear_all_bots_use_case.dart';
import '../../application/use_cases/create_bot_use_case.dart';
import '../../application/use_cases/delete_bot_use_case.dart';
import '../../application/use_cases/load_bots_use_case.dart';
import '../../application/use_cases/persist_bots_use_case.dart';
import '../../application/use_cases/persist_bots_use_case_provider.dart';
import '../../application/use_cases/send_message_use_case.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/entities/demo_chat_message.dart';
import '../mappers/bot_ui_mapper.dart';

/// Estado del demo.
class DemoState {
  final List<DemoBotEntity> bots;
  final String? selectedBotId;
  final bool isCreating;
  final String? error;

  const DemoState({
    this.bots = const [],
    this.selectedBotId,
    this.isCreating = false,
    this.error,
  });

  DemoBotEntity? get selectedBot {
    if (selectedBotId == null || bots.isEmpty) return null;
    try {
      return bots.firstWhere((b) => b.id == selectedBotId);
    } catch (e) {
      return bots.isNotEmpty ? bots.first : null;
    }
  }

  DemoState copyWith({
    List<DemoBotEntity>? bots,
    String? selectedBotId,
    bool? isCreating,
    String? error,
  }) {
    return DemoState(
      bots: bots ?? this.bots,
      selectedBotId: selectedBotId ?? this.selectedBotId,
      isCreating: isCreating ?? this.isCreating,
      error: error,
    );
  }
}

/// Notifier para gestionar el estado del demo.
/// Solo gestiona estado de UI y delega toda la lógica de negocio a los use cases.
class DemoNotifier extends StateNotifier<DemoState> {
  final CreateBotUseCase _createBotUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final LoadBotsUseCase _loadBotsUseCase;
  final DeleteBotUseCase _deleteBotUseCase;
  final ClearAllBotsUseCase _clearAllBotsUseCase;
  final PersistBotsUseCase _persistBotsUseCase;
  
  // ⚡ OPTIMIZACIÓN: Flag para lazy loading
  bool _isInitialized = false;

  DemoNotifier(
    this._createBotUseCase,
    this._sendMessageUseCase,
    this._loadBotsUseCase,
    this._deleteBotUseCase,
    this._clearAllBotsUseCase,
    this._persistBotsUseCase,
  ) : super(const DemoState()) {
    // ⚡ OPTIMIZACIÓN: Ya NO cargamos bots aquí (lazy loading)
    // Se cargarán cuando se llame a ensureInitialized()
  }

  /// Carga los bots al abrir el demo: primero desde Supabase (demo_bots);
  /// si hay datos se sincronizan a local. Si remoto falla o está vacío, se usa local.
  /// Así los bots persisten al cerrar y volver a abrir la web.
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    _isInitialized = true;

    try {
      final bots = await _loadBotsUseCase.executePreferRemote();
      if (bots.isNotEmpty) {
        state = state.copyWith(bots: bots);
      }
    } catch (e) {
      LoggerService.error('Error cargando bots al iniciar demo', tag: 'DemoProvider', error: e);
      final localBots = _loadBotsUseCase.execute();
      if (localBots.isNotEmpty) {
        state = state.copyWith(bots: localBots);
      }
    }
  }

  /// Persiste los bots después de cada cambio usando el use case
  Future<void> _persistBots() async {
    try {
      final success = await _persistBotsUseCase.execute(state.bots);
      if (!success) {
        LoggerService.debug('Persistencia en curso, operación omitida', tag: 'DemoProvider');
      }
    } catch (e) {
      LoggerService.error('Error al persistir bots', tag: 'DemoProvider', error: e);
    }
  }

  /// Crea un nuevo bot delegando al use case.
  Future<void> createBot({
    required String name,
    required String prompt,
    required Color color,
  }) async {
    // Convertir Color de Flutter a BotColor del dominio
    final botColor = BotUIMapper.fromFlutterColor(color);
    state = state.copyWith(isCreating: true, error: null);

    try {
      final result = await _createBotUseCase.execute(
        name: name,
        prompt: prompt,
        color: botColor,
      );

      state = state.copyWith(
        bots: [...state.bots, result.bot],
        selectedBotId: result.bot.id,
        isCreating: false,
      );
      
      // Persistir cambios
      await _persistBots();
    } catch (e, stackTrace) {
      LoggerService.endOperationError('CREAR BOT EN PROVIDER', e, tag: 'DemoProvider', stackTrace: stackTrace);
      
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      
      // CRÍTICO: Relanzar la excepción para que la UI pueda capturarla
      rethrow;
    }
  }

  /// Selecciona un bot.
  void selectBot(String botId) {
    state = state.copyWith(selectedBotId: botId);
  }

  /// Envía un mensaje a un bot. Muestra el mensaje del usuario al instante y la respuesta del bot cuando llega.
  Future<void> sendMessage(String botId, String message) async {
    final botIndex = state.bots.indexWhere((b) => b.id == botId);
    if (botIndex == -1) return;

    final bot = state.bots[botIndex];

    // Mostrar el mensaje del usuario de inmediato (conversación fluida)
    final userMessage = DemoChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _updateBotSync(botIndex, bot.copyWith(
      messages: [...bot.messages, userMessage],
      isTyping: true,
    ));

    try {
      final result = await _sendMessageUseCase.execute(
        bot: bot,
        message: message,
      );

      final updatedBotIndex = state.bots.indexWhere((b) => b.id == botId);
      if (updatedBotIndex == -1) return;

      final currentBot = state.bots[updatedBotIndex];
      final updatedBot = currentBot.copyWith(
        messages: [...currentBot.messages, result.botResponse],
        isTyping: false,
        mood: result.mood,
      );

      await _updateBot(updatedBotIndex, updatedBot);
    } catch (e) {
      final errorBotIndex = state.bots.indexWhere((b) => b.id == botId);
      if (errorBotIndex == -1) return;

      final currentBot = state.bots[errorBotIndex];
      await _updateBot(errorBotIndex, currentBot.copyWith(isTyping: false));

      LoggerService.error('Error enviando mensaje', tag: 'DemoProvider', error: e);
    }
  }

  /// Actualiza un bot en la lista de forma síncrona (sin persistir).
  void _updateBotSync(int index, DemoBotEntity bot) {
    final bots = [...state.bots];
    bots[index] = bot;
    state = state.copyWith(bots: bots);
  }

  /// Actualiza un bot en la lista y persiste.
  Future<void> _updateBot(int index, DemoBotEntity bot) async {
    _updateBotSync(index, bot);
    await _persistBots();
  }

  /// Elimina un bot.
  Future<void> removeBot(String botId) async {
    await _deleteBotUseCase.execute(botId);
    
    state = state.copyWith(
      bots: state.bots.where((b) => b.id != botId).toList(),
      selectedBotId: state.selectedBotId == botId ? null : state.selectedBotId,
    );
    
    // Persistir cambios
    await _persistBots();
  }

  /// Limpia todos los bots.
  Future<void> clearAll() async {
    await _createBotUseCase.resetCounter();
    await _clearAllBotsUseCase.execute();
    state = const DemoState();
  }
}

/// Provider del notifier de demo.
final demoProvider = StateNotifierProvider<DemoNotifier, DemoState>((ref) {
  final createBotUseCase = ref.watch(createBotUseCaseProvider);
  final sendMessageUseCase = ref.watch(sendMessageUseCaseProvider);
  final loadBotsUseCase = ref.watch(loadBotsUseCaseProvider);
  final deleteBotUseCase = ref.watch(deleteBotUseCaseProvider);
  final clearAllBotsUseCase = ref.watch(clearAllBotsUseCaseProvider);
  final persistBotsUseCase = ref.watch(persistBotsUseCaseProvider);
  
  return DemoNotifier(
    createBotUseCase,
    sendMessageUseCase,
    loadBotsUseCase,
    deleteBotUseCase,
    clearAllBotsUseCase,
    persistBotsUseCase,
  );
});
