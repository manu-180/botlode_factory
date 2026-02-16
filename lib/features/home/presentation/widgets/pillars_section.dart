import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/section_title.dart';

/// Sección de los 3 pilares de BotLode
class PillarsSection extends StatelessWidget {
  final ValueNotifier<Offset>? globalMousePosition;

  const PillarsSection({
    super.key,
    this.globalMousePosition,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    // Espacio reducido ya que las cards están en su propia sección
    final topSectionPadding = isMobile ? 24.0 : 32.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        right: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        top: topSectionPadding + AppConstants.spacing4xl,
        bottom: AppConstants.spacing4xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              // Separador visual: marca clara entre las 3 cards del hero y "Los 3 Pilares"
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: isMobile ? 32 : 40),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.5),
                            AppColors.primary.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                    const SectionTitle(
                      tag: 'Ecosistema Completo',
                      title: 'Los 3 Pilares de BotLode',
                      subtitle:
                          'Un sistema integral que te permite crear, gestionar y monetizar bots de IA sin límites.',
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 48 : 96),

              // Grid de pilares - Wrap para mantener tamaño consistente
              isMobile
                  ? Column(
                      children: _buildPillars(context, isMobile),
                    )
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 24,
                      children: _buildPillars(context, isMobile),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPillars(BuildContext context, bool isMobile) {
    final pillars = [
      _PillarData(
        icon: Icons.factory_outlined,
        title: 'La Fábrica',
        subtitle: 'BOTLODE FACTORY',
        description:
            'Crea bots ilimitados con un clic. Cada bot es un empleado virtual listo para trabajar 24/7 en cualquier sitio web.',
        color: AppColors.primary,
        features: ['Creación instantánea', 'Personalización total', 'Sin código'],
        route: AppConstants.routeFactory,
        delay: 0,
      ),
      _PillarData(
        icon: FontAwesomeIcons.robot,
        title: 'Cat Bot',
        subtitle: 'BOTLODE PLAYER',
        useFaIcon: true,
        description:
            '6 modos, seguimiento de mouse, detección de WiFi. Un bot que parece vivo y conecta con tus clientes.',
        color: AppColors.techCyan,
        features: ['6 personalidades', 'IA conversacional', 'Modo vendedor'],
        route: AppConstants.routeBot,
        delay: 100,
      ),
      _PillarData(
        icon: Icons.analytics_outlined,
        title: 'Command Center',
        subtitle: 'BOTLODE HISTORY',
        description:
            'Cada conversación, cada lead, cada dato. Todo en tiempo real con alertas por email cuando hay un cliente caliente.',
        color: AppColors.success,
        features: ['Chats en vivo', 'Alertas por email', 'Indicador de interés'],
        route: AppConstants.routeBot,
        delay: 200,
      ),
    ];

    return pillars.map((pillar) {
      final cardWidget = _PillarCard(
        data: pillar,
        globalMousePosition: globalMousePosition,
      );

      // En mobile, full width con padding bottom
      if (isMobile) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: cardWidget,
        );
      }

      // En desktop/tablet, ancho reducido para que quepan las 3 cards en una sola línea (maxContentWidth 900)
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 240,
          maxWidth: 280,
        ),
        child: cardWidget,
      );
    }).toList();
  }
}

class _PillarData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<String> features;
  final String route;
  final int delay;
  final bool useFaIcon;

  _PillarData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.features,
    required this.route,
    required this.delay,
    this.useFaIcon = false,
  });
}

class _PillarCard extends StatelessWidget {
  final _PillarData data;
  final ValueNotifier<Offset>? globalMousePosition;

  const _PillarCard({
    required this.data,
    this.globalMousePosition,
  });

  @override
  Widget build(BuildContext context) {
    return GlowBorderCard(
      glowColor: data.color,
      padding: const EdgeInsets.all(28),
      onTap: () => context.go(data.route),
      globalMousePosition: globalMousePosition,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.color.withValues(alpha: 0.2)),
            ),
            child: data.useFaIcon
                ? FaIcon(data.icon, size: 32, color: data.color)
                : Icon(data.icon, size: 32, color: data.color),
          ),

          const SizedBox(height: 24),

          // Subtítulo
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: data.color,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Título
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 24),

          // Features
          ...data.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: data.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 24),

          // CTA
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explorar',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: data.color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: data.color,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: data.delay),
        ).slideY(begin: 0.1, end: 0);
  }
}
