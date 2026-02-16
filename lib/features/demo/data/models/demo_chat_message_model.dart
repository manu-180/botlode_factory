import '../../domain/entities/demo_chat_message.dart';

/// Modelo de datos para mensajes de chat con capacidad de serialización.
class DemoChatMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const DemoChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  /// Crea un modelo desde una entidad de dominio
  factory DemoChatMessageModel.fromEntity(DemoChatMessage entity) {
    return DemoChatMessageModel(
      id: entity.id,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }

  /// Convierte a entidad de dominio
  DemoChatMessage toEntity() {
    return DemoChatMessage(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
    );
  }

  /// Serializa a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Deserializa desde JSON
  factory DemoChatMessageModel.fromJson(Map<String, dynamic> json) {
    return DemoChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
