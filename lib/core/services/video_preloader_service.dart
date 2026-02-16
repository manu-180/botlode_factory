import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Servicio para pre-cargar videos en el inicio de la app
/// para que aparezcan instantáneamente cuando se necesiten.
///
/// OPTIMIZACIÓN: Carga secuencial (no paralela) para no saturar red,
/// y detecta orientación para priorizar los videos de la pantalla actual.
class VideoPreloaderService {
  static final VideoPreloaderService _instance = VideoPreloaderService._internal();
  factory VideoPreloaderService() => _instance;
  VideoPreloaderService._internal();

  // Cache de video elements pre-cargados
  final Map<String, html.VideoElement> _videoCache = {};
  
  // Estado de carga
  final Map<String, Completer<void>> _loadingCompleters = {};
  bool _isPreloading = false;
  bool _allVideosLoaded = false;

  /// Callbacks por viewId para notificar cuando un video falla (ej. sin red)
  final Map<String, void Function()> _errorCallbacks = {};

  /// Videos horizontales (desktop) - URLs públicas Supabase
  static const List<String> _horizontalVideoPaths = [
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/videohomehorizontal.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/fabricahorizontal.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/demohorizontal.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/botplayerhorizontal.mp4',
  ];

  /// Videos verticales (mobile) - URLs públicas Supabase
  static const List<String> _verticalVideoPaths = [
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/videohomevertical.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/fabricavertical.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/demovertical.mp4',
    'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/botplayervertical.mp4',
  ];

  /// Convierte clave de asset a URL absoluta para web.
  static String _resolveAssetUrl(String assetKey) {
    if (assetKey.startsWith('http://') || assetKey.startsWith('https://') || assetKey.startsWith('/')) {
      return assetKey;
    }
    return '/assets/$assetKey';
  }

  /// Detectar si la pantalla es mobile (vertical)
  static bool _isMobileScreen() {
    return html.window.innerWidth != null && html.window.innerWidth! < 600;
  }

  /// Pre-cargar videos de forma SECUENCIAL y PRIORIZADA.
  /// 1. Primero carga los videos de la orientación actual (mobile=vertical, desktop=horizontal)
  /// 2. Luego carga los de la otra orientación
  Future<void> preloadAllVideos() async {
    if (_isPreloading || _allVideosLoaded) {
      debugPrint('⏭️ Videos ya están cargándose o cargados');
      return;
    }

    _isPreloading = true;
    debugPrint('🎬 Iniciando precarga secuencial de videos...');

    final startTime = DateTime.now();
    final isMobile = _isMobileScreen();
    
    // Priorizar videos de la orientación actual
    final priorityVideos = isMobile ? _verticalVideoPaths : _horizontalVideoPaths;
    final secondaryVideos = isMobile ? _horizontalVideoPaths : _verticalVideoPaths;

    // Fase 1: Cargar SECUENCIALMENTE los videos prioritarios (orientación actual)
    for (final path in priorityVideos) {
      await _preloadSingleVideo(path);
    }

    final phase1Duration = DateTime.now().difference(startTime);
    debugPrint('✅ Videos prioritarios cargados en ${phase1Duration.inMilliseconds}ms');

    // Fase 2: Cargar SECUENCIALMENTE los videos secundarios (otra orientación)
    for (final path in secondaryVideos) {
      await _preloadSingleVideo(path);
    }

    final totalDuration = DateTime.now().difference(startTime);
    _allVideosLoaded = true;
    _isPreloading = false;
    
    debugPrint('✅ Todos los videos pre-cargados en ${totalDuration.inMilliseconds}ms');
  }

  /// Pre-cargar un video individual
  Future<void> _preloadSingleVideo(String path) async {
    if (_videoCache.containsKey(path)) {
      debugPrint('✓ Video ya cargado: $path');
      return;
    }

    final completer = Completer<void>();
    _loadingCompleters[path] = completer;

    try {
      final resolvedUrl = _resolveAssetUrl(path);
      // Crear elemento de video optimizado para precarga
      final videoElement = html.VideoElement()
        ..src = resolvedUrl
        ..muted = true // Debe estar muted para autoplay
        ..loop = true
        ..controls = false // Sin controles
        ..preload = 'auto' // Cargar completamente el video
        ..style.display = 'none' // Oculto durante precarga
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
        ..setAttribute('disablePictureInPicture', 'true');

      // Escuchar cuando el video está listo
      videoElement.onCanPlayThrough.listen((_) {
        if (!completer.isCompleted) {
          _videoCache[path] = videoElement;
          debugPrint('✅ Video pre-cargado: $path');
          completer.complete();
        }
      });

      // Manejar errores
      videoElement.onError.listen((error) {
        if (!completer.isCompleted) {
          debugPrint('❌ Error cargando video: $path');
          completer.completeError('Error loading video: $path');
        }
      });

      // Timeout de seguridad (30 segundos)
      Future.delayed(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          debugPrint('⏱️ Timeout cargando video: $path');
          // Completar de todas formas para no bloquear
          _videoCache[path] = videoElement;
          completer.complete();
        }
      });

      // Agregar al DOM temporalmente para forzar carga
      html.document.body?.append(videoElement);

      await completer.future;
      
    } catch (e) {
      debugPrint('❌ Excepción pre-cargando video $path: $e');
    }
  }

  /// Obtener un video pre-cargado (o crear uno nuevo si no existe).
  /// Quien use el elemento debe registrar onError y llamar [notifyVideoError] si falla.
  html.VideoElement getVideo(String path) {
    final resolvedUrl = _resolveAssetUrl(path);
    if (_videoCache.containsKey(path)) {
      // Clonar el video para uso independiente
      final clonedVideo = html.VideoElement()
        ..src = resolvedUrl
        ..autoplay = true
        ..muted = true
        ..loop = true
        ..controls = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.objectPosition = 'center center'
        ..style.display = 'block'
        ..style.border = 'none'
        ..style.outline = 'none'
        ..style.margin = '0'
        ..style.padding = '0'
        ..style.transform = 'translateZ(0)'
        ..style.setProperty('-webkit-transform', 'translateZ(0)')
        ..style.setProperty('image-rendering', 'optimizeQuality')
        ..style.setProperty('-webkit-backface-visibility', 'hidden')
        ..style.setProperty('backface-visibility', 'hidden')
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
        ..setAttribute('disablePictureInPicture', 'true');

      debugPrint('🎯 Video servido desde caché: $path');
      return clonedVideo;
    }

    debugPrint('⚠️ Video no está en caché, creando nuevo: $path');
    return html.VideoElement()
      ..src = resolvedUrl
      ..autoplay = true
      ..muted = true
      ..loop = true
      ..controls = false
      ..preload = 'auto'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.objectPosition = 'center center'
      ..style.display = 'block'
      ..style.border = 'none'
      ..style.outline = 'none'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.transform = 'translateZ(0)'
      ..style.setProperty('-webkit-transform', 'translateZ(0)')
      ..style.setProperty('image-rendering', 'optimizeQuality')
      ..style.setProperty('-webkit-backface-visibility', 'hidden')
      ..style.setProperty('backface-visibility', 'hidden')
      ..setAttribute('playsinline', 'true')
      ..setAttribute('webkit-playsinline', 'true')
      ..setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
      ..setAttribute('disablePictureInPicture', 'true');
  }

  /// Verificar si un video está cargado
  bool isVideoLoaded(String path) => _videoCache.containsKey(path);

  /// Verificar si todos los videos están cargados
  bool get allVideosLoaded => _allVideosLoaded;

  /// Registra un callback que se invoca cuando el video de este viewId falla al cargar
  /// (ej. sin WiFi). Permite mostrar un poster/fallback en los heroes.
  void registerErrorCallback(String viewId, void Function() onError) {
    _errorCallbacks[viewId] = onError;
  }

  /// Llamado desde el factory del platform view cuando el elemento video dispara onError
  void notifyVideoError(String viewId) {
    _errorCallbacks[viewId]?.call();
  }

  /// Limpiar caché (útil para testing)
  void clearCache() {
    for (var video in _videoCache.values) {
      video.pause();
      video.remove();
    }
    _videoCache.clear();
    _loadingCompleters.clear();
    _errorCallbacks.clear();
    _allVideosLoaded = false;
    _isPreloading = false;
    debugPrint('🗑️ Caché de videos limpiada');
  }
}
