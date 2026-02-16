import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_repository_provider.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/entities/demo_chat_message.dart';
import '../../domain/repositories/i_demo_repository.dart';
import 'generate_response_use_case.dart';

/// Resultado de enviar un mensaje con mood del bot.
class SendMessageResult {
  final DemoChatMessage userMessage;
  final DemoChatMessage botResponse;
  final String mood;

  const SendMessageResult({
    required this.userMessage,
    required this.botResponse,
    required this.mood,
  });
}

/// Caso de uso para enviar un mensaje a un bot usando la edge function real.
/// Encapsula la lógica de:
/// - Creación del mensaje del usuario
/// - Obtención de respuesta del cerebro real (botlode-brain)
/// - Creación del mensaje de respuesta con mood
class SendMessageUseCase {
  final IDemoRepository _repository;
  final GenerateResponseUseCase _generateResponse;

  SendMessageUseCase(this._repository, this._generateResponse);

  /// Ejecuta el envío de un mensaje usando el cerebro real.
  Future<SendMessageResult> execute({
    required DemoBotEntity bot,
    required String message,
  }) async {
    // Crear mensaje del usuario
    final userMessage = DemoChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Obtener respuesta del cerebro real
    String responseContent;
    String mood = 'neutral';

    if (_repository.isAvailable) {
      final isTransientBot = bot.id == 'temp_id' || bot.id.startsWith('local_temp_');
      final effectiveBotId = isTransientBot ? 'temp_id' : bot.id;

      debugPrint('📤 Enviando mensaje al cerebro real...');
      debugPrint('   - Bot ID: $effectiveBotId (original: ${bot.id})');
      debugPrint('   - Session ID: ${bot.sessionId}');
      debugPrint('   - Chat ID: ${bot.chatId}');
      
      final remoteResponse = await _repository.sendMessage(
        botId: effectiveBotId,
        message: message,
        sessionId: bot.sessionId,
        chatId: bot.chatId,
        botName: isTransientBot ? bot.name : null,
        systemPrompt: isTransientBot ? bot.prompt : null,
      );
      
      if (remoteResponse != null) {
        debugPrint('✅ Respuesta recibida del cerebro real');
        responseContent = remoteResponse.message;
        mood = remoteResponse.mood;
      } else {
        debugPrint('⚠️ Sin respuesta del cerebro, usando fallback local');
        final localResult = _generateResponse.executeWithMood(bot, message);
        responseContent = localResult.message;
        mood = localResult.mood;
      }
    } else {
      debugPrint('⚠️ Repositorio no disponible, usando respuesta local');
      // Simular delay para respuesta local
      await Future.delayed(const Duration(milliseconds: 800));
      final localResult = _generateResponse.executeWithMood(bot, message);
      responseContent = localResult.message;
      mood = localResult.mood;
    }

    // Crear mensaje de respuesta del bot
    final botResponse = DemoChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_bot',
      content: responseContent,
      isUser: false,
      timestamp: DateTime.now(),
    );

    return SendMessageResult(
      userMessage: userMessage,
      botResponse: botResponse,
      mood: mood,
    );
  }
}

/// Provider del caso de uso de enviar mensaje.
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  final generateResponse = ref.watch(generateResponseUseCaseProvider);
  return SendMessageUseCase(repository, generateResponse);
});
