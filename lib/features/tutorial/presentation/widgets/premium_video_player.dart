import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_colors.dart';

/// Reproductor de video premium con controles personalizados y estética sci-fi.
class PremiumVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final Color accentColor;
  final VoidCallback? onClose;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const PremiumVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.accentColor = AppColors.primary,
    this.onClose,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  @override
  State<PremiumVideoPlayer> createState() => _PremiumVideoPlayerState();
}

class _PremiumVideoPlayerState extends State<PremiumVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isHovering = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  double _volume = 1.0;
  bool _showVolumeSlider = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Determinar si es asset local o URL externa
    if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }
    
    try {
      await _controller.initialize();
      
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
      debugPrint('Error al inicializar video: $e');
    }

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
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
    _hideControlsTimer?.cancel();
    _controller.dispose();
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

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _controller.setVolume(volume);
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _onMouseMove();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hideControlsTimer?.cancel();
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

              // Video
              Expanded(
                child: _isInitialized
                    ? _buildVideoPlayer()
                    : _buildLoadingState(),
              ),

              // Controls
              if (_isInitialized) _buildControls(),
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
          // Indicator
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

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Play/Pause overlay con auto-hide
          AnimatedOpacity(
            opacity: _showControls && (!_isPlaying || _isHovering) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.background,
                size: 48,
              ),
            ).animate(
              target: _isPlaying ? 0 : 1,
            ).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 300.ms,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: widget.accentColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando video premium...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
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
          // Progress bar
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
                _controller.seekTo(newPosition);
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
                    // Slider vertical
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

              const SizedBox(width: 8),

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
