import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_colors.dart';

/// Reproductor de video usando HTML5 Video Element directamente
/// para evitar controles nativos del navegador
class HtmlVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final Color accentColor;
  final VoidCallback? onClose;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const HtmlVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.accentColor = AppColors.primary,
    this.onClose,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  @override
  State<HtmlVideoPlayer> createState() => _HtmlVideoPlayerState();
}

class _HtmlVideoPlayerState extends State<HtmlVideoPlayer> {
  static int _viewCounter = 0;
  late String _viewId;
  late html.VideoElement _videoElement;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  double _volume = 1.0;
  bool _showVolumeSlider = false;
  double _progress = 0.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _progressTimer;
  static final Set<String> _registeredViews = {};

  /// Convierte clave de asset Flutter a URL absoluta para web (evita /assets/assets/assets/).
  static String _resolveVideoSrc(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('/')) {
      return url;
    }
    return '/assets/$url';
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'tutorial-video-player-${_viewCounter++}';
    _registerVideoElement();
    
    // Timer para actualizar el progreso
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && _isInitialized) {
        setState(() {
          _position = Duration(seconds: _videoElement.currentTime.toInt());
          _duration = Duration(seconds: _videoElement.duration.toInt());
          if (_duration.inSeconds > 0) {
            _progress = _position.inSeconds / _duration.inSeconds;
          }
        });
      }
    });
  }

  void _registerVideoElement() {
    if (_registeredViews.contains(_viewId)) return;
    _registeredViews.add(_viewId);

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        // Crear elemento de video optimizado para móvil
        _videoElement = html.VideoElement()
          ..src = _resolveVideoSrc(widget.videoUrl)
          ..controls = false
          ..preload = 'auto'
          ..muted = false  // Con sonido (usuario toca play, puede tener sonido)
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain'
          ..style.objectPosition = 'center center'
          ..style.display = 'block'
          ..style.border = 'none'
          ..style.outline = 'none'
          ..style.margin = '0'
          ..style.padding = '0'
          ..style.backgroundColor = '#000000'
          ..setAttribute('playsinline', 'true')
          ..setAttribute('webkit-playsinline', 'true')
          ..setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
          ..setAttribute('disablePictureInPicture', 'true');

        // Listeners
        _videoElement.onLoadedMetadata.listen((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _duration = Duration(seconds: _videoElement.duration.toInt());
            });
          }
        });

        _videoElement.onPlay.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = true);
          }
        });

        _videoElement.onPause.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        });

        _videoElement.onVolumeChange.listen((_) {
          if (mounted) {
            setState(() {
              _volume = _videoElement.volume.toDouble();
            });
          }
        });

        return _videoElement;
      },
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _progressTimer?.cancel();
    _videoElement.pause();
    super.dispose();
  }

  void _onMouseMove() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_videoElement.paused) {
      // Play defensivo: manejar promesa y errores (móvil puede bloquear)
      _videoElement.play().catchError((e) {
        debugPrint('⚠️ Error al reproducir video: $e');
      });
    } else {
      _videoElement.pause();
    }
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _videoElement.volume = volume;
    });
  }

  void _seek(double value) {
    final newPosition = _duration.inSeconds * value;
    _videoElement.currentTime = newPosition.toDouble();
  }

  IconData _getVolumeIcon() {
    if (_volume == 0) return Icons.volume_off;
    if (_volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
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

              // Video
              Expanded(
                child: Stack(
                  children: [
                    // Video player
                    Container(
                      color: Colors.black,
                      child: HtmlElementView(
                        key: ValueKey(_viewId),
                        viewType: _viewId,
                      ),
                    ),

                    // Play button overlay
                    if (!_isPlaying)
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
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
                              child: const Icon(
                                Icons.play_arrow,
                                color: AppColors.background,
                                size: 48,
                              ),
                            ).animate().scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                              duration: 500.ms,
                            ),
                          ),
                        ),
                      ),

                    // Click to play/pause
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildControls() {
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
                value: _progress.clamp(0.0, 1.0),
                onChanged: _seek,
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
                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                ),

                const Spacer(),

                // Volume control
                MouseRegion(
                  onEnter: (_) => setState(() => _showVolumeSlider = true),
                  onExit: (_) => setState(() => _showVolumeSlider = false),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      
                      IconButton(
                        icon: Icon(_getVolumeIcon()),
                        color: widget.accentColor,
                        onPressed: () {
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
                if (widget.onToggleFullscreen != null)
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
