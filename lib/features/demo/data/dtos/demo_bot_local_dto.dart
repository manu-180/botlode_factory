import 'package:flutter/material.dart';

import '../../domain/entities/demo_bot_entity.dart';
import '../models/demo_bot_model.dart';
import '../models/demo_chat_message_model.dart';

/// DTO para serialización/deserialización con SharedPreferences.
/// Maneja la conversión entre JSON local y el modelo de datos.
class DemoBotLocalDTO {
  final String id;
  final String name;
  final String prompt;
  final int colorValue;
  final String createdAt;
  final List<Map<String, dynamic>> messages;
  final bool isTyping;

  const DemoBotLocalDTO({
    required this.id,
    required this.name,
    required this.prompt,
    required this.colorValue,
    required this.createdAt,
    required this.messages,
    required this.isTyping,
  });

  /// Crea un DTO desde JSON local.
  factory DemoBotLocalDTO.fromJson(Map<String, dynamic> json) {
    return DemoBotLocalDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      prompt: json['prompt'] as String,
      colorValue: json['color'] as int,
      createdAt: json['createdAt'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => m as Map<String, dynamic>)
          .toList(),
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }

  /// Convierte el DTO a JSON local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'color': colorValue,
      'createdAt': createdAt,
      'messages': messages,
      'isTyping': isTyping,
    };
  }

  /// Convierte el DTO a un modelo de datos.
  DemoBotModel toModel() {
    return DemoBotModel(
      id: id,
      name: name,
      prompt: prompt,
      color: Color(colorValue),
      createdAt: DateTime.parse(createdAt),
      messages: messages
          .map((m) => DemoChatMessageModel.fromJson(m).toEntity())
          .toList(),
      isTyping: isTyping,
    );
  }

  /// Crea un DTO desde un modelo de datos.
  factory DemoBotLocalDTO.fromModel(DemoBotModel model) {
    return DemoBotLocalDTO(
      id: model.id,
      name: model.name,
      prompt: model.prompt,
      colorValue: model.color.value,
      createdAt: model.createdAt.toIso8601String(),
      messages: model.messages
          .map((m) => DemoChatMessageModel.fromEntity(m).toJson())
          .toList(),
      isTyping: model.isTyping,
    );
  }

  /// Crea un DTO desde una entidad de dominio.
  factory DemoBotLocalDTO.fromEntity(DemoBotEntity entity) {
    return DemoBotLocalDTO(
      id: entity.id,
      name: entity.name,
      prompt: entity.prompt,
      colorValue: entity.color.value,
      createdAt: entity.createdAt.toIso8601String(),
      messages: entity.messages
          .map((m) => DemoChatMessageModel.fromEntity(m).toJson())
          .toList(),
      isTyping: entity.isTyping,
    );
  }
}
