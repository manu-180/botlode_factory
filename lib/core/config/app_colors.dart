import 'package:flutter/material.dart';

/// Paleta de colores oficial de BotLode
/// Estética tecnológica/futurista con tonos dorados
abstract class AppColors {
  // ══════════════════════════════════════════════════════════════════════════
  // COLORES PRIMARIOS
  // ══════════════════════════════════════════════════════════════════════════

  /// Amarillo Oro - Color principal de la marca
  static const Color primary = Color(0xFFFFC000);

  /// Oro brillante para efectos de glow
  static const Color primaryGlow = Color(0xFFFFD54F);

  /// Oro oscuro para gradientes
  static const Color primaryDark = Color(0xFFB38600);

  // ══════════════════════════════════════════════════════════════════════════
  // FONDOS Y SUPERFICIES
  // ══════════════════════════════════════════════════════════════════════════

  /// Negro profundo - Fondo principal
  static const Color background = Color(0xFF050505);

  /// Gris oscuro / Carbono - Superficies elevadas
  static const Color surface = Color(0xFF151515);

  /// Superficie más clara para cards
  static const Color surfaceLight = Color(0xFF1A1A1A);

  /// Superficie con hover
  static const Color surfaceHover = Color(0xFF252525);

  /// Bordes sutiles de vidrio
  static const Color borderGlass = Colors.white10;

  /// Borde con más visibilidad
  static const Color borderLight = Colors.white24;

  // ══════════════════════════════════════════════════════════════════════════
  // COLORES DE ESTADO / MODOS DEL BOT
  // ══════════════════════════════════════════════════════════════════════════

  /// Verde Neón - Éxito, Online
  static const Color success = Color(0xFF00FF94);

  /// Naranja Neón - Advertencia, Alerta
  static const Color warning = Color(0xFFFF9500);

  /// Rojo Láser - Error, Enojado
  static const Color error = Color(0xFFFF003C);

  /// Cyan Cyberpunk - Técnico
  static const Color techCyan = Color(0xFF00F0FF);

  /// Rosa/Magenta - Feliz
  static const Color happy = Color(0xFFFF00D6);

  /// Púrpura - Confundido
  static const Color confused = Color(0xFF7B00FF);

  /// Rojo intenso - Enojado
  static const Color angry = Color(0xFFFF2A00);

  /// Rojo tranquilo - Costos / mantenimiento (va con el tema oscuro)
  static const Color maintenanceRed = Color(0xFFC97070);

  /// Amarillo Oro - Vendedor (mismo que primary)
  static const Color sales = primary;

  /// Verde Neón - Neutral
  static const Color neutral = Color(0xFF00FF94);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXTO
  // ══════════════════════════════════════════════════════════════════════════

  /// Texto principal
  static const Color textPrimary = Colors.white;

  /// Texto secundario
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// Texto terciario / disabled
  static const Color textTertiary = Color(0xFF707070);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ══════════════════════════════════════════════════════════════════════════

  /// Gradiente dorado principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFC000),
      Color(0xFFB38600),
    ],
  );

  /// Gradiente de fondo sutil
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0A0A),
      Color(0xFF050505),
      Color(0xFF000000),
    ],
  );

  /// Gradiente para bordes con glow
  static RadialGradient glowGradient({
    required Offset center,
    Color color = primary,
  }) {
    return RadialGradient(
      center: Alignment(center.dx, center.dy),
      radius: 1.5,
      colors: [
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOMBRAS
  // ══════════════════════════════════════════════════════════════════════════

  /// Sombra suave para cards
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// Sombra con glow dorado
  static List<BoxShadow> glowShadow({Color color = primary, double intensity = 0.4}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 30,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
