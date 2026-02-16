import 'package:url_launcher/url_launcher.dart';

/// Servicio para manejar interacciones con WhatsApp
class WhatsAppService {
  WhatsAppService._();

  /// Número de WhatsApp de contacto (sin espacios ni caracteres especiales)
  /// Formato: código de país + número (ej: 521234567890 para México)
  static const String _contactNumber = '5491234567890'; // Reemplazar con número real

  /// Abre WhatsApp con un mensaje predefinido
  /// [message] es el texto del mensaje a enviar
  /// [phoneNumber] es opcional, si no se proporciona usa el número por defecto
  static Future<bool> openWhatsApp({
    required String message,
    String? phoneNumber,
  }) async {
    final number = phoneNumber ?? _contactNumber;
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$number?text=$encodedMessage');
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Abre WhatsApp con un mensaje de consulta sobre ingresos
  /// [monthlyIncome] es el ingreso mensual calculado
  static Future<bool> openWhatsAppWithIncomeQuery(double monthlyIncome) async {
    final formattedIncome = monthlyIncome.toStringAsFixed(2);
    final message = '''
Hola! 👋

He calculado que podría generar \$$formattedIncome USD mensuales con BotLode.

Me gustaría conocer más sobre:
• Cómo empezar
• Casos de éxito
• Soporte y capacitación

¿Cuándo podríamos agendar una llamada?
''';
    
    return await openWhatsApp(message: message);
  }

  /// Abre WhatsApp con un mensaje de consulta general
  static Future<bool> openWhatsAppWithGeneralQuery() async {
    const message = '''
Hola! 👋

Estoy interesado en BotLode y me gustaría conocer más sobre:
• Funcionalidades
• Precios
• Casos de uso

¿Podríamos agendar una llamada?
''';
    
    return await openWhatsApp(message: message);
  }

  /// Abre WhatsApp con un mensaje personalizado de soporte
  static Future<bool> openWhatsAppForSupport(String issue) async {
    final message = '''
Hola! 👋

Necesito ayuda con: $issue

¿Podrían asistirme?
''';
    
    return await openWhatsApp(message: message);
  }
}
