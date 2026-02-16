import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/logger_service.dart';

/// Resultado de la inicialización de la app
class AppInitializationResult {
  final bool riveLoaded;
  final bool supabaseConnected;
  final bool videosLoaded;
  final Duration initializationTime;

  const AppInitializationResult({
    required this.riveLoaded,
    required this.supabaseConnected,
    required this.videosLoaded,
    required this.initializationTime,
  });

  bool get isFullyInitialized => riveLoaded && supabaseConnected && videosLoaded;
  bool get canWork => riveLoaded && videosLoaded; // La app necesita Rive y videos
}

/// Caso de uso para inicializar la aplicación
/// Encapsula la lógica de inicialización de recursos (Rive, Supabase, Videos)
class InitializeAppUseCase {
  /// Ejecuta la inicialización de la app
  /// Retorna un resultado con el estado de cada recurso
  /// [initSharedPreferences] opcional: precarga SharedPreferences para persistencia local del Demo
  Future<AppInitializationResult> execute({
    required Future<void> Function() initRive,
    required Future<void> Function() initSupabase,
    required Future<void> Function() initVideos,
    Future<void> Function()? initSharedPreferences,
    Duration minSplashDuration = const Duration(milliseconds: 500),
  }) async {
    LoggerService.startOperation('INICIALIZACIÓN DE APP', tag: 'InitApp');
    
    final startTime = DateTime.now();
    
    // Inicializar recursos en paralelo
    bool riveLoaded = false;
    bool supabaseConnected = false;
    bool videosLoaded = false;

    final futures = [
      _initializeRive(initRive).then((success) => riveLoaded = success),
      _initializeSupabase(initSupabase).then((success) => supabaseConnected = success),
      _initializeVideos(initVideos).then((success) => videosLoaded = success),
    ];
    if (initSharedPreferences != null) {
      futures.add(_initializeSharedPreferences(initSharedPreferences));
    }
    await Future.wait(futures);

    // Calcular tiempo de inicialización
    final elapsedTime = DateTime.now().difference(startTime);

    // Asegurar duración mínima del splash
    if (elapsedTime < minSplashDuration) {
      final remainingTime = minSplashDuration - elapsedTime;
      await Future.delayed(remainingTime);
    }

    final totalTime = DateTime.now().difference(startTime);

    LoggerService.info(
      'Inicialización completada en ${totalTime.inMilliseconds}ms',
      tag: 'InitApp',
    );
    LoggerService.success(
      'Rive: ${riveLoaded ? "✓" : "✗"} | Supabase: ${supabaseConnected ? "✓" : "✗"} | Videos: ${videosLoaded ? "✓" : "✗"}',
      tag: 'InitApp',
    );

    return AppInitializationResult(
      riveLoaded: riveLoaded,
      supabaseConnected: supabaseConnected,
      videosLoaded: videosLoaded,
      initializationTime: totalTime,
    );
  }

  /// Inicializa Rive
  Future<bool> _initializeRive(Future<void> Function() initFn) async {
    try {
      await initFn();
      LoggerService.success('Rive cargado correctamente', tag: 'InitApp');
      return true;
    } catch (e) {
      LoggerService.warning('Error al cargar Rive', tag: 'InitApp', error: e);
      return false;
    }
  }

  /// Inicializa Supabase
  Future<bool> _initializeSupabase(Future<void> Function() initFn) async {
    try {
      await initFn();
      LoggerService.success('Supabase conectado correctamente', tag: 'InitApp');
      return true;
    } catch (e) {
      LoggerService.warning('Supabase no disponible (modo offline)', tag: 'InitApp', error: e);
      return false;
    }
  }

  /// Inicializa videos
  Future<bool> _initializeVideos(Future<void> Function() initFn) async {
    try {
      await initFn();
      LoggerService.success('Videos pre-cargados correctamente', tag: 'InitApp');
      return true;
    } catch (e) {
      LoggerService.warning('Error al pre-cargar videos', tag: 'InitApp', error: e);
      return false;
    }
  }

  /// Inicializa SharedPreferences para persistencia local del Demo
  Future<bool> _initializeSharedPreferences(Future<void> Function() initFn) async {
    try {
      await initFn();
      LoggerService.success('SharedPreferences listo (persistencia Demo)', tag: 'InitApp');
      return true;
    } catch (e) {
      LoggerService.warning('SharedPreferences no disponible', tag: 'InitApp', error: e);
      return false;
    }
  }
}

/// Provider del caso de uso de inicialización
final initializeAppUseCaseProvider = Provider<InitializeAppUseCase>((ref) {
  return InitializeAppUseCase();
});
