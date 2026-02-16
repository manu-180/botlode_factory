import 'package:flutter/material.dart';

import '../../core/config/app_constants.dart';

/// Mixin que proporciona funcionalidad de hover para widgets StatefulWidget.
/// 
/// Uso:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
/// 
/// class _MyWidgetState extends State<MyWidget> with HoverableMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildHoverable(
///       child: Container(...),
///     );
///   }
/// }
/// ```
mixin HoverableMixin<T extends StatefulWidget> on State<T> {
  bool _isHovered = false;

  bool get isHovered => _isHovered;

  /// Construye un widget con detección de hover.
  Widget buildHoverable({
    required Widget child,
    MouseCursor cursor = SystemMouseCursors.click,
    VoidCallback? onTap,
    VoidCallback? onHoverStart,
    VoidCallback? onHoverEnd,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;

        return MouseRegion(
          onEnter: hasValidSize
              ? (_) {
                  setState(() => _isHovered = true);
                  onHoverStart?.call();
                }
              : null,
          onExit: hasValidSize
              ? (_) {
                  setState(() => _isHovered = false);
                  onHoverEnd?.call();
                }
              : null,
          cursor: cursor,
          child: onTap != null
              ? GestureDetector(onTap: onTap, child: child)
              : child,
        );
      },
    );
  }

  /// Construye un widget animado que escala al hacer hover.
  Widget buildHoverableScaled({
    required Widget child,
    double scale = 1.05,
    MouseCursor cursor = SystemMouseCursors.click,
    VoidCallback? onTap,
  }) {
    return buildHoverable(
      cursor: cursor,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        transform: Matrix4.identity()..scale(_isHovered ? scale : 1.0),
        transformAlignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// Widget helper para hover sin necesidad de StatefulWidget.
class HoverableWidget extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final MouseCursor cursor;
  final VoidCallback? onTap;

  const HoverableWidget({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
    this.onTap,
  });

  @override
  State<HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<HoverableWidget> with HoverableMixin {
  @override
  Widget build(BuildContext context) {
    return buildHoverable(
      cursor: widget.cursor,
      onTap: widget.onTap,
      child: widget.builder(context, isHovered),
    );
  }
}

/// Widget de botón con efecto hover.
class HoverableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? hoverColor;
  final Color? normalColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final BoxBorder? hoverBorder;
  final List<BoxShadow>? hoverShadow;
  final double hoverScale;

  const HoverableButton({
    super.key,
    required this.child,
    this.onPressed,
    this.hoverColor,
    this.normalColor,
    this.borderRadius,
    this.padding,
    this.border,
    this.hoverBorder,
    this.hoverShadow,
    this.hoverScale = 1.0,
  });

  @override
  State<HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<HoverableButton> with HoverableMixin {
  @override
  Widget build(BuildContext context) {
    return buildHoverable(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: widget.padding,
        transform: Matrix4.identity()
          ..scale(isHovered ? widget.hoverScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHovered
              ? (widget.hoverColor ?? widget.normalColor)
              : widget.normalColor,
          borderRadius: widget.borderRadius,
          border: isHovered
              ? (widget.hoverBorder ?? widget.border)
              : widget.border,
          boxShadow: isHovered ? widget.hoverShadow : null,
        ),
        child: widget.child,
      ),
    );
  }
}
