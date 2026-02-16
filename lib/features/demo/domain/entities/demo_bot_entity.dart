import 'package:uuid/uuid.dart';

import '../value_objects/bot_color.dart';
import 'demo_chat_message.dart';

const _uuid = Uuid();

/// Entidad de dominio pura para un bot de demo.
/// No contiene lógica de serialización - eso pertenece a la capa de datos.
/// Sin dependencias de Flutter para mantener el dominio puro.
class DemoBotEntity {
  final String id;
  final String name;
  final String prompt;
  final BotColor color;
  final DateTime createdAt;
  final List<DemoChatMessage> messages;
  final bool isTyping;
  final String mood; // Modo de personalidad del bot (neutral, happy, angry, tech, etc.)
  
  // IDs para la edge function botlode-brain
  final String sessionId; // ID de sesión único por bot
  final String chatId;    // ID de chat persistente por bot

  const DemoBotEntity({
    required this.id,
    required this.name,
    required this.prompt,
    required this.color,
    required this.createdAt,
    this.messages = const [],
    this.isTyping = false,
    this.mood = 'neutral',
    String? sessionId,
    String? chatId,
  }) : sessionId = sessionId ?? '',
       chatId = chatId ?? '';

  /// Crea un bot con IDs de sesión y chat generados automáticamente
  factory DemoBotEntity.withGeneratedIds({
    required String id,
    required String name,
    required String prompt,
    required BotColor color,
    required DateTime createdAt,
    List<DemoChatMessage> messages = const [],
    bool isTyping = false,
    String mood = 'neutral',
  }) {
    return DemoBotEntity(
      id: id,
      name: name,
      prompt: prompt,
      color: color,
      createdAt: createdAt,
      messages: messages,
      isTyping: isTyping,
      mood: mood,
      sessionId: _uuid.v4(),
      chatId: _uuid.v4(),
    );
  }

  DemoBotEntity copyWith({
    String? id,
    String? name,
    String? prompt,
    BotColor? color,
    DateTime? createdAt,
    List<DemoChatMessage>? messages,
    bool? isTyping,
    String? mood,
    String? sessionId,
    String? chatId,
  }) {
    return DemoBotEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      mood: mood ?? this.mood,
      sessionId: sessionId ?? this.sessionId,
      chatId: chatId ?? this.chatId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemoBotEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
