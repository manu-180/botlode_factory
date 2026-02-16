import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/demo_bot_entity.dart';

/// Resultado de generación local con mood.
class GenerateResponseResult {
  final String message;
  final String mood;

  const GenerateResponseResult({
    required this.message,
    required this.mood,
  });
}

/// Caso de uso para generar respuestas locales cuando no hay conexión con la edge function.
/// En ese caso el bot responde siempre con un mensaje de mantenimiento en primera persona.
class GenerateResponseUseCase {
  /// Mensaje único que muestra el bot cuando no hay conexión con el cerebro (edge function).
  /// El bot habla en primera persona.
  static const String maintenanceMessage =
      '¡Perdón! Estoy en mantenimiento, Manu está desarrollando mejoras para mí. '
      'Volveré en seguida. 🙌';

  /// Detecta el mood basándose en palabras clave del mensaje del usuario.
  String _detectMood(String userMessage) {
    final messageLower = userMessage.toLowerCase();

    // Palabras que indican enojo
    if (messageLower.contains('mal') || 
        messageLower.contains('error') || 
        messageLower.contains('problema') ||
        messageLower.contains('enojado') ||
        messageLower.contains('molesto') ||
        messageLower.contains('queja')) {
      return 'angry';
    }

    // Palabras que indican felicidad
    if (messageLower.contains('gracias') || 
        messageLower.contains('excelente') || 
        messageLower.contains('perfecto') ||
        messageLower.contains('genial') ||
        messageLower.contains('feliz') ||
        messageLower.contains('contento')) {
      return 'happy';
    }

    // Palabras que indican venta/comercial
    if (messageLower.contains('precio') || 
        messageLower.contains('comprar') || 
        messageLower.contains('vender') ||
        messageLower.contains('producto') ||
        messageLower.contains('servicio') ||
        messageLower.contains('costo')) {
      return 'sales';
    }

    // Palabras que indican confusión
    if (messageLower.contains('no entiendo') || 
        messageLower.contains('confundido') || 
        messageLower.contains('qué') ||
        messageLower.contains('cómo') ||
        messageLower.contains('por qué') ||
        messageLower.contains('ayuda')) {
      return 'confused';
    }

    // Palabras técnicas
    if (messageLower.contains('técnico') || 
        messageLower.contains('api') || 
        messageLower.contains('código') ||
        messageLower.contains('error') ||
        messageLower.contains('bug') ||
        messageLower.contains('configuración')) {
      return 'tech';
    }

    // Por defecto neutral
    return 'neutral';
  }

  /// Cuando no hay conexión con la edge function, el bot siempre responde con el mensaje de mantenimiento.
  String execute(DemoBotEntity bot, String userMessage) {
    return maintenanceMessage;
  }

  /// Ejecuta la generación con detección de mood.
  GenerateResponseResult executeWithMood(DemoBotEntity bot, String userMessage) {
    final message = execute(bot, userMessage);
    final mood = _detectMood(userMessage);
    
    return GenerateResponseResult(
      message: message,
      mood: mood,
    );
  }
}

/// Provider del caso de uso de generar respuesta.
final generateResponseUseCaseProvider = Provider<GenerateResponseUseCase>((ref) {
  return GenerateResponseUseCase();
});
