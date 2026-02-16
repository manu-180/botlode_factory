import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';

/// Reproductor de video dual (2 videos simultáneos) para el historial.
/// Diseñado para mostrar 2 videos lado a lado, incluso en móvil.
class DualVideoPlayer extends StatefulWidget {
  final String videoUrl1;
  final String videoUrl2;
  final String title;
  final Color accentColor;
  final VoidCallback? onClose;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const DualVideoPlayer({
    super.key,
    required this.videoUrl1,
    required this.videoUrl2,
    required this.title,
    this.accentColor = AppColors.primary,
    this.onClose,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  @override
  State<DualVideoPlayer> createState() => _DualVideoPlayerState();
}

class _DualVideoPlayerState extends State<DualVideoPlayer> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _isInitialized1 = false;
  bool _isInitialized2 = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  double _volume = 1.0; // Volumen del video 2 (el que tiene sonido)
  bool _showVolumeSlider = false;

  bool get _bothInitialized => _isInitialized1 && _isInitialized2;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    // Determinar si son assets locales o URLs externas
    // Video 1 (Dashboard - SIN SONIDO)
    if (widget.videoUrl1.startsWith('http://') || widget.videoUrl1.startsWith('https://')) {
      _controller1 = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl1));
    } else {
      _controller1 = VideoPlayerController.asset(widget.videoUrl1);
    }
    
    // Video 2 (Alertas - CON SONIDO)
    if (widget.videoUrl2.startsWith('http://') || widget.videoUrl2.startsWith('https://')) {
      _controller2 = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl2));
    } else {
      _controller2 = VideoPlayerController.asset(widget.videoUrl2);
    }
    
    try {
      await _controller1.initialize();
      // Configurar video 1 SIN sonido
      await _controller1.setVolume(0.0);
      
      // Configurar atributos HTML en web para ocultar controles nativos
      if (kIsWeb) {
        _configureVideoElementAttributes(_controller1);
      }
      
      if (mounted) {
        setState(() {
          _isInitialized1 = true;
        });
      }
    } catch (e) {
      debugPrint('Error al inicializar video 1: $e');
    }

    try {
      await _controller2.initialize();
      // Configurar video 2 CON sonido
      await _controller2.setVolume(1.0);
      
      // Configurar atributos HTML en web para ocultar controles nativos
      if (kIsWeb) {
        _configureVideoElementAttributes(_controller2);
      }
      
      if (mounted) {
        setState(() {
          _isInitialized2 = true;
        });
      }
    } catch (e) {
      debugPrint('Error al inicializar video 2: $e');
    }

    // Listeners para sincronización
    _controller1.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller1.value.isPlaying;
        });
      }
    });
  }

  /// Configurar atributos HTML del elemento video para ocultar controles nativos del navegador
  void _configureVideoElementAttributes(VideoPlayerController controller) {
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
    _hideControlsTimer?.cancel();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _onMouseMove() {
    // Mostrar controles
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }

    // Cancelar timer anterior
    _hideControlsTimer?.cancel();

    // Crear nuevo timer de 2 segundos
    _hideControlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    setState(() {
      if (_controller1.value.isPlaying) {
        _controller1.pause();
        _controller2.pause();
      } else {
        // Reproducir ambos simultáneamente
        _controller1.play();
        _controller2.play();
      }
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      // Solo el video 2 tiene sonido
      _controller2.setVolume(volume);
    });
  }

  IconData _getVolumeIcon() {
    if (_volume == 0) {
      return Icons.volume_off;
    } else if (_volume < 0.5) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return MouseRegion(
      onEnter: (_) => _onMouseMove(),
      onExit: (_) {
        _hideControlsTimer?.cancel();
        setState(() => _showControls = true);
      },
      onHover: (_) => _onMouseMove(),
      cursor: _showControls ? SystemMouseCursors.basic : SystemMouseCursors.none,
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Videos duales
            Expanded(
              child: _bothInitialized
                  ? _buildDualVideos(isMobile)
                  : _buildLoadingState(),
            ),

            // Controls
            if (_bothInitialized) _buildControls(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.accentColor.withValues(alpha: 0.15),
            AppColors.surface,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: widget.accentColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Indicator dual
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isPlaying ? AppColors.success : widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? AppColors.success : widget.accentColor)
                          .withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(
                onPlay: (c) => c.repeat(),
              ).fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),

              const SizedBox(width: 4),

              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isPlaying ? AppColors.success : widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? AppColors.success : widget.accentColor)
                          .withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(
                onPlay: (c) => c.repeat(),
              ).fadeIn(duration: 800.ms, delay: 400.ms).then().fadeOut(duration: 800.ms),
            ],
          ),

          const SizedBox(width: 12),

          // Badge DUAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              'DUAL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Close button
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: AppColors.textSecondary,
              onPressed: widget.onClose,
              tooltip: 'Cerrar',
            ),
        ],
      ),
    );
  }

  Widget _buildDualVideos(bool isMobile) {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Video 1: Dashboard/Historial (SIN SONIDO)
              Expanded(
                child: _buildSingleVideoPanel(
                  controller: _controller1,
                  label: 'Dashboard',
                  isLeft: true,
                  hasSound: false,
                ),
              ),

              // Divider
              Container(
                width: 2,
                height: double.infinity,
                color: widget.accentColor.withValues(alpha: 0.5),
              ),

              // Video 2: Alertas/Notificaciones (CON SONIDO)
              Expanded(
                child: _buildSingleVideoPanel(
                  controller: _controller2,
                  label: 'Alertas',
                  isLeft: false,
                  hasSound: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSingleVideoPanel({
    required VideoPlayerController controller,
    required String label,
    required bool isLeft,
    required bool hasSound,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        Center(
          child: controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: widget.accentColor,
                    ),
                  ),
                ),
        ),

        // Play button overlay (centrado en cada video) con auto-hide
        AnimatedOpacity(
          opacity: _showControls && !_isPlaying ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.background,
                  size: 40,
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: widget.accentColor,
              ),
              const SizedBox(width: 16),
              CircularProgressIndicator(
                color: widget.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando videos duales...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sincronizando reproducción',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final position = _controller1.value.position;
    final duration = _controller1.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            widget.accentColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: widget.accentColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Progress bar (sincronizada con video 1)
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: widget.accentColor,
              inactiveTrackColor: AppColors.borderGlass,
              thumbColor: widget.accentColor,
              overlayColor: widget.accentColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPosition = duration * value;
                _controller1.seekTo(newPosition);
                _controller2.seekTo(newPosition); // Sincronizar ambos
              },
            ),
          ),

          const SizedBox(height: 8),

          // Controls row
          Row(
            children: [
              // Play/Pause
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: widget.accentColor,
                onPressed: _togglePlayPause,
                iconSize: 32,
              ),

              const SizedBox(width: 16),

              // Time
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
              ),

              const Spacer(),

              // Volume control con slider
              MouseRegion(
                onEnter: (_) => setState(() => _showVolumeSlider = true),
                onExit: (_) => setState(() => _showVolumeSlider = false),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Slider horizontal
                    if (_showVolumeSlider)
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: widget.accentColor,
                            inactiveTrackColor: AppColors.borderGlass,
                            thumbColor: widget.accentColor,
                            overlayColor: widget.accentColor.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: _setVolume,
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms).slideX(
                        begin: 0.5,
                        end: 0,
                        duration: 200.ms,
                      ),
                    
                    // Icono de volumen
                    IconButton(
                      icon: Icon(_getVolumeIcon()),
                      color: widget.accentColor,
                      onPressed: () {
                        // Toggle mute/unmute
                        if (_volume > 0) {
                          _setVolume(0);
                        } else {
                          _setVolume(1.0);
                        }
                      },
                      iconSize: 24,
                      tooltip: _volume == 0 ? 'Activar sonido' : 'Silenciar',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Sync indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sync,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SINCRONIZADO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Fullscreen toggle
              IconButton(
                icon: Icon(
                  widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
                color: widget.accentColor,
                onPressed: widget.onToggleFullscreen,
                iconSize: 24,
                tooltip: widget.isFullscreen ? 'Salir de pantalla completa' : 'Pantalla completa',
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
