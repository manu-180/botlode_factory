import 'package:flutter/material.dart';

import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/entities/demo_chat_message.dart';
import '../../domain/value_objects/bot_color.dart';
import 'demo_chat_message_model.dart';

/// Modelo de datos (DTO) para un bot de demo.
/// Contiene la lógica de serialización para comunicarse con Supabase y almacenamiento local.
class DemoBotModel {
  final String id;
  final String name;
  final String prompt;
  final Color color;
  final DateTime createdAt;
  final List<DemoChatMessage> messages;
  final bool isTyping;
  final String mood;
  final String sessionId;
  final String chatId;

  const DemoBotModel({
    required this.id,
    required this.name,
    required this.prompt,
    required this.color,
    required this.createdAt,
    this.messages = const [],
    this.isTyping = false,
    this.mood = 'neutral',
    this.sessionId = '',
    this.chatId = '',
  });

  /// Crea un modelo desde un mapa de Supabase.
  factory DemoBotModel.fromMap(Map<String, dynamic> map) {
    return DemoBotModel(
      id: map['id'] as String,
      name: map['name'] as String,
      prompt: map['prompt'] as String? ?? '',
      color: Color(int.parse((map['color'] as String).replaceFirst('#', '0xFF'))),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Crea un modelo desde una entidad de dominio.
  factory DemoBotModel.fromEntity(DemoBotEntity entity) {
    return DemoBotModel(
      id: entity.id,
      name: entity.name,
      prompt: entity.prompt,
      color: Color(entity.color.value), // Convertir BotColor a Color
      createdAt: entity.createdAt,
      messages: entity.messages,
      isTyping: entity.isTyping,
      mood: entity.mood,
      sessionId: entity.sessionId,
      chatId: entity.chatId,
    );
  }

  /// Convierte el modelo a un mapa para Supabase.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'prompt': prompt,
      'color': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
    };
  }

  /// Convierte el modelo a una entidad de dominio.
  DemoBotEntity toEntity() {
    return DemoBotEntity(
      id: id,
      name: name,
      prompt: prompt,
      color: BotColor(color.value), // Convertir Color a BotColor
      createdAt: createdAt,
      messages: messages,
      isTyping: isTyping,
      mood: mood,
      sessionId: sessionId,
      chatId: chatId,
    );
  }

  DemoBotModel copyWith({
    String? id,
    String? name,
    String? prompt,
    Color? color,
    DateTime? createdAt,
    List<DemoChatMessage>? messages,
    bool? isTyping,
    String? mood,
    String? sessionId,
    String? chatId,
  }) {
    return DemoBotModel(
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

  /// Serializa a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages.map((m) => DemoChatMessageModel.fromEntity(m).toJson()).toList(),
      'isTyping': isTyping,
      'mood': mood,
      'sessionId': sessionId,
      'chatId': chatId,
    };
  }

  /// Deserializa desde JSON para almacenamiento local
  factory DemoBotModel.fromJson(Map<String, dynamic> json) {
    return DemoBotModel(
      id: json['id'] as String,
      name: json['name'] as String,
      prompt: json['prompt'] as String,
      color: Color(json['color'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => DemoChatMessageModel.fromJson(m as Map<String, dynamic>).toEntity())
          .toList(),
      isTyping: json['isTyping'] as bool? ?? false,
      mood: json['mood'] as String? ?? 'neutral',
      sessionId: json['sessionId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
    );
  }
}
