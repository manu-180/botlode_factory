import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';
import '../mixins/hoverable_mixin.dart';

/// Logo de BotLode reutilizable.
/// Puede usarse en el navbar, footer, y cualquier otro lugar.
class BotLodeLogo extends StatefulWidget {
  final double? size;
  final bool showText;
  final bool enableHover;
  final VoidCallback? onTap;
  final Color? glowColor;

  const BotLodeLogo({
    super.key,
    this.size,
    this.showText = true,
    this.enableHover = true,
    this.onTap,
    this.glowColor,
  });

  @override
  State<BotLodeLogo> createState() => _BotLodeLogoState();
}

class _BotLodeLogoState extends State<BotLodeLogo> with HoverableMixin {
  @override
  Widget build(BuildContext context) {
    final logoSize = widget.size ?? 32.0;
    final glowColor = widget.glowColor ?? AppColors.primary;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono del logo
        AnimatedContainer(
          duration: AppConstants.durationFast,
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glowColor,
                glowColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(logoSize * 0.25),
            boxShadow: widget.enableHover && isHovered
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.robot,
              color: AppColors.background,
              size: logoSize * 0.6,
            ),
          ),
        ),
        if (widget.showText) ...[
          SizedBox(width: logoSize * 0.4),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: logoSize * 0.65,
                  ),
              children: [
                TextSpan(
                  text: 'Bot',
                  style: TextStyle(color: glowColor),
                ),
                const TextSpan(
                  text: 'Lode',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    if (!widget.enableHover && widget.onTap == null) {
      return content;
    }

    return buildHoverable(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        transform: Matrix4.identity()
          ..scale(widget.enableHover && isHovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        child: content,
      ),
    );
  }
}

/// Versión compacta del logo (solo icono).
class BotLodeIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const BotLodeIcon({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor,
            logoColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: logoColor.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.robot,
          color: AppColors.background,
          size: size * 0.6,
        ),
      ),
    );
  }
}
