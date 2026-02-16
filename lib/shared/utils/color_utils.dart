import 'package:flutter/material.dart';

/// Utilidades para trabajar con colores
class ColorUtils {
  ColorUtils._();

  /// Obtiene un color de texto que contrasta con el color de fondo
  /// Retorna blanco para fondos oscuros y negro para fondos claros
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calcular la luminancia del color de fondo
    final luminance = backgroundColor.computeLuminance();
    
    // Si la luminancia es mayor a 0.5, el fondo es claro, usar texto oscuro
    // Si es menor o igual a 0.5, el fondo es oscuro, usar texto claro
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Obtiene un color con el alpha modificado
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  /// Convierte un color a su representación hexadecimal
  static String toHexString(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Crea un color desde una cadena hexadecimal
  static Color fromHexString(String hex) {
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Oscurece un color en un porcentaje dado (0.0 a 1.0)
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Aclara un color en un porcentaje dado (0.0 a 1.0)
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
