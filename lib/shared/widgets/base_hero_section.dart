import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';
import '../../core/providers/screen_size_provider.dart';
import 'section_title.dart';

/// Sección hero base reutilizable para todas las páginas.
/// Proporciona un diseño consistente con gradiente, título y contenido opcional.
class BaseHeroSection extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Widget? icon;
  final Widget? additionalContent;
  final List<Widget>? tips;
  final double verticalPadding;
  final Alignment gradientCenter;

  const BaseHeroSection({
    super.key,
    required this.tag,
    required this.title,
    required this.subtitle,
    this.accentColor = AppColors.primary,
    this.icon,
    this.additionalContent,
    this.tips,
    this.verticalPadding = AppConstants.spacing4xl,
    this.gradientCenter = const Alignment(0, -0.5),
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeHelper(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screen.horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: gradientCenter,
          radius: 1.5,
          colors: [
            accentColor.withValues(alpha: 0.1),
            AppColors.background,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              // Icono opcional
              if (icon != null) ...[
                icon!.animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),
                const SizedBox(height: 32),
              ],

              // Título de sección
              SectionTitle(
                tag: tag,
                title: title,
                subtitle: subtitle,
                accentColor: accentColor,
              ),

              // Tips opcionales
              if (tips != null && tips!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: tips!,
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
              ],

              // Contenido adicional
              if (additionalContent != null) ...[
                const SizedBox(height: 24),
                additionalContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tip para mostrar en la sección hero.
class HeroTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const HeroTip({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tipColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tipColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icono decorativo para usar en la sección hero.
class HeroIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const HeroIcon({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeHelper(context);
    final effectiveSize = screen.isMobile ? size * 0.8 : size;

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(
        icon,
        size: effectiveSize * 0.5,
        color: color,
      ),
    );
  }
}
