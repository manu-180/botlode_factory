import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rive/rive.dart' as rive;

import '../../core/config/app_colors.dart';
import '../../core/providers/rive_loader_provider.dart';
import '../../core/providers/head_tracking_provider.dart';
import '../../core/providers/bot_mood_provider.dart';

/// Detecta si el dispositivo es táctil (móvil/tablet).
/// En dispositivos táctiles el mouse tracking no tiene sentido.
/// Umbral 768: solo desactivar en móvil; ventanas 768–1024 (ej. pantalla partida) siguen con tracking.
bool _isTouchDevice() {
  try {
    final data = WidgetsBinding.instance.platformDispatcher;
    final view = data.views.first;
    final width = view.physicalSize.width / view.devicePixelRatio;
    return width < 768;
  } catch (_) {
    return false;
  }
}

/// Avatar Rive del bot con seguimiento de mouse GLOBAL.
///
/// OPTIMIZACIÓN v2:
/// - Ticker throttled a ~20fps (cada 3 frames) en vez de 60fps
/// - Cachea RenderBox para no hacer findRenderObject cada frame
/// - Desactiva mouse tracking automáticamente en dispositivos táctiles
class RiveBotAvatar extends ConsumerStatefulWidget {
  final double size;
  final bool useHead;
  final Color glowColor;
  final bool enableMouseTracking;
  final double sensitivity;
  final double maxDistance;
  /// Cuando true, muestra el círculo de "cargando" en la cara (input Download en Rive), como en botlode_player
  final bool isThinking;
  /// Índice de emoción para el input Mood del Rive (0=neutral, 1=angry, 2=happy, 3=sales, 4=confused, 5=tech)
  final int moodIndex;

  const RiveBotAvatar({
    super.key,
    this.size = 300,
    this.useHead = false,
    this.glowColor = AppColors.primary,
    this.enableMouseTracking = true,
    this.sensitivity = 400.0,
    this.maxDistance = 400.0,
    this.isThinking = false,
    this.moodIndex = 0,
  });

  @override
  ConsumerState<RiveBotAvatar> createState() => _RiveBotAvatarState();
}

class _RiveBotAvatarState extends ConsumerState<RiveBotAvatar> 
    with SingleTickerProviderStateMixin {
  rive.StateMachineController? _controller;
  rive.SMINumber? _lookX;
  rive.SMINumber? _lookY;
  rive.SMINumber? _mood;
  rive.SMINumber? _download;

  Ticker? _ticker;
  
  double _targetX = 50.0;
  double _targetY = 50.0;
  double _currentX = 50.0;
  double _currentY = 50.0;
  
  bool _isTracking = false;
  bool _wasTrackingPreviously = false;
  int _trackingFrames = 0;

  /// Throttle: solo procesar cada N frames (~20fps en vez de 60fps)
  int _frameCount = 0;
  static const int _frameSkip = 3; // Procesar cada 3 frames = ~20fps

  /// Cache del RenderBox para no hacer findRenderObject cada frame
  RenderBox? _cachedRenderBox;
  int _renderBoxCacheFrames = 0;
  static const int _renderBoxCacheInterval = 15; // Refrescar cada 15 frames (~4 veces/seg)

  /// Determina si el tracking está efectivamente habilitado
  late final bool _effectiveMouseTracking;

  @override
  void initState() {
    super.initState();
    // Desactivar mouse tracking en dispositivos táctiles
    _effectiveMouseTracking = widget.enableMouseTracking && !_isTouchDevice();
    
    if (_effectiveMouseTracking) {
      _ticker = createTicker(_onTick)..start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller?.dispose();
    _cachedRenderBox = null;
    super.dispose();
  }

  /// Obtener RenderBox con cache para reducir llamadas a findRenderObject
  RenderBox? _getRenderBox() {
    _renderBoxCacheFrames++;
    if (_cachedRenderBox == null || _renderBoxCacheFrames >= _renderBoxCacheInterval) {
      _renderBoxCacheFrames = 0;
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize && renderObject.attached) {
        _cachedRenderBox = renderObject;
      }
    }
    return _cachedRenderBox;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lookX == null || _lookY == null) return;

    // THROTTLE: Solo calcular tracking cada N frames
    _frameCount++;
    if (_frameCount < _frameSkip) {
      // Aun así interpolar suavemente hacia el target en cada frame
      _interpolateAndUpdate();
      return;
    }
    _frameCount = 0;

    // Calcular tracking (solo cada ~20fps)
    if (_effectiveMouseTracking) {
      try {
        final globalPointer = ref.read(globalPointerPositionProvider);
        
        final box = _getRenderBox();
        if (box == null) return;
        
        final widgetCenter = Offset(
          box.localToGlobal(Offset.zero).dx + box.size.width / 2,
          box.localToGlobal(Offset.zero).dy + box.size.height / 2,
        );

        final trackingState = HeadTrackingController.calculateGlobalTracking(
          globalPointer: globalPointer,
          widgetCenter: widgetCenter,
          sensitivity: widget.sensitivity,
          maxDistance: widget.maxDistance,
        );

        _targetX = trackingState.targetX;
        _targetY = trackingState.targetY;
        _isTracking = trackingState.isTracking;
        
        if (_isTracking && !_wasTrackingPreviously) {
          _trackingFrames = 0;
        }
        
        if (_isTracking) {
          _trackingFrames++;
        } else {
          _trackingFrames = 0;
        }
        
        _wasTrackingPreviously = _isTracking;
      } catch (e) {
        _targetX = 50.0;
        _targetY = 50.0;
        _isTracking = false;
        _wasTrackingPreviously = false;
        _trackingFrames = 0;
        return;
      }
    }

    _interpolateAndUpdate();
  }

  /// Interpola suavemente hacia el target y actualiza Rive.
  /// Se ejecuta cada frame para mantener animación fluida aunque
  /// el cálculo de tracking sea throttled.
  void _interpolateAndUpdate() {
    double smoothFactor;
    if (_isTracking) {
      if (_trackingFrames < 10) {
        smoothFactor = 0.15;
      } else {
        smoothFactor = 1.0;
      }
    } else {
      smoothFactor = 0.05;
    }

    double calibratedTargetY = _targetY - 15.0; 
    calibratedTargetY = calibratedTargetY.clamp(0.0, 100.0);

    _currentX = lerpDouble(_currentX, _targetX, smoothFactor) ?? 50;
    _currentY = lerpDouble(_currentY, calibratedTargetY, smoothFactor) ?? 50;

    try {
      _lookX?.value = _currentX;
      _lookY?.value = _currentY;
    } catch (e) {
      // Ignorar errores si el controlador ya fue disposed
    }
  }

  void _onRiveInit(rive.Artboard artboard) {
    if (!mounted) return;
    
    try {
      rive.StateMachineController? controller;
      controller = rive.StateMachineController.fromArtboard(artboard, 'State Machine 1');
      controller ??= rive.StateMachineController.fromArtboard(artboard, 'State Machine');

      if (controller != null) {
        artboard.addController(controller);
        _controller = controller;

        _lookX = controller.getNumberInput('LookX');
        _lookY = controller.getNumberInput('LookY');
        _mood = controller.getNumberInput('Mood');
        _download = controller.getNumberInput('Download');

        final moodValue = widget.isThinking ? 0.0 : widget.moodIndex.clamp(0, 5).toDouble();
        _mood?.value = moodValue;
        _lookX?.value = 50;
        _lookY?.value = 50;
        _download?.value = widget.isThinking ? 1.0 : 0.0;
        
        if (!_effectiveMouseTracking) {
          _currentX = 50.0;
          _currentY = 50.0;
          _targetX = 50.0;
          _targetY = 50.0;
        }
      }
    } catch (e) {
      debugPrint('Error inicializando Rive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar círculo de "cargando" y mood
    if (_download != null) {
      _download!.value = widget.isThinking ? 1.0 : 0.0;
    }
    if (_mood != null) {
      _mood!.value = widget.isThinking ? 0.0 : widget.moodIndex.clamp(0, 5).toDouble();
    }

    final riveAsync = widget.useHead
        ? ref.watch(riveHeadFileLoaderProvider)
        : ref.watch(riveFileLoaderProvider);

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: riveAsync.when(
          data: (riveFile) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: rive.RiveAnimation.direct(
                riveFile,
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (_, __) => _buildErrorState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            widget.glowColor.withValues(alpha: 0.15),
            AppColors.background.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: widget.glowColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.glowColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: FaIcon(
        FontAwesomeIcons.robot,
        size: widget.size * 0.5,
        color: widget.glowColor,
      ),
    );
  }
}

/// Avatar interactivo con modos y tracking GLOBAL
class InteractiveRiveBotAvatar extends ConsumerStatefulWidget {
  final double size;
  final int initialMood;
  final Color glowColor;
  final Function(int)? onMoodChange;
  final double sensitivity;
  final double maxDistance;

  const InteractiveRiveBotAvatar({
    super.key,
    this.size = 300,
    this.initialMood = 0,
    this.glowColor = AppColors.primary,
    this.onMoodChange,
    this.sensitivity = 400.0,
    this.maxDistance = 400.0,
  });

  @override
  ConsumerState<InteractiveRiveBotAvatar> createState() =>
      _InteractiveRiveBotAvatarState();
}

class _InteractiveRiveBotAvatarState
    extends ConsumerState<InteractiveRiveBotAvatar> 
    with SingleTickerProviderStateMixin {
  rive.StateMachineController? _controller;
  rive.SMINumber? _lookX;
  rive.SMINumber? _lookY;
  rive.SMINumber? _mood;

  Ticker? _ticker;
  
  double _targetX = 50.0;
  double _targetY = 50.0;
  double _currentX = 50.0;
  double _currentY = 50.0;
  
  bool _isTracking = false;
  bool _wasTrackingPreviously = false;
  int _trackingFrames = 0;

  /// Throttle: solo procesar cada N frames (~20fps en vez de 60fps)
  int _frameCount = 0;
  static const int _frameSkip = 3;

  /// Cache del RenderBox
  RenderBox? _cachedRenderBox;
  int _renderBoxCacheFrames = 0;
  static const int _renderBoxCacheInterval = 15;

  /// Determina si el tracking está efectivamente habilitado
  late final bool _effectiveMouseTracking;

  static const List<Map<String, dynamic>> moods = [
    {'name': 'Neutral', 'color': AppColors.success, 'value': 0, 'icon': Icons.sentiment_neutral},
    {'name': 'Enojado', 'color': AppColors.angry, 'value': 1, 'icon': Icons.warning_amber},
    {'name': 'Feliz', 'color': AppColors.happy, 'value': 2, 'icon': Icons.sentiment_very_satisfied},
    {'name': 'Vendedor', 'color': AppColors.sales, 'value': 3, 'icon': Icons.shopping_cart},
    {'name': 'Confundido', 'color': AppColors.confused, 'value': 4, 'icon': Icons.help_outline},
    {'name': 'Técnico', 'color': AppColors.techCyan, 'value': 5, 'icon': Icons.code},
  ];

  @override
  void initState() {
    super.initState();
    _effectiveMouseTracking = !_isTouchDevice();
    
    if (_effectiveMouseTracking) {
      _ticker = createTicker(_onTick)..start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller?.dispose();
    _cachedRenderBox = null;
    super.dispose();
  }

  /// Obtener RenderBox con cache
  RenderBox? _getRenderBox() {
    _renderBoxCacheFrames++;
    if (_cachedRenderBox == null || _renderBoxCacheFrames >= _renderBoxCacheInterval) {
      _renderBoxCacheFrames = 0;
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize && renderObject.attached) {
        _cachedRenderBox = renderObject;
      }
    }
    return _cachedRenderBox;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lookX == null || _lookY == null) return;

    // THROTTLE: Solo calcular tracking cada N frames
    _frameCount++;
    if (_frameCount < _frameSkip) {
      _interpolateAndUpdate();
      return;
    }
    _frameCount = 0;

    try {
      final globalPointer = ref.read(globalPointerPositionProvider);
      
      final box = _getRenderBox();
      if (box == null) return;
      
      final widgetCenter = Offset(
        box.localToGlobal(Offset.zero).dx + box.size.width / 2,
        box.localToGlobal(Offset.zero).dy + box.size.height / 2,
      );

      final trackingState = HeadTrackingController.calculateGlobalTracking(
        globalPointer: globalPointer,
        widgetCenter: widgetCenter,
        sensitivity: widget.sensitivity,
        maxDistance: widget.maxDistance,
      );

      _targetX = trackingState.targetX;
      _targetY = trackingState.targetY;
      _isTracking = trackingState.isTracking;
      
      if (_isTracking && !_wasTrackingPreviously) {
        _trackingFrames = 0;
      }
      
      if (_isTracking) {
        _trackingFrames++;
      } else {
        _trackingFrames = 0;
      }
      
      _wasTrackingPreviously = _isTracking;
    } catch (e) {
      _targetX = 50.0;
      _targetY = 50.0;
      _isTracking = false;
      _wasTrackingPreviously = false;
      _trackingFrames = 0;
      return;
    }

    _interpolateAndUpdate();
  }

  /// Interpola suavemente hacia el target y actualiza Rive
  void _interpolateAndUpdate() {
    double smoothFactor;
    if (_isTracking) {
      if (_trackingFrames < 10) {
        smoothFactor = 0.15;
      } else {
        smoothFactor = 1.0;
      }
    } else {
      smoothFactor = 0.05;
    }

    double calibratedTargetY = _targetY - 15.0; 
    calibratedTargetY = calibratedTargetY.clamp(0.0, 100.0);

    _currentX = lerpDouble(_currentX, _targetX, smoothFactor) ?? 50;
    _currentY = lerpDouble(_currentY, calibratedTargetY, smoothFactor) ?? 50;

    try {
      _lookX?.value = _currentX;
      _lookY?.value = _currentY;
    } catch (e) {
      // Ignorar errores si el controlador ya fue disposed
    }
  }

  void _onRiveInit(rive.Artboard artboard) {
    if (!mounted) return;
    
    rive.StateMachineController? controller;
    controller = rive.StateMachineController.fromArtboard(artboard, 'State Machine 1');
    controller ??= rive.StateMachineController.fromArtboard(artboard, 'State Machine');

    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;

      _lookX = controller.getNumberInput('LookX');
      _lookY = controller.getNumberInput('LookY');
      _mood = controller.getNumberInput('Mood');

      try {
        final mood = ref.read(botMoodProvider).clamp(0, 5);
        _mood?.value = mood.toDouble();
        _lookX?.value = 50;
        _lookY?.value = 50;
      } catch (e) {
        // Ignorar errores de inicialización
      }
    }
  }

  void _changeMood(int moodValue) {
    if (!mounted) return;
    final current = ref.read(botMoodProvider);
    if (current == moodValue) return;
    ref.read(botMoodProvider.notifier).state = moodValue;
    try {
      _mood?.value = moodValue.toDouble();
    } catch (e) {
      // Ignorar errores si el controlador ya fue disposed
    }
    widget.onMoodChange?.call(moodValue);
  }

  /// Sincroniza el input Mood de Rive con el estado del provider.
  void _syncMoodToRive() {
    try {
      final mood = ref.read(botMoodProvider).clamp(0, 5);
      _mood?.value = mood.toDouble();
    } catch (e) {
      // Controller no listo o disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    final riveAsync = ref.watch(riveFileLoaderProvider);
    final currentMood = ref.watch(botMoodProvider);
    final currentMoodData = moods.firstWhere(
      (m) => m['value'] == currentMood,
      orElse: () => moods.first,
    );
    final moodColor = currentMoodData['color'] as Color;

    // Mantener Rive sincronizado con el mood en cada build
    _syncMoodToRive();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar con glow que cambia según el modo seleccionado (feedback visual claro)
        RepaintBoundary(
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: moodColor.withValues(alpha: 0.35),
                  blurRadius: widget.size * 0.25,
                  spreadRadius: widget.size * -0.05,
                ),
                BoxShadow(
                  color: moodColor.withValues(alpha: 0.2),
                  blurRadius: widget.size * 0.4,
                  spreadRadius: widget.size * -0.1,
                ),
              ],
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: riveAsync.when(
                data: (riveFile) {
                  return Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: moodColor.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: rive.RiveAnimation.direct(
                        riveFile,
                        fit: BoxFit.contain,
                        onInit: _onRiveInit,
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        moodColor.withValues(alpha: 0.15),
                        AppColors.background.withValues(alpha: 0.5),
                      ],
                    ),
                    border: Border.all(
                      color: moodColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: widget.size * 0.3,
                      height: widget.size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          moodColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                error: (_, __) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: moodColor.withValues(alpha: 0.3)),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.robot,
                    size: widget.size * 0.5,
                    color: moodColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Selector de modos: 3 columnas x 2 filas (o 2 columnas x 3 filas si la pantalla es muy angosta). Ancho máximo total 600.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final crossAxisCount = isNarrow ? 2 : 3;
                const spacing = 10.0;
                final itemWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int row = 0; row < (moods.length / crossAxisCount).ceil(); row++) ...[
                  if (row > 0) const SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < crossAxisCount; col++) ...[
                        if (col > 0) const SizedBox(width: spacing),
                        SizedBox(
                          width: itemWidth,
                          child: row * crossAxisCount + col < moods.length
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _MoodCard(
                                    key: ValueKey<int>(moods[row * crossAxisCount + col]['value'] as int),
                                    name: moods[row * crossAxisCount + col]['name'] as String,
                                    color: moods[row * crossAxisCount + col]['color'] as Color,
                                    icon: moods[row * crossAxisCount + col]['icon'] as IconData,
                                    isSelected: (moods[row * crossAxisCount + col]['value'] as int) == currentMood,
                                    compact: isNarrow,
                                    onTap: () => _changeMood(moods[row * crossAxisCount + col]['value'] as int),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
            ),
          ),
        ),
      ],
    );
  }
}

/// Card de modo con diseño tech senior: glass, glow, icono y tipografía alineada a la página.
class _MoodCard extends StatefulWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;

  const _MoodCard({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  static const double _minTouchHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final selected = widget.isSelected;
    final active = selected || _isHovered || _isPressed;
    final borderRadius = BorderRadius.circular(14);

    final Color selectedBgTop = Color.alphaBlend(
      c.withValues(alpha: 0.24),
      AppColors.surface,
    );
    final Color selectedBgBottom = Color.alphaBlend(
      c.withValues(alpha: 0.10),
      AppColors.surfaceLight,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (_) {
          setState(() => _isPressed = true);
          widget.onTap();
        },
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Container(
          constraints: BoxConstraints(
            minHeight: _minTouchHeight,
            minWidth: widget.compact ? 126 : 142,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 14,
            vertical: widget.compact ? 9 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [selectedBgTop, selectedBgBottom],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface.withValues(alpha: 0.92),
                      AppColors.surfaceLight.withValues(alpha: 0.86),
                    ],
                  ),
            border: Border.all(
              color: active ? c.withValues(alpha: 0.9) : AppColors.borderGlass,
              width: selected ? 1.7 : 1,
            ),
            boxShadow: [
              if (selected) ...[
                BoxShadow(
                  color: c.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ] else if (_isHovered || _isPressed) ...[
                BoxShadow(
                  color: c.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: widget.compact ? 26 : 30,
                    height: widget.compact ? 26 : 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? c.withValues(alpha: 0.12)
                          : c.withValues(alpha: 0.08),
                      border: Border.all(
                        color: c.withValues(alpha: selected ? 0.55 : 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: widget.compact ? 14 : 16,
                      color: c,
                    ),
                  ),
                  SizedBox(width: widget.compact ? 8 : 10),
                  Text(
                    widget.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? AppColors.textPrimary : c,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: widget.compact ? 10 : 10.5,
                        ),
                  ),
                  SizedBox(width: widget.compact ? 6 : 8),
                  Icon(
                    Icons.settings,
                    size: widget.compact ? 12 : 13,
                    color: selected
                        ? c.withValues(alpha: 0.9)
                        : c.withValues(alpha: 0.45),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          c.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
