import 'package:flutter/material.dart';

import '../../domain/entities/demo_bot_entity.dart';
import '../models/demo_bot_model.dart';

/// DTO para serialización/deserialización con Supabase.
/// Maneja la conversión entre el formato de Supabase y el modelo de datos.
class DemoBotSupabaseDTO {
  final String id;
  final String name;
  final String prompt;
  final String color;
  final String createdAt;

  const DemoBotSupabaseDTO({
    required this.id,
    required this.name,
    required this.prompt,
    required this.color,
    required this.createdAt,
  });

  /// Crea un DTO desde un mapa de Supabase.
  /// Acepta columnas reales de la tabla (system_prompt, tech_color) o legacy (prompt, color).
  factory DemoBotSupabaseDTO.fromMap(Map<String, dynamic> map) {
    final prompt = map['system_prompt'] as String? ?? map['prompt'] as String? ?? '';
    final color = map['tech_color'] as String? ?? map['color'] as String? ?? '#888888';
    final createdAt = map['created_at'] as String? ?? DateTime.now().toIso8601String();
    return DemoBotSupabaseDTO(
      id: map['id'] as String,
      name: map['name'] as String,
      prompt: prompt,
      color: color.startsWith('#') ? color : '#$color',
      createdAt: createdAt,
    );
  }

  /// Convierte el DTO a un mapa para Supabase.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'prompt': prompt,
      'color': color,
    };
  }

  /// Convierte el DTO a un modelo de datos.
  DemoBotModel toModel() {
    return DemoBotModel(
      id: id,
      name: name,
      prompt: prompt,
      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Crea un DTO desde un modelo de datos.
  factory DemoBotSupabaseDTO.fromModel(DemoBotModel model) {
    return DemoBotSupabaseDTO(
      id: model.id,
      name: model.name,
      prompt: model.prompt,
      color: '#${model.color.value.toRadixString(16).substring(2).toUpperCase()}',
      createdAt: model.createdAt.toIso8601String(),
    );
  }

  /// Crea un DTO desde una entidad de dominio.
  factory DemoBotSupabaseDTO.fromEntity(DemoBotEntity entity) {
    return DemoBotSupabaseDTO(
      id: entity.id,
      name: entity.name,
      prompt: entity.prompt,
      color: '#${entity.color.value.toRadixString(16).substring(2).toUpperCase()}',
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
