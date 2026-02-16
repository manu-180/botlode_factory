import 'package:flutter/material.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';

/// Botón con efecto de brillo al hover
class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const GlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.primary,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;

        return MouseRegion(
          onEnter:
              hasValidSize ? (_) => setState(() => _isHovered = true) : null,
          onExit:
              hasValidSize ? (_) => setState(() => _isHovered = false) : null,
          cursor: isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: isDisabled ? null : widget.onPressed,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _isHovered && !isDisabled ? -2.0 : 0.0),
              duration: AppConstants.durationFast,
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                curve: Curves.easeOut,
                width: widget.width,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                transform: Matrix4.identity()
                  ..scale(_isPressed ? 0.98 : 1.0),
                transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: !widget.isOutlined && !isDisabled
                    ? (_isHovered
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color,
                              Color.lerp(widget.color, Colors.white, 0.2)!,
                              widget.color,
                            ],
                          )
                        : null)
                    : null,
                color: widget.isOutlined
                    ? (_isHovered && !isDisabled
                        ? widget.color.withValues(alpha: 0.08)
                        : Colors.transparent)
                    : (isDisabled
                        ? AppColors.surfaceHover
                        : (_isHovered ? null : widget.color)),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: widget.isOutlined
                    ? Border.all(
                        color: isDisabled ? AppColors.textTertiary : widget.color,
                        width: _isHovered && !isDisabled ? 2.5 : 2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          widget.isOutlined ? widget.color : AppColors.background,
                        ),
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isOutlined
                          ? (isDisabled ? AppColors.textTertiary : widget.color)
                          : AppColors.background,
                    ),
                  if ((widget.icon != null || widget.isLoading) &&
                      widget.text.isNotEmpty)
                    const SizedBox(width: 10),
                  if (widget.text.isNotEmpty)
                    Flexible(
                      child: Text(
                        widget.text,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: widget.isOutlined
                                  ? (isDisabled
                                      ? AppColors.textTertiary
                                      : widget.color)
                                  : AppColors.background,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              height: 1.2,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Botón de icono con efecto glow
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final String? tooltip;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = AppColors.primary,
    this.size = 48,
    this.tooltip,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;
        
        return MouseRegion(
          onEnter: hasValidSize ? (_) => setState(() => _isHovered = true) : null,
          onExit: hasValidSize ? (_) => setState(() => _isHovered = false) : null,
          cursor: widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isHovered ? widget.color : AppColors.surface,
                borderRadius: BorderRadius.circular(widget.size / 4),
                border: Border.all(
                  color: _isHovered ? widget.color : AppColors.borderGlass,
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.5,
                color: _isHovered ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
