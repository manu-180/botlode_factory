import 'app_config.dart';

/// Constantes globales de la aplicación BotLode Web
abstract class AppConstants {
  // ══════════════════════════════════════════════════════════════════════════
  // BREAKPOINTS RESPONSIVE
  // ══════════════════════════════════════════════════════════════════════════

  /// Móvil pequeño
  static const double mobileSmall = 320;

  /// Móvil
  static const double mobile = 480;

  /// Tablet
  static const double tablet = 768;

  /// Desktop pequeño
  static const double desktopSmall = 1024;

  /// Desktop
  static const double desktop = 1280;

  /// Desktop grande
  static const double desktopLarge = 1536;

  // ══════════════════════════════════════════════════════════════════════════
  // DURACIONES DE ANIMACIÓN
  // ══════════════════════════════════════════════════════════════════════════

  /// Animación ultra rápida (hover states)
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Animación normal
  static const Duration durationNormal = Duration(milliseconds: 300);

  /// Animación media
  static const Duration durationMedium = Duration(milliseconds: 500);

  /// Animación lenta (entradas)
  static const Duration durationSlow = Duration(milliseconds: 800);

  // ══════════════════════════════════════════════════════════════════════════
  // ESPACIADO
  // ══════════════════════════════════════════════════════════════════════════

  /// Espaciado extra pequeño
  static const double spacingXs = 4;

  /// Espaciado pequeño
  static const double spacingSm = 8;

  /// Espaciado medio
  static const double spacingMd = 16;

  /// Espaciado grande
  static const double spacingLg = 24;

  /// Espaciado extra grande
  static const double spacingXl = 32;

  /// Espaciado 2XL
  static const double spacing2xl = 48;

  /// Espaciado 3XL
  static const double spacing3xl = 64;

  /// Espaciado 4XL
  static const double spacing4xl = 96;

  // ══════════════════════════════════════════════════════════════════════════
  // BORDES
  // ══════════════════════════════════════════════════════════════════════════

  /// Radio de borde pequeño
  static const double radiusSm = 8;

  /// Radio de borde medio
  static const double radiusMd = 12;

  /// Radio de borde grande
  static const double radiusLg = 16;

  /// Radio de borde extra grande
  static const double radiusXl = 24;

  /// Grosor del borde glow (fino, uniforme en todos los lados)
  static const double glowBorderWidth = 1.5;

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENIDO
  // ══════════════════════════════════════════════════════════════════════════

  /// Ancho máximo del contenido (navbar, hero, pilares, etc.)
  static const double maxContentWidth = 900;

  /// Padding horizontal en móvil
  static const double mobilePadding = 20;

  /// Padding horizontal en desktop
  static const double desktopPadding = 40;

  // ══════════════════════════════════════════════════════════════════════════
  // SUPABASE - Delegadas a AppConfig
  // ══════════════════════════════════════════════════════════════════════════

  /// URL de Supabase (delegada a AppConfig)
  static String get supabaseUrl => AppConfig.supabaseUrl;

  /// Anon Key de Supabase (delegada a AppConfig)
  static String get supabaseAnonKey => AppConfig.supabaseAnonKey;

  // ══════════════════════════════════════════════════════════════════════════
  // RUTAS
  // ══════════════════════════════════════════════════════════════════════════

  static const String routeHome = '/';
  static const String routeBot = '/bot';
  static const String routeFactory = '/factory';
  static const String routeTutorial = '/tutorial';
  static const String routeDemo = '/demo';
  /// En Factory no hay vista History; el CTA del bot redirige a Demo
  static const String routeHistory = '/demo';

  // ══════════════════════════════════════════════════════════════════════════
  // CONTACTO
  // ══════════════════════════════════════════════════════════════════════════

  /// Número de WhatsApp de contacto (formato internacional sin +)
  static const String whatsappNumber = '5491134272488';
  
  /// Mensaje predeterminado para WhatsApp
  static const String whatsappDefaultMessage = '¡Hola! Quiero conocer más sobre BotLode Factory';
}
