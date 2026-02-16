import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/footer.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../domain/entities/tutorial_video.dart';
import '../providers/tutorial_provider.dart';
import '../widgets/html_dual_video_player.dart';
import '../widgets/html_video_player.dart';
import '../widgets/video_thumbnail_widget.dart';

/// Vista de la página Tutorial - Videos y guías.
/// Usa Riverpod para gestionar el estado del filtrado.
class TutorialView extends ConsumerWidget {
  const TutorialView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final state = ref.watch(tutorialProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero
          const _TutorialHero(),

          // Grid de videos premium (sin filtros)
          _VideoGrid(
            videos: state.allVideos,
            isMobile: isMobile,
          ),

          const SizedBox(height: 64),

          // Footer al final del scroll
          const Footer(),
        ],
      ),
    );
  }
}

/// Hero de Tutorial
class _TutorialHero extends StatelessWidget {
  const _TutorialHero();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing4xl,
      ),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.5,
          colors: [
            AppColors.happy.withValues(alpha: 0.08),
            AppColors.background,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              // Icono
              Container(
                width: isMobile ? 80 : 100,
                height: isMobile ? 80 : 100,
                decoration: BoxDecoration(
                  color: AppColors.happy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.happy.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.play_circle_filled,
                  size: isMobile ? 40 : 50,
                  color: AppColors.happy,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

              const SizedBox(height: 32),

              const SectionTitle(
                tag: 'Domina la Tecnología',
                title: 'Guías en Video Premium',
                subtitle:
                    'Tres tutoriales esenciales que te llevan de cero a experto. Aprende a crear, integrar y gestionar tu ecosistema de bots IA en minutos.',
                accentColor: AppColors.happy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filtro de categorías
/// Grid de videos premium
class _VideoGrid extends StatelessWidget {
  final List<TutorialVideo> videos;
  final bool isMobile;

  const _VideoGrid({
    required this.videos,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive: 1 columna móvil, 2 tablet, 3 desktop
    final crossAxisCount = isMobile ? 1 : (screenWidth < 1024 ? 2 : 3);
    // Aspect ratio más bajo = celdas más altas (más espacio para video e info, evita overflow)
    final childAspectRatio = isMobile ? 0.62 : (screenWidth < 1024 ? 0.68 : 0.72);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing3xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: videos.isEmpty
              ? const _EmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 32,
                    crossAxisSpacing: 32,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return GlowBorderCard(
                      glowColor: AppColors.primary,
                      enableHoverScale: false,
                      padding: EdgeInsets.zero,
                      child: _PremiumVideoCard(
                        video: videos[index],
                        delay: index * 150,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// Dialog con estado para manejar fullscreen
class _VideoPlayerDialog extends StatefulWidget {
  final TutorialVideo video;

  const _VideoPlayerDialog({required this.video});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  bool _isFullscreen = false;

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(_isFullscreen ? 0 : (isMobile ? 12 : 32)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isFullscreen 
            ? double.infinity 
            : (widget.video.isDualVideo ? (isMobile ? double.infinity : 1600) : 900),
          maxHeight: _isFullscreen 
            ? double.infinity 
            : (isMobile ? double.infinity : (widget.video.isDualVideo ? 800 : 700)),
        ),
        child: widget.video.isDualVideo
            ? HtmlDualVideoPlayer(
                videoUrl1: widget.video.videoUrl!,
                videoUrl2: widget.video.videoUrl2!,
                title: widget.video.title,
                accentColor: AppColors.happy,
                onClose: () => Navigator.of(context).pop(),
                onToggleFullscreen: _toggleFullscreen,
                isFullscreen: _isFullscreen,
              )
            : HtmlVideoPlayer(
                videoUrl: widget.video.videoUrl!,
                title: widget.video.title,
                accentColor: AppColors.primary,
                onClose: () => Navigator.of(context).pop(),
                onToggleFullscreen: _toggleFullscreen,
                isFullscreen: _isFullscreen,
              ),
      ),
    );
  }
}

/// Card premium de video con efecto WOW
class _PremiumVideoCard extends StatefulWidget {
  final TutorialVideo video;
  final int delay;

  const _PremiumVideoCard({required this.video, required this.delay});

  @override
  State<_PremiumVideoCard> createState() => _PremiumVideoCardState();
}

class _PremiumVideoCardState extends State<_PremiumVideoCard> {
  bool _isHovered = false;
  bool _showPlayButton = true;
  Timer? _hideButtonTimer;

  @override
  void dispose() {
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  void _onMouseMove() {
    // Mostrar el botón cuando el mouse se mueve
    if (!_showPlayButton) {
      setState(() {
        _showPlayButton = true;
      });
    }

    // Cancelar timer anterior
    _hideButtonTimer?.cancel();

    // Crear nuevo timer de 2 segundos
    _hideButtonTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showPlayButton = false;
        });
      }
    });
  }

  void _onMouseExit() {
    // Ocultar el botón cuando el mouse sale
    _hideButtonTimer?.cancel();
    setState(() {
      _showPlayButton = false;
    });
  }

  void _openVideoPlayer(BuildContext context) {
    if (!widget.video.isAvailable || widget.video.videoUrl == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return _VideoPlayerDialog(video: widget.video);
      },
    );
  }

  static Widget _thumbnailFallback(BuildContext context, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  static Widget _durationChip(BuildContext context, String durationText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            durationText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;

        return MouseRegion(
          onEnter: hasValidSize
              ? (_) {
                  setState(() => _isHovered = true);
                  _onMouseMove();
                }
              : null,
          onExit: hasValidSize
              ? (_) {
                  setState(() => _isHovered = false);
                  _onMouseExit();
                }
              : null,
          onHover: hasValidSize ? (_) => _onMouseMove() : null,
          cursor: widget.video.isAvailable
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.video.isAvailable
                ? () => _openVideoPlayer(context)
                : null,
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              transform: Matrix4.translationValues(
                0.0,
                _isHovered && widget.video.isAvailable ? -8.0 : 0.0,
                0.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                // Sin border ni boxShadow: GlowBorderCard aporta el único borde con
                // elevación y glow que sigue el mouse (como en el resto de la web)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail premium con primer frame del video
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          // Primer frame del video como thumbnail (dual: no cargar asset para evitar MEDIA_ERR_SRC_NOT_SUPPORTED)
                          if (widget.video.videoUrl != null)
                            Positioned.fill(
                              child: widget.video.isDualVideo
                                  ? _thumbnailFallback(
                                      context,
                                      widget.video.thumbnail,
                                    )
                                  : VideoThumbnailWidget(
                                      videoUrl: widget.video.videoUrl!,
                                      fallbackIcon: widget.video.thumbnail,
                                      accentColor: AppColors.primary,
                                      staticThumbnail: widget.video.thumbnailImage,
                                    ),
                            ),

                          // Overlay oscuro semi-transparente
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Play button premium con auto-hide
                          if (widget.video.isAvailable)
                            AnimatedOpacity(
                              opacity: _showPlayButton ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Center(
                                child: AnimatedScale(
                                  scale: _isHovered ? 1.1 : 1.0,
                                  duration: AppConstants.durationFast,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.6),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: AppColors.background,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),


                          // Duración: para dual usamos texto estático para no cargar el video (formato puede no ser soportado en web)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: widget.video.isDualVideo
                                ? _durationChip(context, widget.video.duration)
                                : VideoMetadataProvider(
                                    videoUrl: widget.video.videoUrl ?? '',
                                    builder: (context, duration, isLoading) {
                                      String durationText = widget.video.duration;
                                      if (!isLoading && duration != null) {
                                        final minutes = duration.inMinutes;
                                        final seconds = duration.inSeconds.remainder(60);
                                        durationText = '$minutes:${seconds.toString().padLeft(2, '0')}';
                                      }
                                      return _durationChip(context, durationText);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Info premium: padding responsive y contenido flexible para evitar overflow
                    Expanded(
                      flex: 4,
                      child: LayoutBuilder(
                        builder: (context, infoConstraints) {
                          final isCompact = infoConstraints.maxHeight < 140;
                          final padding = isCompact ? 12.0 : 20.0;
                          return Container(
                            padding: EdgeInsets.all(padding),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.surface,
                                  AppColors.background,
                                ],
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.borderGlass,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Título
                                Text(
                                  widget.video.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                            fontSize: isCompact ? 14 : null,
                                          ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: isCompact ? 6 : 12),

                                // Descripción (flexible para no desbordar)
                                Flexible(
                                  child: Text(
                                    widget.video.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                              fontSize: isCompact ? 11 : null,
                                            ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                SizedBox(height: isCompact ? 6 : 12),

                                // CTA
                                Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle_filled,
                                      size: isCompact ? 16 : 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'VER AHORA',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
        ).slideY(begin: 0.15, end: 0);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay videos en esta categoría',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
