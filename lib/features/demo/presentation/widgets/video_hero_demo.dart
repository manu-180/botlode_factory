import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/services/video_preloader_service.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/video_skeleton.dart';
import '../../../../shared/widgets/video_poster_fallback.dart';

/// Hero con video de fondo para Demo usando HTML5 Video Element
class VideoHeroDemo extends StatefulWidget {
  const VideoHeroDemo({super.key});

  @override
  State<VideoHeroDemo> createState() => _VideoHeroDemoState();
}

class _VideoHeroDemoState extends State<VideoHeroDemo> {
  static const String _viewTypeHorizontal = 'demo-video-horizontal';
  static const String _viewTypeVertical = 'demo-video-vertical';
  static int _viewCounter = 0;
  late String _viewIdHorizontal;
  late String _viewIdVertical;
  bool _isInitialized = false;
  bool _videoFailed = false;
  static final Set<String> _registeredViews = {};

  @override
  void initState() {
    super.initState();
    _viewIdHorizontal = '${_viewTypeHorizontal}_${_viewCounter}';
    _viewIdVertical = '${_viewTypeVertical}_${_viewCounter}';
    _viewCounter++;
    
    // Registrar ambas versiones del video (horizontal y vertical)
    _registerVideoElement(_viewIdHorizontal, 'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/demohorizontal.mp4');
    _registerVideoElement(_viewIdVertical, 'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/demovertical.mp4');
    
    VideoPreloaderService().registerErrorCallback(_viewIdHorizontal, () {
      if (mounted) setState(() => _videoFailed = true);
    });
    VideoPreloaderService().registerErrorCallback(_viewIdVertical, () {
      if (mounted) setState(() => _videoFailed = true);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  void _registerVideoElement(String viewId, String videoPath) {
    // Evitar registrar el mismo viewId múltiples veces
    if (_registeredViews.contains(viewId)) {
      return;
    }
    _registeredViews.add(viewId);

    // Registrar el video element para Flutter Web de forma síncrona
    // ignore: undefined_prefixed_name
    final viewIdKey = viewId;
    ui_web.platformViewRegistry.registerViewFactory(
      viewIdKey,
      (int id) {
        final videoElement = VideoPreloaderService().getVideo(videoPath);

        videoElement.onCanPlay.listen((_) {
          videoElement.play();
        });

        videoElement.onLoadedData.listen((_) {
          videoElement.play();
        });

        videoElement.onError.listen((error) {
          debugPrint('Error playing video $videoPath: $error');
          VideoPreloaderService().notifyVideoError(viewIdKey);
        });

        // Si el video ya está listo (pre-cargado), reproducir inmediatamente
        if (videoElement.readyState >= 3) {
          videoElement.play();
        }

        return videoElement;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < AppConstants.tablet;

    // Seleccionar el viewId correcto según el tamaño de pantalla
    final viewId = isMobile ? _viewIdVertical : _viewIdHorizontal;

    // Altura del hero
    final heroHeight = isMobile 
        ? screenHeight * 0.7  // 70% de la pantalla en móvil
        : screenHeight * 0.85; // 85% de la pantalla en desktop

    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: heroHeight,
        child: Stack(
          children: [
            if (_videoFailed)
            Positioned.fill(
              child: VideoPosterFallback(
                accentColor: AppColors.primary,
              ),
            ),

          if (!_videoFailed)
            Positioned.fill(
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: double.infinity,
                  height: heroHeight,
                  child: HtmlElementView(
                    key: ValueKey(viewId),
                    viewType: viewId,
                  ),
                ),
              ),
            ),

          // Overlay más sutil para dejar brillar el video
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45), // Más transparente arriba
                    Colors.black.withValues(alpha: 0.25), // Muy transparente en medio
                    Colors.black.withValues(alpha: 0.5),  // Medio transparente abajo
                    Colors.black.withValues(alpha: 0.85), // Borde inferior
                  ],
                  stops: const [0.0, 0.4, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // Contenido encima del video
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 40 : 60,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? screenWidth - 48 : 1000,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Título con barra vertical accent pulsante
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Barra vertical pulsante
                            PulsingBar(
                              color: AppColors.primary,
                              width: 4,
                              height: isMobile ? 60 : 80,
                            ),
                            
                            SizedBox(width: isMobile ? 20 : 32),
                            
                            // Título compacto y potente
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título principal
                                  Text(
                                    'Demo Interactivo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      color: Colors.white,
                                      fontSize: isMobile ? 38 : 58,
                                      letterSpacing: isMobile ? -1 : -1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.8),
                                          blurRadius: 24,
                                          offset: const Offset(0, 4),
                                        ),
                                        Shadow(
                                          color: AppColors.primary.withValues(alpha: 0.6),
                                          blurRadius: 48,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  // Subtítulo minimalista
                                  Text(
                                    'Crea. Prueba. Experimenta.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                      fontSize: isMobile ? 16 : 22,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.8),
                                          blurRadius: 16,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 900.ms)
                            .slideX(begin: -0.3, end: 0)
                            .scale(begin: const Offset(0.95, 0.95)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Skeleton loader mientras se inicializa el video
          if (!_isInitialized)
            const Positioned.fill(
              child: SimpleVideoSkeleton(),
            ),

          // Franja inferior para ocultar artefacto de línea clara en el borde del video al hacer scroll
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 12,
              color: AppColors.background,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
