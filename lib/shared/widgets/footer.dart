import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';
import 'reactor_pulse.dart';

/// Footer tecnológico de BotLode
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderGlass),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              // Contenido principal
              if (isMobile)
                _buildMobileContent(context)
              else
                _buildDesktopContent(context),

              const SizedBox(height: 32),

              // Línea divisoria
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Copyright - Responsive para móvil
              if (isMobile)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ReactorPulse(size: 10, color: AppColors.success),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'SISTEMA OPERATIVO',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                  letterSpacing: 2,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© ${DateTime.now().year} BotLode.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ReactorPulse(size: 10, color: AppColors.success),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'SISTEMA OPERATIVO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              letterSpacing: 2,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Flexible(
                      child: Text(
                        '© ${DateTime.now().year} BotLode. Todos los derechos reservados.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo y descripción
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.factory_outlined,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'BOTLODE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'La fábrica de bots IA que trabajan 24/7.\nCrea, personaliza y monetiza tus propios asistentes virtuales.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Stats
        Expanded(
          child: _FooterStats(),
        ),

        const SizedBox(width: 48),

        // Navegación
        Expanded(
          child: _FooterLinks(),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.factory_outlined,
                  color: AppColors.background,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'BOTLODE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Links móvil
        _FooterLinks(),
      ],
    );
  }
}

/// Estadísticas del footer
class _FooterStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTADÍSTICAS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        _StatItem(label: 'Bots Activos', value: 'Ilimitado'),
        const SizedBox(height: 8),
        _StatItem(label: 'Modos', value: '6 estados'),
        const SizedBox(height: 8),
        _StatItem(label: 'Historial', value: 'Completo'),
      ],
    );
  }
}

/// Item de estadística
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.techCyan.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.techCyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.techCyan,
                    fontWeight: FontWeight.w700,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Links de navegación del footer
class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NAVEGACIÓN',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        _FooterLink(label: 'Home', route: AppConstants.routeHome),
        const SizedBox(height: 8),
        _FooterLink(label: 'El Bot', route: AppConstants.routeBot),
        const SizedBox(height: 8),
        _FooterLink(label: 'La Fábrica', route: AppConstants.routeFactory),
        const SizedBox(height: 8),
        _FooterLink(label: 'Probar Demo', route: AppConstants.routeDemo),
        const SizedBox(height: 8),
        _FooterLink(label: 'Tutorial', route: AppConstants.routeTutorial),
      ],
    );
  }
}

/// Link individual del footer
class _FooterLink extends StatefulWidget {
  final String label;
  final String route;

  const _FooterLink({
    required this.label,
    required this.route,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => context.go(widget.route),
        hoverColor: Colors.transparent,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppConstants.durationFast,
                width: _isHovered ? 8 : 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _isHovered ? AppColors.primary : AppColors.borderGlass,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isHovered ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ahora usamos el widget compartido ReactorPulse
