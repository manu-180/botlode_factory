import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/section_title.dart';
import '../providers/income_calculator_provider.dart';

/// Abre WhatsApp con el número de contacto predefinido
Future<void> _openWhatsApp() async {
  final Uri whatsappUrl = Uri.parse(
    'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(AppConstants.whatsappDefaultMessage)}',
  );
  
  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  }
}

/// Calculadora de ingresos potenciales.
/// Usa Riverpod para gestionar el estado y delega los cálculos al servicio.
class IncomeCalculator extends ConsumerWidget {
  final ValueNotifier<Offset>? globalMousePosition;

  const IncomeCalculator({
    super.key,
    this.globalMousePosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final state = ref.watch(incomeCalculatorProvider);

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
                tag: 'Modelo de Negocio',
                title: 'Calcula Tu Potencial',
                subtitle:
                    'Cada bot es un empleado que trabaja 24/7 y te genera ingresos pasivos mensuales.',
                accentColor: AppColors.success,
              ),

              const SizedBox(height: 64),

              // Calculator Card
              GlowBorderCard(
                glowColor: AppColors.success,
                enableHoverScale: false,
                padding: EdgeInsets.all(isMobile ? 24 : 48),
                globalMousePosition: globalMousePosition,
                child: Column(
                  children: [
                    // Banner explicativo
                    _PricingExplanationBanner(isMobile: isMobile),
                    
                    SizedBox(height: isMobile ? 32 : 40),

                    // Slider de bots
                    _SliderSection(
                      botCount: state.botCount,
                      onChanged: (value) {
                        ref.read(incomeCalculatorProvider.notifier).updateBotCount(value);
                      },
                    ),

                    SizedBox(height: isMobile ? 32 : 48),

                    // Resultados
                    isMobile
                        ? _MobileResults(
                            monthlyRevenue: state.calculation.monthlyRevenue,
                            monthlyVariableCost: state.calculation.monthlyVariableCost,
                            monthlyFixedCost: state.calculation.monthlyFixedCost,
                            monthlyCost: state.calculation.monthlyCost,
                            monthlyProfit: state.calculation.monthlyProfit,
                            yearlyProfit: state.calculation.yearlyProfit,
                            pricePerBot: state.pricePerBot,
                            maintenanceCost: state.maintenanceCost,
                            botCount: state.botCount,
                          )
                        : _DesktopResults(
                            monthlyRevenue: state.calculation.monthlyRevenue,
                            monthlyVariableCost: state.calculation.monthlyVariableCost,
                            monthlyFixedCost: state.calculation.monthlyFixedCost,
                            monthlyCost: state.calculation.monthlyCost,
                            monthlyProfit: state.calculation.monthlyProfit,
                            yearlyProfit: state.calculation.yearlyProfit,
                            pricePerBot: state.pricePerBot,
                            maintenanceCost: state.maintenanceCost,
                            botCount: state.botCount,
                          ),

                    const SizedBox(height: 32),

                    // CTAs
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        GlowButton(
                          text: 'PROBAR DEMO GRATIS',
                          color: AppColors.success,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.go(AppConstants.routeDemo),
                        ),
                        GlowButton(
                          text: 'QUIERO MI FACTORY',
                          color: AppColors.primary,
                          isOutlined: true,
                          icon: FontAwesomeIcons.whatsapp,
                          onPressed: () => _openWhatsApp(),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 48),

              // Info adicional
              _InfoCards(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final int botCount;
  final ValueChanged<int> onChanged;

  const _SliderSection({
    required this.botCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cantidad de Bots',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Desliza para calcular',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.robot,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$botCount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.success,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.success,
            overlayColor: AppColors.success.withValues(alpha: 0.2),
            trackHeight: 10,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
          ),
          child: Slider(
            value: botCount.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 bot',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '100 bots',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopResults extends StatelessWidget {
  final double monthlyRevenue;
  final double monthlyVariableCost;
  final double monthlyFixedCost;
  final double monthlyCost;
  final double monthlyProfit;
  final double yearlyProfit;
  final double pricePerBot;
  final double maintenanceCost;
  final int botCount;

  const _DesktopResults({
    required this.monthlyRevenue,
    required this.monthlyVariableCost,
    required this.monthlyFixedCost,
    required this.monthlyCost,
    required this.monthlyProfit,
    required this.yearlyProfit,
    required this.pricePerBot,
    required this.maintenanceCost,
    required this.botCount,
  });

  @override
  Widget build(BuildContext context) {
    final isBreakEven = monthlyProfit == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila 1: Ingresos, Costo variable, Costo fijo (más espacio para que no se trunque el texto)
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Ingresos Mensuales',
                  value: '\$${monthlyRevenue.toStringAsFixed(0)}',
                  sublabel: '\$${pricePerBot.toInt()} x $botCount bots',
                  color: AppColors.techCyan,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 2, color: AppColors.borderGlass),
              const SizedBox(width: 16),
              Expanded(
                child: _ResultCard(
                  label: 'Costo variable',
                  value: '-\$${monthlyVariableCost.toStringAsFixed(0)}',
                  sublabel: '\$${maintenanceCost.toInt()} x $botCount bots',
                  color: AppColors.error,
                  labelIcon: FontAwesomeIcons.robot,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 2, color: AppColors.borderGlass),
              const SizedBox(width: 16),
              Expanded(
                child: _ResultCard(
                  label: 'Costo fijo',
                  value: '-\$${monthlyFixedCost.toStringAsFixed(0)}',
                  sublabel: 'Fábrica',
                  color: AppColors.error,
                  labelIcon: Icons.factory_outlined,
                  labelIconIsMaterial: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 2, color: AppColors.borderGlass),
        const SizedBox(height: 16),
        // Fila 2: Ganancia neta en su propio renglón
        _ResultCard(
          label: 'GANANCIA NETA',
          value: isBreakEven
              ? 'Punto de equilibrio'
              : '\$${monthlyProfit.toStringAsFixed(0)}/mes',
          sublabel: isBreakEven
              ? 'Ingresos cubren todos los costos'
              : '\$${yearlyProfit.toStringAsFixed(0)} al año',
          color: AppColors.success,
          isHighlighted: true,
        ),
      ],
    );
  }
}

class _MobileResults extends StatelessWidget {
  final double monthlyRevenue;
  final double monthlyVariableCost;
  final double monthlyFixedCost;
  final double monthlyCost;
  final double monthlyProfit;
  final double yearlyProfit;
  final double pricePerBot;
  final double maintenanceCost;
  final int botCount;

  const _MobileResults({
    required this.monthlyRevenue,
    required this.monthlyVariableCost,
    required this.monthlyFixedCost,
    required this.monthlyCost,
    required this.monthlyProfit,
    required this.yearlyProfit,
    required this.pricePerBot,
    required this.maintenanceCost,
    required this.botCount,
  });

  @override
  Widget build(BuildContext context) {
    final isBreakEven = monthlyProfit == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _ResultCard(
                label: 'Ingresos',
                value: '\$${monthlyRevenue.toStringAsFixed(0)}',
                sublabel: '/mes',
                color: AppColors.techCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultCard(
                label: 'Costo variable',
                value: '-\$${monthlyVariableCost.toStringAsFixed(0)}',
                sublabel: '\$${maintenanceCost.toInt()} x $botCount',
                color: AppColors.error,
                labelIcon: FontAwesomeIcons.robot,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ResultCard(
                label: 'Costo fijo',
                value: '-\$${monthlyFixedCost.toStringAsFixed(0)}',
                sublabel: 'Fábrica',
                color: AppColors.error,
                labelIcon: Icons.factory_outlined,
                labelIconIsMaterial: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultCard(
                label: 'GANANCIA NETA',
                value: isBreakEven
                    ? 'Punto de equilibrio'
                    : '\$${monthlyProfit.toStringAsFixed(0)}/mes',
                sublabel: isBreakEven
                    ? 'Ingresos = costos'
                    : '\$${yearlyProfit.toStringAsFixed(0)} al año',
                color: AppColors.success,
                isHighlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCards extends StatelessWidget {
  final bool isMobile;

  const _InfoCards({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _InfoCardData(
        icon: Icons.savings,
        title: 'Ahorro Real',
        description: 'Reemplaza un empleado que cuesta miles. Tu bot: una fracción del precio.',
      ),
      _InfoCardData(
        icon: Icons.all_inclusive,
        title: 'Sin Límites',
        description: 'Crea bots ilimitados. Tu fábrica de empleados virtuales.',
      ),
      _InfoCardData(
        icon: Icons.attach_money_rounded,
        title: 'Tú Pones el Precio',
        description: '\$30, \$50, \$100 o más. Cobra lo que tu valor y experiencia merece.',
      ),
    ];

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _InfoCard(data: card),
        )).toList(),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _InfoCard(data: card),
          ),
        )).toList(),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final bool isHighlighted;
  final IconData? labelIcon;
  /// Si true, usa Icon() (Material); si false, usa FaIcon() (Font Awesome).
  final bool labelIconIsMaterial;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    this.isHighlighted = false,
    this.labelIcon,
    this.labelIconIsMaterial = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w800,
      fontSize: 11,
    );

    return Container(
      padding: EdgeInsets.all(isHighlighted ? 32 : 16),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted 
          ? Border.all(color: color.withValues(alpha: 0.3), width: 2) 
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label con badge minimalista (opcionalmente con icono)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: labelIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      labelIconIsMaterial
                          ? Icon(labelIcon!, size: 12, color: color)
                          : FaIcon(labelIcon!, size: 12, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          style: labelStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: labelStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          
          SizedBox(height: isHighlighted ? 20 : 12),
          
          // Valor principal
          Text(
            value,
            style: (isHighlighted 
              ? Theme.of(context).textTheme.headlineLarge 
              : Theme.of(context).textTheme.headlineMedium)?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Sublabel
          Text(
            sublabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoCardData {
  final IconData icon;
  final String title;
  final String description;

  _InfoCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoCardData data;

  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner explicativo del pricing con mensaje vendedor
class _PricingExplanationBanner extends StatelessWidget {
  final bool isMobile;

  const _PricingExplanationBanner({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: AppColors.success,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'El Precio Lo Decides Tú',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: isMobile ? 14 : null,
                  ),
              children: [
                TextSpan(
                  text: '\$50/mes es solo un ejemplo. ',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: 'Tu bot reemplaza un empleado completo trabajando 24/7 sin descansos, vacaciones ni licencias. ',
                ),
                TextSpan(
                  text: 'Cobra lo que consideres justo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: ' — tus clientes ahorran en costos operativos y tú construyes ',
                ),
                TextSpan(
                  text: 'ingresos pasivos recurrentes',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: ' que crecen cada mes mientras duermes.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGlass),
                  ),
                  child: Text(
                    'Tip: El rango típico está entre \$40-\$100 mensuales, dependiendo de tu mercado y el valor que aportas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                          fontSize: isMobile ? 11 : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }
}
