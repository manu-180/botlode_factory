import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_colors.dart';

/// Widget que muestra el primer frame de un video como thumbnail.
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final String? staticThumbnail; // Ruta a imagen estática de miniatura

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.fallbackIcon,
    this.accentColor = AppColors.primary,
    this.staticThumbnail,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Solo cargar video si no hay imagen estática disponible
    if (widget.staticThumbnail == null) {
      _initializeVideo();
    } else {
      // Si hay imagen estática, marcar como inicializado
      _isInitialized = true;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Determinar si es asset local o URL externa
      if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      }

      final controller = _controller;
      if (controller == null) return;
      
      await controller.initialize();
      
      // Ir al primer frame (posición 0)
      await controller.seekTo(Duration.zero);
      
      // Configurar atributos HTML en web para ocultar controles nativos
      if (kIsWeb) {
        _configureVideoElementAttributes();
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error cargando thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  /// Configurar atributos HTML del elemento video para ocultar controles nativos del navegador
  void _configureVideoElementAttributes() {
    if (!kIsWeb) return;
    
    try {
      // Esperar un frame para que el video element esté en el DOM
      Future.delayed(const Duration(milliseconds: 100), () {
        final videoElements = html.document.querySelectorAll('video');
        for (var element in videoElements) {
          if (element is html.VideoElement) {
            element.controls = false;
            element.setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback');
            element.setAttribute('disablePictureInPicture', 'true');
            element.setAttribute('playsinline', 'true');
            element.setAttribute('webkit-playsinline', 'true');
          }
        }
      });
    } catch (e) {
      debugPrint('Error configurando atributos HTML del video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si hay imagen estática, usarla directamente
    if (widget.staticThumbnail != null) {
      return Image.asset(
        widget.staticThumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Si falla la imagen, mostrar fallback con icono
          return _buildFallback();
        },
      );
    }
    
    final controller = _controller;
    
    if (_hasError || !_isInitialized || controller == null) {
      // Fallback: Icono con gradiente mientras carga o si hay error
      return _buildFallback();
    }

    // Mostrar el primer frame del video
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            widget.accentColor.withValues(alpha: 0.15),
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon,
          size: 80,
          color: widget.accentColor.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

/// Widget que obtiene la duración real de un video.
class VideoMetadataProvider extends StatefulWidget {
  final String videoUrl;
  final Widget Function(BuildContext context, Duration? duration, bool isLoading) builder;

  const VideoMetadataProvider({
    super.key,
    required this.videoUrl,
    required this.builder,
  });

  @override
  State<VideoMetadataProvider> createState() => _VideoMetadataProviderState();
}

class _VideoMetadataProviderState extends State<VideoMetadataProvider> {
  VideoPlayerController? _controller;
  Duration? _duration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      // Determinar si es asset local o URL externa
      VideoPlayerController controller;
      if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        controller = VideoPlayerController.asset(widget.videoUrl);
      }
      
      _controller = controller;

      await controller.initialize();
      
      // Configurar atributos HTML en web para ocultar controles nativos
      if (kIsWeb) {
        _configureVideoMetadataElementAttributes();
      }
      
      final duration = controller.value.duration;
      
      // Dispose inmediatamente después de obtener la metadata
      controller.dispose();
      _controller = null; // Marcar como disposed
      
      if (mounted) {
        setState(() {
          _duration = duration;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error obteniendo metadata del video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Configurar atributos HTML del elemento video para ocultar controles nativos del navegador
  void _configureVideoMetadataElementAttributes() {
    if (!kIsWeb) return;
    
    try {
      // Esperar un frame para que el video element esté en el DOM
      Future.delayed(const Duration(milliseconds: 100), () {
        final videoElements = html.document.querySelectorAll('video');
        for (var element in videoElements) {
          if (element is html.VideoElement) {
            element.controls = false;
            element.setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback');
            element.setAttribute('disablePictureInPicture', 'true');
            element.setAttribute('playsinline', 'true');
            element.setAttribute('webkit-playsinline', 'true');
          }
        }
      });
    } catch (e) {
      debugPrint('Error configurando atributos HTML del video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _duration, _isLoading);
  }
}
