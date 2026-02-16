import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/providers/head_tracking_provider.dart';
import '../../../../core/services/video_preloader_service.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import 'hero_title.dart';
import '../../../../shared/widgets/video_skeleton.dart';
import '../../../../shared/widgets/video_poster_fallback.dart';

/// Hero con video de fondo para Home (horizontal/vertical) usando HTML5 Video Element.
/// Mismo patrón que Bot, Demo y Factory; estilos para ocultar controles en Edge están en web/index.html.
class VideoHeroHome extends ConsumerStatefulWidget {
  const VideoHeroHome({super.key});

  @override
  ConsumerState<VideoHeroHome> createState() => _VideoHeroHomeState();
}

class _VideoHeroHomeState extends ConsumerState<VideoHeroHome> {
  static const String _viewTypeHorizontal = 'home-video-horizontal';
  static const String _viewTypeVertical = 'home-video-vertical';
  static int _viewCounter = 0;
  late String _viewIdHorizontal;
  late String _viewIdVertical;
  bool _isInitialized = false;
  bool _videoFailed = false;
  bool _isThinking = false;
  static final Set<String> _registeredViews = {};

  void _toggleThinking() {
    setState(() => _isThinking = !_isThinking);
  }

  @override
  void initState() {
    super.initState();
    _viewIdHorizontal = '${_viewTypeHorizontal}_${_viewCounter}';
    _viewIdVertical = '${_viewTypeVertical}_${_viewCounter}';
    _viewCounter++;

    _registerVideoElement(_viewIdHorizontal, 'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/videohomehorizontal.mp4');
    _registerVideoElement(_viewIdVertical, 'https://gfvslxtqmjrelrugrcfp.supabase.co/storage/v1/object/public/botlode/videohomevertical.mp4');

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
    if (_registeredViews.contains(viewId)) return;
    _registeredViews.add(viewId);

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

    final viewId = isMobile ? _viewIdVertical : _viewIdHorizontal;

    // Altura ajustada para mejor proporción y espaciado
    final heroHeight = isMobile
        ? screenHeight * 0.80
        : screenHeight * 0.75;

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
                child: IgnorePointer(
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
              ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.4, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Área de contenido con altura máxima para evitar overflow
            // Listener actualiza la posición del mouse aquí para que el bot del hero siga el cursor (como en Bot/Demo)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Listener(
                onPointerMove: (event) {
                  ref.read(globalPointerPositionProvider.notifier).state = event.position;
                },
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                    final paddingH = isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding;
                    final paddingTop = isMobile ? 24.0 : 48.0;
                    final paddingBottom = isMobile ? 24.0 : 48.0;
                    final gradientHeight = 80.0;
                    final maxContentHeight = constraints.maxHeight - paddingTop - paddingBottom - gradientHeight;
                    // Mismo ancho máximo que el resto del home (navbar, pilares, cards, etc.)
                    final maxContentWidth = isMobile ? screenWidth - paddingH * 2 : AppConstants.maxContentWidth;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        paddingH,
                        paddingTop,
                        paddingH,
                        paddingBottom + gradientHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                            maxHeight: maxContentHeight,
                          ),
                          child: isMobile
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: _buildMobileContentWithTracking(
                                    context,
                                    maxContentHeight,
                                  ),
                                )
                              : _buildDesktopContentWithTracking(
                                  context,
                                  screenWidth,
                                  maxContentWidth,
                                  maxContentHeight,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                ),
              ),
            ),

            if (!_isInitialized)
              const Positioned.fill(
                child: SimpleVideoSkeleton(),
              ),

            // Transición suave y amplia al contenido inferior (elimina la franja negra)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.45),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop: texto/botones dentro de FittedBox (escala si no cabe);
  /// avatar FUERA de FittedBox para que el seguimiento del mouse use coordenadas correctas (como en Bot/Demo).
  Widget _buildDesktopContentWithTracking(
    BuildContext context,
    double screenWidth,
    double maxContentWidth,
    double maxContentHeight,
  ) {
    final isLarge = screenWidth >= AppConstants.desktop;
    var avatarSize = isLarge ? 540.0 : 420.0;
    if (maxContentHeight < 500) avatarSize = 280;
    else if (maxContentHeight < 600) avatarSize = 360;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _HeroContent(isMobile: false, compact: maxContentHeight < 520),
            ),
          ),
        ),
        SizedBox(width: maxContentHeight < 400 ? 16 : 32),
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: RepaintBoundary(
            child: GestureDetector(
              onTap: _toggleThinking,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: RiveBotAvatar(
                  size: avatarSize,
                  enableMouseTracking: true,
                  isThinking: _isThinking,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Móvil: orden título -> bot -> botones. Sin subtítulo, bot y título más grandes.
  Widget _buildMobileContentWithTracking(BuildContext context, double maxContentHeight) {
    final avatarSize = maxContentHeight < 380 ? 240.0 : (maxContentHeight < 500 ? 300.0 : 360.0);
    final compact = maxContentHeight < 520;

    final avatarWidget = RepaintBoundary(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: GestureDetector(
          onTap: _toggleThinking,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: RiveBotAvatar(
              size: avatarSize,
              enableMouseTracking: true,
              isThinking: _isThinking,
            ),
          ),
        ),
      ),
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: _HeroContent(
        isMobile: true,
        compact: compact,
        insertBetweenTitleAndBody: avatarWidget,
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final bool isMobile;
  final bool compact;
  /// En móvil: widget a mostrar entre el título y los botones (ej. el avatar del bot).
  final Widget? insertBetweenTitleAndBody;

  const _HeroContent({
    required this.isMobile,
    this.compact = false,
    this.insertBetweenTitleAndBody,
  });

  @override
  Widget build(BuildContext context) {
    final spacingTitle = compact ? 12.0 : 20.0;

    final titleBlock = [
      HeroTitle(isMobile: isMobile, compact: compact)
          .animate()
          .fadeIn(duration: 600.ms, delay: 100.ms)
          .slideY(begin: 0.1, end: 0),
      SizedBox(height: spacingTitle),
      HeroTitleUnderline(isMobile: isMobile)
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scaleX(begin: 0, end: 1),
    ];

    final bodyBlock = [
      SizedBox(height: compact ? 12 : 16),
      Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            GlowButton(
              text: 'CREAR MI BOT',
              icon: Icons.rocket_launch,
              onPressed: () => context.go(AppConstants.routeDemo),
            ),
            GlowButton(
              text: 'VER FACTORY',
              isOutlined: true,
              icon: Icons.factory,
              onPressed: () => context.go(AppConstants.routeFactory),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
    ];

    final children = <Widget>[
      ...titleBlock,
      if (insertBetweenTitleAndBody != null) ...[
        SizedBox(height: compact ? 16 : 24),
        insertBetweenTitleAndBody!,
        SizedBox(height: compact ? 16 : 24),
      ],
      ...bodyBlock,
    ];

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
