import 'package:flutter/foundation.dart';

/// Servicio centralizado de logging
class LoggerService {
  LoggerService._();

  /// Niveles de log
  static const String _levelDebug = '🔍 DEBUG';
  static const String _levelInfo = 'ℹ️  INFO';
  static const String _levelWarning = '⚠️  WARNING';
  static const String _levelError = '❌ ERROR';
  static const String _levelSuccess = '✅ SUCCESS';

  /// Log de depuración
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _log(_levelDebug, message, tag: tag);
    }
  }

  /// Log informativo
  static void info(String message, {String? tag}) {
    _log(_levelInfo, message, tag: tag);
  }

  /// Log de advertencia
  static void warning(String message, {String? tag, Object? error}) {
    _log(_levelWarning, message, tag: tag, error: error);
  }

  /// Log de error
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_levelError, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log de éxito
  static void success(String message, {String? tag}) {
    _log(_levelSuccess, message, tag: tag);
  }

  /// Método interno para formatear y mostrar logs
  static void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final tagString = tag != null ? '[$tag]' : '';
    
    debugPrint('$timestamp $level $tagString $message');
    
    if (error != null) {
      debugPrint('   Error: $error');
    }
    
    if (stackTrace != null) {
      debugPrint('   Stack trace:');
      debugPrint('$stackTrace');
    }
  }

  /// Log formateado para inicio de operaciones
  static void startOperation(String operation, {String? tag}) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════');
      debug('INICIO: $operation', tag: tag);
      debugPrint('═══════════════════════════════════════════════════');
    }
  }

  /// Log formateado para fin de operaciones exitosas
  static void endOperationSuccess(String operation, {String? tag}) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('✅✅✅ $operation COMPLETADO ✅✅✅');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('');
    }
  }

  /// Log formateado para fin de operaciones con error
  static void endOperationError(String operation, Object error, {String? tag, StackTrace? stackTrace}) {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('❌ ERROR EN: $operation');
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('Error: $error');
    
    if (stackTrace != null) {
      debugPrint('');
      debugPrint('Stack Trace:');
      debugPrint('$stackTrace');
    }
    
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('');
  }
}
