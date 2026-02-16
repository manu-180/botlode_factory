import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import 'hero_title.dart';

/// Sección Hero con avatar Rive gigante interactivo
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  bool _isThinking = false;

  void _toggleThinking() {
    setState(() {
      _isThinking = !_isThinking;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final isDesktop = screenWidth >= AppConstants.desktop;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isMobile ? 700 : 600,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing3xl,
      ),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.7, -0.2),
          radius: 1.2,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.background,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context, isDesktop),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isLarge) {
    final avatarSize = isLarge ? 350.0 : 280.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Contenido textual
        Expanded(
          flex: 3,
          child: _HeroContent(),
        ),

        const SizedBox(width: 32),

        // Avatar Rive - con tamaño fijo, RepaintBoundary y GestureDetector para click
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: RepaintBoundary(
            child: GestureDetector(
              onTap: _toggleThinking,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: RiveBotAvatar(
                  size: avatarSize,
                  enableMouseTracking: true,
                  isThinking: _isThinking,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Avatar primero en móvil - con tamaño fijo y GestureDetector para click
        RepaintBoundary(
          child: SizedBox(
            width: 220,
            height: 220,
            child: GestureDetector(
              onTap: _toggleThinking,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: RiveBotAvatar(
                  size: 220,
                  enableMouseTracking: true,
                  isThinking: _isThinking,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Contenido
        _HeroContent(isMobile: true),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  final bool isMobile;

  const _HeroContent({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroTitle(isMobile: isMobile)
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 20),
        HeroTitleUnderline(isMobile: isMobile)
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .scaleX(begin: 0, end: 1),

        const SizedBox(height: 40),

        // Botones CTA
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            GlowButton(
              text: 'CREAR MI BOT',
              icon: Icons.rocket_launch,
              onPressed: () => context.go(AppConstants.routeDemo),
            ),
            GlowButton(
              text: 'VER FACTORY',
              isOutlined: true,
              icon: Icons.factory,
              onPressed: () => context.go(AppConstants.routeFactory),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 48),

        // Stats - Wrap para responsive
        Wrap(
          spacing: isMobile ? 24 : 32,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _HeroStat(
              value: '6',
              label: 'Modos',
              color: AppColors.happy,
            ),
            _HeroStat(
              icon: FontAwesomeIcons.infinity,
              label: 'Bots',
              color: AppColors.techCyan,
            ),
            _HeroStat(
              value: '\$',
              label: 'Por Bot',
              color: AppColors.success,
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String? value;
  final IconData? icon;
  final String label;
  final Color color;

  const _HeroStat({
    this.value,
    this.icon,
    required this.label,
    required this.color,
  }) : assert(value != null || icon != null, 'Debe proporcionar value o icon');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mostrar ícono o texto
            if (icon != null)
              FaIcon(
                icon,
                size: 36,
                color: color,
              )
            else
              Text(
                value!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Ahora usamos el widget compartido ReactorPulse desde shared/widgets/
