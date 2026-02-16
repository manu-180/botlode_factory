import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la aplicación desde variables de entorno
class AppConfig {
  // -----------------------------------------------------------
  // 🔐 CREDENCIALES DE PRODUCCIÓN (HARDCODED como fallback)
  // -----------------------------------------------------------
  
  static const String _hardcodedUrl = "https://gfvslxtqmjrelrugrcfp.supabase.co";
  
  // Clave pública (Anon Key) - Es seguro exponerla (protegida por RLS)
  static const String _hardcodedKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmdnNseHRxbWpyZWxydWdyY2ZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0MzkwMjUsImV4cCI6MjA4NDAxNTAyNX0.sjGjwMXpdA6ztW4D61NViMnJPiI3fgKtt1vXGwLdZm0";

  // -----------------------------------------------------------
  
  // Nombre exacto del archivo Rive (gato completo)
  static const String riveFileName = "catbotlode.riv";

  /// URL de Supabase desde variables de entorno (con fallback hardcoded)
  static String get supabaseUrl {
    debugPrint('📋 AppConfig.supabaseUrl - Obteniendo URL...');
    
    try {
      final envUrl = dotenv.env['SUPABASE_URL'];
      debugPrint('   - dotenv.env[SUPABASE_URL]: ${envUrl == null ? "null" : (envUrl.isEmpty ? "(vacío)" : envUrl)}');
      
      // Verificar que no sea null NI vacío
      if (envUrl != null && envUrl.isNotEmpty) {
        debugPrint('   ✅ Usando URL de .env');
        return envUrl;
      }
    } catch (e) {
      debugPrint('   ⚠️ Error accediendo a dotenv: $e');
    }
    
    debugPrint('   ✅ Usando URL hardcodeada: $_hardcodedUrl');
    return _hardcodedUrl;
  }

  /// Anon Key de Supabase desde variables de entorno (con fallback hardcoded)
  static String get supabaseAnonKey {
    debugPrint('📋 AppConfig.supabaseAnonKey - Obteniendo Key...');
    
    try {
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];
      debugPrint('   - dotenv.env[SUPABASE_ANON_KEY]: ${envKey == null ? "null" : (envKey.isEmpty ? "(vacío)" : "${envKey.substring(0, 20)}...")}');
      
      // Verificar que no sea null NI vacío
      if (envKey != null && envKey.isNotEmpty) {
        debugPrint('   ✅ Usando Key de .env');
        return envKey;
      }
    } catch (e) {
      debugPrint('   ⚠️ Error accediendo a dotenv: $e');
    }
    
    debugPrint('   ✅ Usando Key hardcodeada: ${_hardcodedKey.substring(0, 20)}...');
    return _hardcodedKey;
  }

  /// URL de la Edge Function (EL CEREBRO)
  static String get brainFunctionUrl {
    final baseUrl = supabaseUrl;
    if (baseUrl.isEmpty) return '';
    final cleanUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    return '$cleanUrl/functions/v1/botlode-brain'; 
  }
}
