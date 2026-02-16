import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/footer.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/section_title.dart';
import '../widgets/video_hero_home.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/pillars_section.dart';
import '../widgets/income_calculator.dart';
import '../widgets/features_grid.dart';

/// Vista principal del Home. Las cards usan globalPointerPositionProvider (MainLayout).
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoHeroHome(),
          QuickStatsSection(),
          PillarsSection(),
          FeaturesGrid(),
          IncomeCalculator(),
          _FinalCTA(),
          Footer(),
        ],
      ),
    );
  }
}

/// Call to Action final
class _FinalCTA extends StatelessWidget {
  const _FinalCTA();

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
                tag: 'Empieza Ahora',
                title: 'Tu Fábrica de Bots Te Espera',
                subtitle:
                    'Crea tu primer bot en minutos. Sin código, sin complicaciones. Solo resultados.',
              ),

              const SizedBox(height: 48),

              // Botones
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  GlowButton(
                    text: 'PROBAR DEMO GRATIS',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.go(AppConstants.routeDemo),
                  ),
                  GlowButton(
                    text: 'VER CÓMO FUNCIONA',
                    isOutlined: true,
                    icon: Icons.play_circle_outline,
                    onPressed: () => context.go(AppConstants.routeTutorial),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // Stats rápidas - Wrap para responsive
              Wrap(
                spacing: isMobile ? 24 : 32,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: const [
                  _QuickStat(icon: Icons.psychology, value: '6 Modos', label: 'Personalidades'),
                  _QuickStat(icon: Icons.access_time_rounded, value: '24/7', label: 'Disponible'),
                  _QuickStat(icon: FontAwesomeIcons.infinity, value: 'Sin límite', label: 'Escalable'),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
