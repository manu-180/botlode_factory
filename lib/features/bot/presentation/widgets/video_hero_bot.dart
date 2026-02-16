import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import '../../../../shared/widgets/video_skeleton.dart';
import '../../../../shared/widgets/video_poster_fallback.dart';

import 'video_hero_registration_stub.dart'
    if (dart.library.html) 'video_hero_registration_web.dart' as registration;

/// Hero con video de fondo para Bot
class VideoHeroBot extends StatefulWidget {
  const VideoHeroBot({super.key});

  @override
  State<VideoHeroBot> createState() => _VideoHeroBotState();
}

class _VideoHeroBotState extends State<VideoHeroBot> {
  static const String _viewTypeHorizontal = 'bot-video-horizontal';
  static const String _viewTypeVertical = 'bot-video-vertical';
  static int _viewCounter = 0;
  late String _viewIdHorizontal;
  late String _viewIdVertical;
  bool _isInitialized = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _viewIdHorizontal = '${_viewTypeHorizontal}_${_viewCounter}';
    _viewIdVertical = '${_viewTypeVertical}_${_viewCounter}';
    _viewCounter++;

    if (kIsWeb) {
      registration.registerVideoElementWeb(
        _viewIdHorizontal,
        'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/botplayerhorizontal.mp4',
        () { if (mounted) setState(() => _videoFailed = true); },
      );
      registration.registerVideoElementWeb(
        _viewIdVertical,
        'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/botplayervertical.mp4',
        () { if (mounted) setState(() => _videoFailed = true); },
      );
    } else {
      // En Windows/desktop no hay video HTML, mostrar fallback
      _videoFailed = true;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < AppConstants.tablet;

    // Seleccionar el viewId correcto según el tamaño de pantalla
    final viewId = isMobile ? _viewIdVertical : _viewIdHorizontal;

    // Altura mínima (el hero crece con el contenido y es "uno" con el body, sin overflow)
    final minHeroHeight = isMobile 
        ? screenHeight * 0.9 
        : screenHeight * 0.85;

    return RepaintBoundary(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeroHeight),
        child: Stack(
          children: [
            // Poster/fallback cuando no hay red o el video falla
            if (_videoFailed)
            Positioned.fill(
              child: VideoPosterFallback(
                accentColor: AppColors.techCyan,
              ),
            ),

          // Video de fondo: ignorar punteros para que los toques lleguen siempre al contenido (modos, avatar)
          if (!_videoFailed)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox.expand(
                    child: HtmlElementView(
                      key: ValueKey(viewId),
                      viewType: viewId,
                    ),
                  ),
                ),
              ),
            ),

          // Overlay más sutil y extendido (también ignorar punteros para que pasen al contenido)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.50), // Top
                    Colors.black.withValues(alpha: 0.30), // Medio-alto
                    Colors.black.withValues(alpha: 0.35), // Medio
                    Colors.black.withValues(alpha: 0.45), // Medio-bajo para modos
                    Colors.black.withValues(alpha: 0.75), // Muy abajo
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
                ),
              ),
            ),
            ),
          ),

          // Contenido encima del video. Sin Positioned.fill para que el Stack mida su altura y sea "uno" con el body.
          Center(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 32 : 48,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? screenWidth - 48 : 1000,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        // Título con barra vertical pulsante
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Barra vertical pulsante
                            PulsingBar(
                              color: AppColors.techCyan,
                              width: 4,
                              height: isMobile ? 40 : 55,
                            ),
                            
                            SizedBox(width: isMobile ? 16 : 24),
                            
                            // Título compacto
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título principal
                                  Text(
                                    'Cat Bot',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      color: Colors.white,
                                      fontSize: isMobile ? 32 : 48,
                                      letterSpacing: isMobile ? -1 : -1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.8),
                                          blurRadius: 24,
                                          offset: const Offset(0, 4),
                                        ),
                                        Shadow(
                                          color: AppColors.techCyan.withValues(alpha: 0.6),
                                          blurRadius: 48,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: isMobile ? 6 : 8),
                                  // Subtítulo minimalista
                                  Text(
                                    'Con personalidad que se adapta',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                      fontSize: isMobile ? 13 : 16,
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
                            .fadeIn(duration: 800.ms)
                            .slideX(begin: -0.3, end: 0),

                        SizedBox(height: isMobile ? 16 : 24),

                        // Avatar interactivo del bot Rive (sin aura)
                        InteractiveRiveBotAvatar(
                          size: isMobile ? 220 : 280,
                          initialMood: 5, // Técnico
                        )
                            .animate()
                            .fadeIn(duration: 800.ms, delay: 300.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        ],
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
