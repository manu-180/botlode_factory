import 'package:flutter/material.dart';

/// Entidad de dominio para un video tutorial.
class TutorialVideo {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String category;
  final IconData thumbnail;
  final String? thumbnailImage; // Ruta a imagen de miniatura estática
  final bool isAvailable;
  final String? videoUrl; // URL principal del video
  final String? videoUrl2; // URL secundaria para videos duales (historial)
  final bool isDualVideo; // Si es un video dual (2 videos simultáneos)

  const TutorialVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.thumbnail,
    this.thumbnailImage,
    required this.isAvailable,
    this.videoUrl,
    this.videoUrl2,
    this.isDualVideo = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Entidad de dominio para una categoría de tutorial.
class TutorialCategory {
  final String id;
  final String label;
  final IconData icon;

  const TutorialCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
