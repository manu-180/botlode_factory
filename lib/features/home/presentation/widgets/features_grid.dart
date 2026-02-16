import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/section_title.dart';

/// Grid de features del bot
class FeaturesGrid extends StatelessWidget {
  final ValueNotifier<Offset>? globalMousePosition;

  const FeaturesGrid({
    super.key,
    this.globalMousePosition,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing4xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              const SectionTitle(
                tag: 'Superpoderes',
                title: 'Lo Que Tu Bot Puede Hacer',
                subtitle:
                    'No es solo un chatbot. Es un empleado completo con inteligencia artificial.',
                accentColor: AppColors.techCyan,
              ),

              const SizedBox(height: 64),

              // Wrap de features para mantener tamaño consistente
              isMobile
                  ? Column(
                      children: _buildFeatureCards(isMobile),
                    )
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 24,
                      children: _buildFeatureCards(isMobile),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards(bool isMobile) {
    return _features.asMap().entries.map((entry) {
      final cardWidget = _FeatureCard(
        data: entry.value,
        delay: entry.key * 100,
        globalMousePosition: globalMousePosition,
      );

      final constrainedCard = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320,
          maxWidth: 380,
        ),
        child: cardWidget,
      );

      // En mobile, agregar padding bottom
      if (isMobile) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: constrainedCard,
        );
      }
      
      return constrainedCard;
    }).toList();
  }

  static final List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.psychology,
      title: '6 Modos',
      description: 'Neutral, vendedor, técnico, feliz, confundido y enojado. El bot adapta su personalidad según la conversación.',
      color: AppColors.happy,
    ),
    _FeatureData(
      icon: Icons.shopping_cart,
      title: 'Modo Vendedor',
      description: 'Recopila teléfonos, emails, agenda reuniones y genera leads calificados automáticamente.',
      color: AppColors.primary,
    ),
    _FeatureData(
      icon: Icons.email,
      title: 'Alertas por Email',
      description: 'Cuando un cliente deja sus datos, recibes un email instantáneo con toda la información.',
      color: AppColors.success,
    ),
    _FeatureData(
      icon: Icons.visibility,
      title: 'Historial en Vivo',
      description: 'Ve las conversaciones en tiempo real. Punto verde cuando alguien está chateando.',
      color: AppColors.techCyan,
    ),
    _FeatureData(
      icon: Icons.wifi_off,
      title: 'Detección WiFi',
      description: 'El bot avisa a tus visitantes si se desconecta el internet y cuando vuelve.',
      color: AppColors.confused,
    ),
    _FeatureData(
      icon: Icons.trending_up,
      title: 'Indicador de Interés',
      description: 'Cada chat tiene un score del 0% al 100%. Al llegar al 80%, se dispara una alerta automática por email.',
      color: AppColors.error,
    ),
  ];
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  final int delay;
  final ValueNotifier<Offset>? globalMousePosition;

  const _FeatureCard({
    required this.data,
    required this.delay,
    this.globalMousePosition,
  });

  @override
  Widget build(BuildContext context) {
    return GlowBorderCard(
      glowColor: data.color,
      padding: const EdgeInsets.all(24),
      globalMousePosition: globalMousePosition,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              size: 28,
              color: data.color,
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Text(
            data.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Descripción
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: delay),
        ).slideY(begin: 0.1, end: 0);
  }
}
