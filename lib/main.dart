import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/head_tracking_provider.dart';
import 'core/providers/app_initialization_provider.dart';
import 'shared/widgets/splash_screen.dart';

const String DEPLOY_VERSION = "FACTORY v1.0 - Initial Release";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    debugPrint('⚠️ No se pudo cargar .env: $e');
    debugPrint('✅ Usando credenciales hardcodeadas de producción');
  }

  // Suprimir errores de hit test durante desarrollo (Flutter web issue)
  FlutterError.onError = (details) {
    final message = details.exception.toString();
    // Ignorar errores de hit test que son comunes en Flutter web
    if (message.contains('hit test') || message.contains('no size')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // ⚡ OPTIMIZACIÓN: Ya NO esperamos Supabase aquí
  // Se inicializará en background cuando se necesite (lazy loading)
  debugPrint('🚀 Iniciando BotLode Factory...');
  debugPrint('📦 DEPLOY VERSION: $DEPLOY_VERSION');

  runApp(
    const ProviderScope(
      child: BotLodeFactoryApp(),
    ),
  );
}

/// Aplicación principal de BotLode Factory
class BotLodeFactoryApp extends ConsumerStatefulWidget {
  const BotLodeFactoryApp({super.key});

  @override
  ConsumerState<BotLodeFactoryApp> createState() => _BotLodeFactoryAppState();
}

class _BotLodeFactoryAppState extends ConsumerState<BotLodeFactoryApp> {
  /// Throttle timer para limitar actualizaciones del provider de posición de mouse.
  /// Sin throttle, cada pixel de movimiento del mouse actualiza el provider,
  /// causando rebuilds en cascada en todos los widgets que lo escuchan.
  Timer? _mouseThrottleTimer;
  Offset? _pendingMousePosition;
  static const Duration _mouseThrottleInterval = Duration(milliseconds: 50); // ~20fps

  /// Detecta si estamos en un dispositivo táctil (móvil/tablet)
  bool _isTouchDevice = false;

  @override
  void initState() {
    super.initState();
    // ⚡ OPTIMIZACIÓN: Iniciar precarga de recursos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appInitializationProvider.notifier).preloadResources(ref);
      // Detectar si es dispositivo táctil
      final view = View.of(context);
      final width = view.physicalSize.width / view.devicePixelRatio;
      _isTouchDevice = width < 1024;
    });
  }

  @override
  void dispose() {
    _mouseThrottleTimer?.cancel();
    super.dispose();
  }

  /// Actualiza la posición del mouse con throttle para reducir actualizaciones del provider
  void _onMouseHover(PointerEvent event) {
    if (_isTouchDevice) return; // No procesar mouse en dispositivos táctiles
    
    _pendingMousePosition = event.position;
    if (_mouseThrottleTimer?.isActive ?? false) return;
    
    // Actualizar inmediatamente la primera vez
    ref.read(globalPointerPositionProvider.notifier).state = event.position;
    
    _mouseThrottleTimer = Timer(_mouseThrottleInterval, () {
      if (_pendingMousePosition != null) {
        ref.read(globalPointerPositionProvider.notifier).state = _pendingMousePosition;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final initState = ref.watch(appInitializationProvider);

    // OPTIMIZACIÓN: En dispositivos táctiles, no envolver con MouseRegion
    final Widget app = MaterialApp.router(
      title: 'BotLode Factory - Fábrica de Bots IA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      // ⚡ OPTIMIZACIÓN: Builder para mostrar splash o app
      builder: (context, child) {
        if (initState.showSplash) {
          return const SplashScreen();
        }
        
        // Transición suave del splash al contenido
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: child,
        );
      },
    );

    // En dispositivos táctiles, omitir MouseRegion completamente
    if (_isTouchDevice) return app;

    return MouseRegion(
      onHover: _onMouseHover,
      onExit: (_) {
        _mouseThrottleTimer?.cancel();
        _pendingMousePosition = null;
        // Cuando el mouse sale de la ventana, volver al centro
        ref.read(globalPointerPositionProvider.notifier).state = null;
      },
      child: app,
    );
  }
}
