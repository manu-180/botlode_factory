import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';

/// Reproductor dual usando HTML5 Video Elements directamente
class HtmlDualVideoPlayer extends StatefulWidget {
  final String videoUrl1;
  final String videoUrl2;
  final String title;
  final Color accentColor;
  final VoidCallback? onClose;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const HtmlDualVideoPlayer({
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
  State<HtmlDualVideoPlayer> createState() => _HtmlDualVideoPlayerState();
}

class _HtmlDualVideoPlayerState extends State<HtmlDualVideoPlayer> {
  static int _viewCounter = 0;
  late String _viewId1;
  late String _viewId2;
  html.VideoElement? _videoElement1;
  html.VideoElement? _videoElement2;
  bool _isInitialized1 = false;
  bool _isInitialized2 = false;
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

  bool get _bothInitialized => _isInitialized1 && _isInitialized2;

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
    _viewId1 = 'tutorial-dual-video-1-${_viewCounter}';
    _viewId2 = 'tutorial-dual-video-2-${_viewCounter++}';
    _registerVideoElement1();
    _registerVideoElement2();
    
    // Timer para actualizar el progreso (solo usar duration cuando sea válida: evita NaN antes de metadata)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final v1 = _videoElement1;
      if (!mounted || !_bothInitialized || v1 == null) return;
      final d = v1.duration;
      final durationValid = d.isFinite && d > 0;
      final newPosition = Duration(seconds: v1.currentTime.toInt().clamp(0, 0x7FFFFFFF));
      final newDuration = durationValid ? Duration(seconds: d.toInt()) : _duration;
      final newProgress = newDuration.inSeconds > 0
          ? (newPosition.inSeconds / newDuration.inSeconds).clamp(0.0, 1.0)
          : _progress;
      if (newPosition != _position || newDuration != _duration || (newProgress - _progress).abs() > 0.001) {
        setState(() {
          _position = newPosition;
          if (durationValid) _duration = newDuration;
          _progress = newProgress;
        });
      }
    });
  }

  void _registerVideoElement1() {
    if (_registeredViews.contains(_viewId1)) return;
    _registeredViews.add(_viewId1);

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId1,
      (int viewId) {
        final videoElement1 = html.VideoElement()
          ..src = _resolveVideoSrc(widget.videoUrl1)
          ..controls = false
          ..preload = 'auto'
          ..muted = true  // Video 1 sin sonido (compatible con autoplay móvil)
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

        _videoElement1 = videoElement1;

        videoElement1.onLoadedMetadata.listen((_) {
          if (mounted) {
            final d = videoElement1.duration;
            setState(() {
              _isInitialized1 = true;
              if (d.isFinite && d > 0) {
                _duration = Duration(seconds: d.toInt());
              }
            });
          }
        });

        videoElement1.onPlay.listen((_) {
          if (mounted) setState(() => _isPlaying = true);
        });

        videoElement1.onPause.listen((_) {
          if (mounted) setState(() => _isPlaying = false);
        });

        videoElement1.onError.listen((_) {
          if (mounted) setState(() => _isInitialized1 = true);
        });

        return videoElement1;
      },
    );
  }

  void _registerVideoElement2() {
    if (_registeredViews.contains(_viewId2)) return;
    _registeredViews.add(_viewId2);

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId2,
      (int viewId) {
        final videoElement2 = html.VideoElement()
          ..src = _resolveVideoSrc(widget.videoUrl2)
          ..controls = false
          ..preload = 'auto'
          ..muted = false  // Video 2 con sonido
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

        _videoElement2 = videoElement2;

        videoElement2.onLoadedMetadata.listen((_) {
          if (mounted) {
            setState(() => _isInitialized2 = true);
          }
        });

        videoElement2.onVolumeChange.listen((_) {
          if (mounted) {
            setState(() => _volume = videoElement2.volume.toDouble());
          }
        });

        videoElement2.onError.listen((_) {
          if (mounted) setState(() => _isInitialized2 = true);
        });

        return videoElement2;
      },
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _progressTimer?.cancel();
    _videoElement1?.pause();
    _videoElement2?.pause();
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

  Future<void> _togglePlayPause() async {
    final v1 = _videoElement1;
    final v2 = _videoElement2;
    if (v1 == null || v2 == null) return;
    if (v1.paused) {
      // Ejecutar play fuera del frame actual para no bloquear la UI si el navegador tarda o falla
      Future.microtask(() async {
        if (!mounted) return;
        bool play1Ok = true;
        bool play2Ok = true;
        try {
          await v1.play().catchError((e) {
            debugPrint('⚠️ Error al reproducir video 1: $e');
            play1Ok = false;
            return null;
          });
        } catch (e) {
          debugPrint('⚠️ Error al reproducir video 1 (sync): $e');
          play1Ok = false;
        }
        if (!mounted) return;
        try {
          await v2.play().catchError((e) {
            debugPrint('⚠️ Error al reproducir video 2: $e');
            play2Ok = false;
            return null;
          });
        } catch (e) {
          debugPrint('⚠️ Error al reproducir video 2 (sync): $e');
          play2Ok = false;
        }
        if (mounted && context.mounted && (!play1Ok || !play2Ok)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No se pudo reproducir el video. Comprueba que el formato sea compatible (p. ej. MP4 H.264) en tu navegador.',
              ),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } else {
      v1.pause();
      v2.pause();
    }
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _videoElement2?.volume = volume;  // Solo el video 2 tiene sonido
    });
  }

  void _seek(double value) {
    final newPosition = _duration.inSeconds * value;
    _videoElement1?.currentTime = newPosition.toDouble();
    _videoElement2?.currentTime = newPosition.toDouble();
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

              // Videos duales (siempre renderizados para permitir carga)
              Expanded(
                child: _buildDualVideos(isMobile),
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
      child: Stack(
        children: [
          // Los HtmlElementView SIEMPRE se renderizan para que el factory
          // callback cree los VideoElement y dispare onLoadedMetadata.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Video 1: Dashboard
              Expanded(
                child: HtmlElementView(
                  key: ValueKey(_viewId1),
                  viewType: _viewId1,
                ),
              ),

              // Divider
              Container(
                width: 2,
                height: double.infinity,
                color: widget.accentColor.withValues(alpha: 0.5),
              ),

              // Video 2: Alertas
              Expanded(
                child: HtmlElementView(
                  key: ValueKey(_viewId2),
                  viewType: _viewId2,
                ),
              ),
            ],
          ),

          // Loading overlay mientras los videos cargan
          if (!_bothInitialized)
            Positioned.fill(
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: widget.accentColor),
                          const SizedBox(width: 16),
                          CircularProgressIndicator(color: widget.accentColor),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cargando videos duales...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Play button overlay (solo cuando ya cargaron ambos)
          if (_bothInitialized && !_isPlaying)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
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
                ),
              ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                ),
              ),
            ),

          // Click-to-play/pause en toda el área (solo cuando ya cargaron)
          if (_bothInitialized)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(color: Colors.transparent),
              ),
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
                      const Icon(Icons.sync, size: 16, color: AppColors.success),
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
