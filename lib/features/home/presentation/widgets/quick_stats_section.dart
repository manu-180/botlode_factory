import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';

/// Sección de estadísticas rápidas (3 cards) justo después del hero principal.
/// Muestra: 6 Modos, ∞ Bots, $ Por Bot con animaciones escalonadas.
class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: isMobile ? 32 : 40,
      ),
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: isMobile
              ? Column(
                  children: _buildStatCards(isMobile),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: _buildStatCards(isMobile),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildStatCards(bool isMobile) {
    final stats = [
      _StatData(
        value: '6',
        label: 'Modos',
        color: AppColors.happy,
        delay: 0,
      ),
      _StatData(
        icon: FontAwesomeIcons.infinity,
        label: 'Bots',
        color: AppColors.techCyan,
        delay: 100,
      ),
      _StatData(
        value: '\$',
        label: 'Por Bot',
        color: AppColors.success,
        delay: 200,
      ),
    ];

    return stats.map((stat) {
      final card = _QuickStatCard(data: stat);
      
      // En mobile, agregar padding bottom
      if (isMobile && stat != stats.last) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: card,
        );
      }
      
      return card;
    }).toList();
  }
}

class _StatData {
  final String? value;
  final IconData? icon;
  final String label;
  final Color color;
  final int delay;

  _StatData({
    this.value,
    this.icon,
    required this.label,
    required this.color,
    required this.delay,
  }) : assert(value != null || icon != null, 'Debe proporcionar value o icon');
}

class _QuickStatCard extends StatefulWidget {
  final _StatData data;

  const _QuickStatCard({required this.data});

  @override
  State<_QuickStatCard> createState() => _QuickStatCardState();
}

class _QuickStatCardState extends State<_QuickStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child:       AnimatedContainer(
        duration: AppConstants.durationFast,
        width: isMobile ? double.infinity : null,
        constraints: BoxConstraints(
          minWidth: isMobile ? 0 : 180,
          maxWidth: isMobile ? double.infinity : 220,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: _isHovered
                ? widget.data.color.withValues(alpha: 0.5)
                : widget.data.color.withValues(alpha: 0.3),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.color.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.data.color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Contenedor para el icono/número
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.data.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.data.color.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: widget.data.icon != null
                  ? FaIcon(
                      widget.data.icon,
                      size: 32,
                      color: widget.data.color,
                    )
                  : Text(
                      widget.data.value!,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: widget.data.color,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                      textAlign: TextAlign.center,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Label
            Text(
              widget.data.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 600.ms,
            delay: Duration(milliseconds: widget.data.delay),
          )
          .slideY(begin: 0.15, end: 0),
    );
  }
}
