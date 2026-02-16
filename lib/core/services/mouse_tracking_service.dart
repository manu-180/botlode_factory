import 'package:flutter/material.dart';

/// Servicio para calcular el tracking del mouse
/// Extrae la lógica de negocio del tracking fuera de los widgets
class MouseTrackingService {
  MouseTrackingService._();

  /// Resultado del cálculo de tracking
  static TrackingResult calculateTracking({
    required Offset? globalPointer,
    required Offset widgetCenter,
    double sensitivity = 600.0,
    double maxDistance = 1200.0,
  }) {
    // Si no hay puntero, volver al centro
    if (globalPointer == null) {
      return const TrackingResult(
        targetX: 50.0,
        targetY: 50.0,
        isTracking: false,
      );
    }

    // Calcular distancia del puntero al centro del widget
    final dx = globalPointer.dx - widgetCenter.dx;
    final dy = globalPointer.dy - widgetCenter.dy;
    final distance = (dx * dx + dy * dy).abs();

    // Si está muy lejos, no hacer tracking
    if (distance > maxDistance * maxDistance) {
      return const TrackingResult(
        targetX: 50.0,
        targetY: 50.0,
        isTracking: false,
      );
    }

    // Calcular el offset normalizado (-1 a 1)
    final normalizedX = (dx / sensitivity).clamp(-1.0, 1.0);
    final normalizedY = (dy / sensitivity).clamp(-1.0, 1.0);

    // Convertir a rango 0-100 (formato esperado por Rive)
    final targetX = ((normalizedX + 1.0) * 50.0).clamp(0.0, 100.0);
    final targetY = ((normalizedY + 1.0) * 50.0).clamp(0.0, 100.0);

    return TrackingResult(
      targetX: targetX,
      targetY: targetY,
      isTracking: true,
    );
  }

  /// Calcula el factor de suavizado basado en si está tracking o en reposo
  static double calculateSmoothFactor(bool isTracking) {
    // Tracking: instantáneo (1.0)
    // Reposo: suave y fluido (0.05)
    return isTracking ? 1.0 : 0.05;
  }

  /// Interpola un valor con suavizado
  static double smoothValue({
    required double current,
    required double target,
    required double smoothFactor,
    double defaultValue = 50.0,
  }) {
    final result = current + (target - current) * smoothFactor;
    return result.isFinite ? result : defaultValue;
  }
}

/// Resultado del cálculo de tracking
class TrackingResult {
  final double targetX;
  final double targetY;
  final bool isTracking;

  const TrackingResult({
    required this.targetX,
    required this.targetY,
    required this.isTracking,
  });
}
