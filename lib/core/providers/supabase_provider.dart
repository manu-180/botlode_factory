import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_constants.dart';

/// Provider que indica si Supabase está disponible
final supabaseAvailableProvider = Provider<bool>((ref) {
  debugPrint('🔍 ═══════════════════════════════════════════════════');
  debugPrint('🔍 VERIFICANDO DISPONIBILIDAD DE SUPABASE');
  debugPrint('🔍 ═══════════════════════════════════════════════════');
  
  final url = AppConstants.supabaseUrl;
  final key = AppConstants.supabaseAnonKey;
  
  debugPrint('🔍 URL obtenida de AppConstants:');
  debugPrint('   - Longitud: ${url.length} caracteres');
  debugPrint('   - Valor: ${url.isEmpty ? "(VACÍA)" : url}');
  
  debugPrint('🔍 Key obtenida de AppConstants:');
  debugPrint('   - Longitud: ${key.length} caracteres');
  debugPrint('   - Valor: ${key.isEmpty ? "(VACÍA)" : "${key.substring(0, 30)}..."}');
  
  final available = url.isNotEmpty && key.isNotEmpty;
  
  if (available) {
    debugPrint('✅ SUPABASE DISPONIBLE: SÍ');
  } else {
    debugPrint('❌ SUPABASE DISPONIBLE: NO');
    if (url.isEmpty) debugPrint('   ⚠️ URL está vacía');
    if (key.isEmpty) debugPrint('   ⚠️ KEY está vacía');
  }
  
  debugPrint('🔍 ═══════════════════════════════════════════════════');
  
  return available;
});

/// Provider que inicializa Supabase de forma lazy (solo cuando se necesita)
/// Esta inicialización NO bloquea el arranque de la app
final supabaseInitializationProvider = FutureProvider<void>((ref) async {
  final isAvailable = ref.watch(supabaseAvailableProvider);
  
  if (!isAvailable) {
    debugPrint('⚠️ Supabase NO está disponible (credenciales vacías)');
    return;
  }
  
  try {
    // Verificar si ya está inicializado
    try {
      Supabase.instance.client;
      debugPrint('✅ Supabase ya estaba inicializado');
      return;
    } catch (_) {
      // No está inicializado, continuar con la inicialización
    }
    
    debugPrint('🔵 Inicializando Supabase en background...');
    debugPrint('   - URL: ${AppConstants.supabaseUrl}');
    debugPrint('   - Key: ${AppConstants.supabaseAnonKey.substring(0, 20)}...');
    
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    
    debugPrint('✅ Supabase inicializado correctamente');
    
    final client = Supabase.instance.client;
    debugPrint('✅ Cliente de Supabase obtenido: ${client.toString()}');
    
    // Autenticación anónima: identifica cada dispositivo sin login visible
    await _ensureAnonymousSession(client);
  } catch (error, stackTrace) {
    debugPrint('❌ Error inicializando Supabase: $error');
    debugPrint('❌ Stack trace: $stackTrace');
    // No rethrow - permitir que la app funcione sin Supabase
  }
});

/// Garantiza que exista una sesión anónima para el Demo (TUS BOTS por dispositivo).
/// Cada navegador obtiene un auth.uid() único; RLS filtra bots por ese uid.
/// Si el proveedor anónimo está deshabilitado en Supabase, la app sigue sin sesión
/// y el Demo usará solo persistencia local (SharedPreferences).
Future<void> _ensureAnonymousSession(SupabaseClient client) async {
  try {
    final session = client.auth.currentSession;
    if (session != null) {
      debugPrint('✅ Sesión anónima ya activa: ${session.user.id}');
      return;
    }
    await client.auth.signInAnonymously();
    final newSession = client.auth.currentSession;
    if (newSession != null) {
      debugPrint('✅ Sesión anónima creada: ${newSession.user.id}');
    } else {
      debugPrint('⚠️ No se pudo crear sesión anónima');
    }
  } on AuthException catch (e) {
    final isAnonymousDisabled = e.code == 'anonymous_provider_disabled' ||
        (e.message.toLowerCase().contains('anonymous') && e.message.toLowerCase().contains('disabled'));
    if (isAnonymousDisabled) {
      debugPrint('ℹ️ Inicio anónimo deshabilitado en Supabase. Demo usará solo almacenamiento local.');
      debugPrint('   Para sincronizar "TUS BOTS" entre dispositivos: Supabase → Authentication → Providers → habilita "Anonymous".');
    } else {
      debugPrint('⚠️ Error en signInAnonymously: $e');
    }
    // No bloqueamos la app; el demo puede usar SharedPreferences como fallback
  } catch (e) {
    debugPrint('⚠️ Error en signInAnonymously: $e');
    // No bloqueamos la app; el demo puede usar SharedPreferences como fallback
  }
}

/// Provider del cliente de Supabase
/// Espera a que Supabase esté inicializado antes de retornar el cliente
final supabaseClientProvider = FutureProvider<SupabaseClient?>((ref) async {
  debugPrint('🔍 supabaseClientProvider: Iniciando obtención de cliente...');
  
  // Esperar a que la inicialización termine
  try {
    await ref.watch(supabaseInitializationProvider.future);
    debugPrint('🔍 supabaseClientProvider: Inicialización completada');
  } catch (e) {
    debugPrint('❌ supabaseClientProvider: Error en inicialización: $e');
    return null;
  }
  
  final isAvailable = ref.watch(supabaseAvailableProvider);
  debugPrint('🔍 supabaseClientProvider: isAvailable = $isAvailable');
  
  if (!isAvailable) {
    debugPrint('⚠️ Supabase NO está disponible (credenciales vacías)');
    return null;
  }
  
  try {
    final client = Supabase.instance.client;
    debugPrint('✅ Cliente de Supabase obtenido correctamente: ${client.toString()}');
    return client;
  } catch (e, stackTrace) {
    debugPrint('❌ Error obteniendo cliente de Supabase: $e');
    debugPrint('❌ Stack trace: $stackTrace');
    return null;
  }
});
