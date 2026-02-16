import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';

/// Título principal del hero con diseño profesional:
/// tipografía refinada, sombra sutil y acento dorado en "Duerme".
class HeroTitle extends StatelessWidget {
  const HeroTitle({super.key, required this.isMobile, this.compact = false});

  final bool isMobile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final displayStyle = compact
        ? Theme.of(context).textTheme.headlineLarge
        : Theme.of(context).textTheme.displayLarge;
    final fontSize = compact ? 38.0 : 82.0; // 82px desktop; 38px móvil (más grande para que se note)
    final baseStyle = displayStyle?.copyWith(
          fontSize: fontSize,
          height: 1.12,
          fontWeight: FontWeight.w800,
          letterSpacing: compact ? -1.5 : -2.5,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: compact ? 12 : 24,
              offset: const Offset(0, 4),
            ),
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    final goldStyle = baseStyle?.copyWith(
      color: AppColors.primary,
      shadows: [
        Shadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 2),
        ),
        Shadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Align(
      alignment: isMobile ? Alignment.center : Alignment.centerLeft,
      child: RichText(
        textAlign: isMobile ? TextAlign.center : TextAlign.left,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Tu Empleado\nQue Nunca\n'),
            TextSpan(
              text: 'Duerme',
              style: goldStyle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Línea decorativa bajo el título: gradiente dorado con glow sutil.
class HeroTitleUnderline extends StatelessWidget {
  const HeroTitleUnderline({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMobile ? Alignment.center : Alignment.centerLeft,
      child: Container(
        width: isMobile ? 140 : 120,
        height: 4,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
