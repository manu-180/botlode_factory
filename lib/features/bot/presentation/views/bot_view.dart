import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/footer.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import '../widgets/video_hero_bot.dart';

/// Vista de la página Bot. Las cards usan globalPointerPositionProvider (MainLayout).
class BotView extends ConsumerWidget {
  const BotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VideoHeroBot(),
          // Cubre la unión hero/contenido para evitar línea clara al hacer scroll
          Container(height: 8, width: double.infinity, color: AppColors.background),
          const _EmotionsSection(),
          const _BotCTA(),
          const Footer(),
        ],
      ),
    );
  }
}

/// Sección de los 6 modos
class _EmotionsSection extends StatelessWidget {
  const _EmotionsSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    // Mismo orden que el selector de modos del hero (rive_bot_avatar): Neutral, Enojado, Feliz, Vendedor, Confundido, Técnico
    final emotions = [
      _EmotionData(
        name: 'Neutral',
        description:
            'El modo base del bot. Conversación equilibrada y profesional, ideal para información general.',
        color: AppColors.neutral,
        icon: Icons.sentiment_neutral,
        features: ['Conversación estándar', 'Información general', 'Modo equilibrado'],
      ),
      _EmotionData(
        name: 'Enojado',
        description:
            'Para situaciones difíciles. Maneja quejas con firmeza pero profesionalismo.',
        color: AppColors.angry,
        icon: Icons.warning_amber,
        features: ['Manejo de quejas', 'Límites claros', 'Escalamiento'],
      ),
      _EmotionData(
        name: 'Feliz',
        description:
            'Interacción amigable y cálida. Perfecto para bienvenidas, celebraciones y feedback positivo.',
        color: AppColors.happy,
        icon: Icons.sentiment_very_satisfied,
        features: ['Bienvenidas', 'Celebraciones', 'Conexión'],
      ),
      _EmotionData(
        name: 'Vendedor',
        description:
            'El modo más importante. Recopila teléfonos, emails, resume proyectos y agenda reuniones. Todo automático.',
        color: AppColors.sales,
        icon: Icons.shopping_cart,
        features: ['Captura de leads', 'Agenda reuniones', 'Resume proyectos'],
      ),
      _EmotionData(
        name: 'Confundido',
        description:
            'Cuando necesita más información. Hace preguntas clarificadoras para entender mejor al cliente.',
        color: AppColors.confused,
        icon: Icons.help_outline,
        features: ['Clarificaciones', 'Preguntas', 'Comprensión'],
      ),
      _EmotionData(
        name: 'Técnico',
        description:
            'Para dudas complejas. Explica con detalle, usa terminología técnica y resuelve problemas específicos.',
        color: AppColors.techCyan,
        icon: Icons.code,
        features: ['Respuestas detalladas', 'Soporte técnico', 'Documentación'],
      ),
    ];

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
                tag: 'Personalidad Dinámica',
                title: '6 Modos, Infinitas Posibilidades',
                subtitle:
                    'El bot analiza la conversación y adapta su personalidad en tiempo real.',
              ),

              const SizedBox(height: 64),

              // Grid de modos: 3 columnas en desktop, 1 columna en móvil
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isMobile ? 1 : 3;
                  const spacing = 24.0;
                  final itemWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int row = 0; row < (emotions.length / crossAxisCount).ceil(); row++) ...[
                        if (row > 0) const SizedBox(height: spacing),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int col = 0; col < crossAxisCount; col++) ...[
                              if (col > 0) const SizedBox(width: spacing),
                              SizedBox(
                                width: itemWidth,
                                child: row * crossAxisCount + col < emotions.length
                                    ? _EmotionCard(
                                        data: emotions[row * crossAxisCount + col],
                                        delay: (row * crossAxisCount + col) * 100,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionData {
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final List<String> features;

  _EmotionData({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.features,
  });
}

class _EmotionCard extends StatelessWidget {
  final _EmotionData data;
  final int delay;

  const _EmotionCard({
    required this.data,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlowBorderCard(
      glowColor: data.color,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Premium
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono limpio y ultra profesional
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: data.color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
              
              const SizedBox(width: 20),
              
              // Título
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre del modo
                    Text(
                      data.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: data.color,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            height: 1,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Separador elegante
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  data.color.withValues(alpha: 0.3),
                  data.color.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Descripción
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                  fontSize: 14,
                ),
          ),

          const SizedBox(height: 24),

          // Features con diseño mejorado
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data.color.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: data.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: data.color.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: delay),
        ).slideY(begin: 0.1, end: 0);
  }
}

/// CTA final — Card premium de alto impacto
class _BotCTA extends StatelessWidget {
  const _BotCTA();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing4xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: GlowBorderCard(
            glowColor: AppColors.primary,
            borderRadius: 24,
            enableHoverScale: true,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
              vertical: isMobile ? 40 : 56,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Listo para probar tu fábrica en vivo?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 28 : 36),
                GlowButton(
                  text: 'PROBAR DEMO',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.go(AppConstants.routeDemo),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 100.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}
