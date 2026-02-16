import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/use_cases/generate_response_use_case.dart';
import '../dtos/demo_bot_supabase_dto.dart';
import '../models/demo_bot_model.dart';

/// Respuesta del bot con cerebro real
class BotBrainResponse {
  final String reply;
  final String mood;

  const BotBrainResponse({
    required this.reply,
    required this.mood,
  });

  factory BotBrainResponse.fromJson(Map<String, dynamic> json) {
    return BotBrainResponse(
      reply: json['reply'] ?? GenerateResponseUseCase.maintenanceMessage,
      mood: json['mood'] ?? "neutral",
    );
  }
}

/// Data source remoto para operaciones con Supabase.
/// Abstrae el acceso a Supabase del repositorio.
abstract class IDemoRemoteDataSource {
  /// Crea un bot en Supabase.
  Future<DemoBotModel?> createBot(DemoBotModel bot);

  /// Envía un mensaje al bot a través de la edge function real (botlode-brain).
  /// Si [botId] es 'temp_id', pasar [botName] y [systemPrompt] para que la edge function use la config sin consultar DB.
  Future<BotBrainResponse?> sendMessage({
    required String botId,
    required String message,
    required String sessionId,
    required String chatId,
    String? botName,
    String? systemPrompt,
  });

  /// Elimina un bot de Supabase.
  Future<bool> deleteBot(String botId);

  /// Obtiene todos los bots desde Supabase.
  Future<List<DemoBotModel>> getBots();

  /// Obtiene un bot por su ID desde Supabase.
  Future<DemoBotModel?> getBotById(String id);

  /// Indica si el servicio remoto está disponible.
  bool get isAvailable;
  
  /// Indica si el servicio está inicializándose.
  bool get isLoading => false;
}

/// Implementación del data source remoto usando Supabase.
/// Usa DTOs específicos para Supabase para serialización/deserialización.
class DemoRemoteDataSource implements IDemoRemoteDataSource {
  final SupabaseClient? _client;

  DemoRemoteDataSource(this._client) {
    debugPrint('📦 DemoRemoteDataSource inicializado');
    debugPrint('   - Cliente disponible: ${_client != null}');
  }

  @override
  bool get isAvailable {
    final available = _client != null;
    if (!available) {
      debugPrint('⚠️ DemoRemoteDataSource.isAvailable = false (cliente nulo)');
    }
    return available;
  }
  
  @override
  bool get isLoading => false;

  @override
  Future<DemoBotModel?> createBot(DemoBotModel bot) async {
    if (_client == null) {
      debugPrint('❌ Cliente de Supabase es NULL - no se puede crear bot');
      return null;
    }

    try {
      debugPrint('🤖 Creando bot en tabla "demo_bots" de Supabase:');
      debugPrint('   - Nombre: ${bot.name}');
      debugPrint('   - Prompt: ${bot.prompt}');
      debugPrint('   - SessionId: ${bot.sessionId}');
      debugPrint('   - ChatId: ${bot.chatId}');
      
      // Crear el bot en la tabla "demo_bots" (estructura simplificada)
      final hexColor = '#${bot.color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
      
      // user_id: auth.uid() del usuario anónimo (un id por dispositivo)
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No hay sesión anónima; el trigger asignará user_id si existe');
      }
      
      final botData = {
        if (userId != null) 'user_id': userId,
        'name': bot.name,
        'system_prompt': bot.prompt,
        'tech_color': hexColor,
        'session_id': bot.sessionId,
        'chat_id': bot.chatId,
      };
      
      debugPrint('📤 Insertando bot en demo_bots...');
      debugPrint('   - Datos: $botData');
      
      final response = await _client
          .from('demo_bots')
          .insert(botData)
          .select()
          .single();

      debugPrint('✅ Bot insertado exitosamente!');
      debugPrint('   - ID recibido: ${response['id']}');
      debugPrint('   - Respuesta completa: $response');
      
      // Retornar el modelo con el ID real de Supabase
      final createdBot = DemoBotModel(
        id: response['id'] as String,
        name: bot.name,
        prompt: bot.prompt,
        color: bot.color,
        createdAt: DateTime.parse(response['created_at'] as String),
        sessionId: bot.sessionId,
        chatId: bot.chatId,
      );
      
      debugPrint('✅ Modelo creado con ID: ${createdBot.id}');
      return createdBot;
      
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('❌ ERROR CRÍTICO CREANDO BOT EN SUPABASE');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('Error: $e');
      debugPrint('Tipo: ${e.runtimeType}');
      debugPrint('');
      debugPrint('Stack Trace:');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('');
      return null;
    }
  }

  @override
  Future<BotBrainResponse?> sendMessage({
    required String botId,
    required String message,
    required String sessionId,
    required String chatId,
    String? botName,
    String? systemPrompt,
  }) async {
    if (_client == null) {
      debugPrint('❌ Cliente de Supabase no disponible');
      return null;
    }

    try {
      debugPrint('🚀 Enviando mensaje a botlode-brain:');
      debugPrint('   - botId: $botId');
      debugPrint('   - sessionId: $sessionId');
      debugPrint('   - chatId: $chatId');
      debugPrint('   - message: $message');
      if (botId == 'temp_id') {
        debugPrint('   - temp_id: enviando name y system_prompt en body');
      }

      // Body: si botId es temp_id, la edge function requiere name y system_prompt en el body
      final body = <String, dynamic>{
        'sessionId': sessionId,
        'chatId': chatId,
        'botId': botId,
        'message': message,
      };
      if (botName != null && systemPrompt != null) {
        body['name'] = botName;
        body['system_prompt'] = systemPrompt;
      }

      final response = await _client.functions.invoke(
        'botlode-brain',
        body: body,
      );

      debugPrint('📡 Respuesta recibida:');
      debugPrint('   - Status: ${response.status}');
      debugPrint('   - Data: ${response.data}');

      // Verificar respuesta de forma segura
      if (response.status == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final brainResponse = BotBrainResponse.fromJson(data);
          debugPrint('✅ Respuesta del cerebro:');
          debugPrint('   - reply: ${brainResponse.reply}');
          debugPrint('   - mood: ${brainResponse.mood}');
          return brainResponse;
        }
      }
      
      debugPrint('⚠️ Respuesta inesperada - Status: ${response.status}');
      return null;
    } on FunctionException catch (e) {
      debugPrint('❌ Error de Supabase Function:');
      debugPrint('   - Reason: ${e.reasonPhrase}');
      debugPrint('   - Details: ${e.details}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al enviar mensaje a botlode-brain:');
      debugPrint('   - Error: $e');
      debugPrint('   - Stack: $stackTrace');
      return null;
    }
  }

  @override
  Future<bool> deleteBot(String botId) async {
    if (_client == null) return false;

    try {
      debugPrint('🗑️ Eliminando bot de demo_bots: $botId');
      await _client.from('demo_bots').delete().eq('id', botId);
      debugPrint('✅ Bot eliminado exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando bot de demo_bots: $e');
      return false;
    }
  }

  @override
  Future<List<DemoBotModel>> getBots() async {
    if (_client == null) return [];

    try {
      debugPrint('📋 Obteniendo bots de demo_bots...');
      final response = await _client
          .from('demo_bots')
          .select()
          .order('created_at', ascending: false);

      final bots = (response as List)
          .map((json) => DemoBotSupabaseDTO.fromMap(json).toModel())
          .toList();
      
      debugPrint('✅ ${bots.length} bots obtenidos de demo_bots');
      return bots;
    } catch (e) {
      debugPrint('❌ Error obteniendo bots de demo_bots: $e');
      return [];
    }
  }

  @override
  Future<DemoBotModel?> getBotById(String id) async {
    if (_client == null) return null;

    try {
      debugPrint('🔍 Buscando bot en demo_bots: $id');
      final response = await _client
          .from('demo_bots')
          .select()
          .eq('id', id)
          .single();

      debugPrint('✅ Bot encontrado en demo_bots');
      return DemoBotSupabaseDTO.fromMap(response).toModel();
    } catch (e) {
      debugPrint('❌ Error buscando bot en demo_bots: $e');
      return null;
    }
  }
}
