import 'package:flutter/material.dart';

import '../domain/entities/tutorial_video.dart';

/// Datos estáticos de videos tutoriales.
class TutorialVideosData {
  TutorialVideosData._();

  /// Lista de categorías disponibles (simplificada a 2 categorías).
  static const List<TutorialCategory> categories = [
    TutorialCategory(id: 'todos', label: 'Todos', icon: Icons.grid_view),
    TutorialCategory(id: 'configuracion', label: 'Configuración', icon: Icons.settings),
  ];

  /// Lista completa de videos (solo 2 videos de la fábrica).
  static const List<TutorialVideo> videos = [
    // Video 1: Crear Bot
    TutorialVideo(
      id: 'video_crear_bot',
      title: 'Crea Tu Bot en 3 Pasos',
      description: 'Del concepto a la realidad: diseña tu asistente inteligente sin escribir código',
      duration: '1:45',
      category: 'configuracion',
      thumbnail: Icons.rocket_launch,
      // thumbnailImage: 'assets/images/thumbnails/crear_bot_thumb.jpg', // Desactivado para mostrar primer frame
      isAvailable: true,
      videoUrl: 'assets/videos/crearbot.mp4',
      isDualVideo: false
    ),
    
    // Video 2: Código/Integración
    TutorialVideo(
      id: 'video_codigo_bot',
      title: 'Integración en Tu Sitio Web',
      description: 'Copia, pega y despliega: tu bot en producción en 3 clicks',
      duration: '1:30',
      category: 'configuracion',
      thumbnail: Icons.code,
      // thumbnailImage: 'assets/images/thumbnails/codigo_bot_thumb.jpg', // Desactivado para mostrar primer frame
      isAvailable: true,
      videoUrl: 'assets/videos/codigodelbot.mp4',
      isDualVideo: false,
    ),

    // Video 3: Historial (dual sincronizado — mismo que en botlode_web)
    TutorialVideo(
      id: 'video_historial_dual',
      title: 'Historial del Bot',
      description: 'Vista dual sincronizada: pantalla del bot y vista del historial en tiempo real.',
      duration: '1:00',
      category: 'configuracion',
      thumbnail: Icons.history,
      isAvailable: true,
      videoUrl: 'assets/videos/historialbot1.mp4',
      videoUrl2: 'assets/videos/historialbot2.mp4',
      isDualVideo: true,
    ),
  ];
}
