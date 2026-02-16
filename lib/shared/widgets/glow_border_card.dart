import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';
import '../../core/providers/head_tracking_provider.dart';

/// Card con borde brillante que sigue el mouse (estilo APEX).
/// Usa RadialGradient dinámico para crear efecto de luz que sigue el mouse GLOBALMENTE.
///
/// OPTIMIZACIÓN v2:
/// - Eliminado ref.watch(globalPointerPositionProvider) del build (causaba rebuild en cada movimiento de mouse)
/// - Throttle con Timer para limitar actualizaciones a ~15fps
/// - RepaintBoundary para aislar repinturas
/// - Sin addPostFrameCallback en build()
class GlowBorderCard extends ConsumerStatefulWidget {
  
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enableHoverScale;
  final ValueNotifier<Offset>? globalMousePosition;
  /// Intensidad del glow (1.0 = normal, 1.2–1.5 = más intenso)
  final double glowIntensity;

  const GlowBorderCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.borderRadius = AppConstants.radiusLg,
    this.borderWidth = AppConstants.glowBorderWidth,
    this.padding,
    this.onTap,
    this.enableHoverScale = true,
    this.globalMousePosition,
    this.glowIntensity = 1.2,
  });

  @override
  ConsumerState<GlowBorderCard> createState() => _GlowBorderCardState();
}

class _GlowBorderCardState extends ConsumerState<GlowBorderCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isHovering = false;
  Offset _localMousePos = Offset.zero;
  Size _cardSize = const Size(100, 100);

  /// Throttle timer para limitar actualizaciones de posición
  Timer? _throttleTimer;
  static const Duration _throttleInterval = Duration(milliseconds: 66); // ~15fps
  Offset? _pendingGlobalPos;

  @override
  void initState() {
    super.initState();
    widget.globalMousePosition?.addListener(_onValueNotifierMove);
    // Sincronizar posición del mouse tras el primer layout para que el glow no quede estático
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.globalMousePosition != null) return;
      final pos = ref.read(globalPointerPositionProvider);
      if (pos != null) _applyGlobalPosition(pos);
    });
  }

  @override
  void didUpdateWidget(GlowBorderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.globalMousePosition != widget.globalMousePosition) {
      oldWidget.globalMousePosition?.removeListener(_onValueNotifierMove);
      widget.globalMousePosition?.addListener(_onValueNotifierMove);
    }
  }

  @override
  void dispose() {
    widget.globalMousePosition?.removeListener(_onValueNotifierMove);
    _throttleTimer?.cancel();
    super.dispose();
  }

  void _onValueNotifierMove() {
    final pos = widget.globalMousePosition?.value;
    if (pos != null) _scheduleUpdate(pos);
  }

  /// Programa una actualización throttled de la posición del mouse
  void _scheduleUpdate(Offset globalPos) {
    _pendingGlobalPos = globalPos;
    if (_throttleTimer?.isActive ?? false) return;
    
    _throttleTimer = Timer(_throttleInterval, () {
      if (!mounted || _pendingGlobalPos == null) return;
      _applyGlobalPosition(_pendingGlobalPos!);
      _pendingGlobalPos = null;
    });
  }

  /// Aplica la posición global calculando la posición local relativa a la card
  void _applyGlobalPosition(Offset globalPos) {
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || !renderBox.attached) return;

    try {
      final localPos = renderBox.globalToLocal(globalPos);
      final size = renderBox.size;

      if (mounted && (localPos != _localMousePos || size != _cardSize)) {
        setState(() {
          _localMousePos = localPos;
          _cardSize = size;
        });
      }
    } catch (_) {}
  }

  void _onLocalHover(PointerEvent event) {
    if (!mounted) return;

    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    try {
      final localPos = renderBox.globalToLocal(event.position);
      final size = renderBox.size;

      setState(() {
        _localMousePos = localPos;
        _cardSize = size;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZACIÓN: Solo escuchar el provider con ref.listen (no ref.watch)
    // para no causar rebuild en cada movimiento de mouse.
    // El throttle se maneja internamente.
    if (widget.globalMousePosition == null) {
      ref.listen<Offset?>(globalPointerPositionProvider, (prev, next) {
        if (next != null) _scheduleUpdate(next);
      });
    }

    final hasGlobalTracking = widget.globalMousePosition != null || 
        ref.read(globalPointerPositionProvider) != null;

    // Calcular gradiente basado en posición del mouse
    final width = _cardSize.width > 0 ? _cardSize.width : 1.0;
    final height = _cardSize.height > 0 ? _cardSize.height : 1.0;

    final centerX = ((_localMousePos.dx / width) * 2 - 1).clamp(-2.0, 2.0);
    final centerY = ((_localMousePos.dy / height) * 2 - 1).clamp(-2.0, 2.0);

    final useGradient = hasGlobalTracking || _isHovering;

    // Aplicar glowIntensity a los alphas del gradiente
    final intensity = widget.glowIntensity.clamp(0.5, 2.0);
    final centerAlpha = (0.9 * intensity).clamp(0.0, 1.0);
    final midAlpha = (0.4 * intensity).clamp(0.0, 1.0);

    final borderGradient = useGradient
        ? RadialGradient(
            center: Alignment(centerX, centerY),
            radius: 1.5,
            colors: [
              widget.glowColor.withValues(alpha: centerAlpha),
              widget.glowColor.withValues(alpha: midAlpha),
              AppColors.borderGlass,
            ],
            stops: const [0.0, 0.4, 1.0],
          )
        : null;

    final surfaceColor = _isHovering ? AppColors.surfaceHover : AppColors.surface;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) setState(() => _isHovering = true);
        },
        onHover: hasGlobalTracking ? null : _onLocalHover,
        onExit: (_) {
          if (mounted) setState(() => _isHovering = false);
        },
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            key: _cardKey,
            duration: AppConstants.durationFast,
            curve: Curves.easeOut,
            clipBehavior: Clip.antiAlias,
            transform: widget.enableHoverScale && _isHovering
                ? (Matrix4.identity()..scale(1.02))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                // Borde con glow (solo visible en la franja del borde)
                if (borderGradient != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        gradient: borderGradient,
                      ),
                    ),
                  ),
                if (borderGradient == null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        color: AppColors.borderGlass,
                      ),
                    ),
                  ),
                // Interior + contenido: sin Positioned para que el Stack tome el tamaño del contenido
                Padding(
                  padding: EdgeInsets.all(widget.borderWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius - widget.borderWidth,
                      ),
                    ),
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: widget.child,
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
