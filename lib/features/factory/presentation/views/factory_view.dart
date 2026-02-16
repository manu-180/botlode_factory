import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/footer.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/section_title.dart';
import '../widgets/video_hero_background.dart';

/// Vista de la página Factory - El modelo de negocio
class FactoryView extends StatefulWidget {
  const FactoryView({super.key});

  @override
  State<FactoryView> createState() => _FactoryViewState();
}

class _FactoryViewState extends State<FactoryView> {
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _mousePos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        _mousePos.value = event.position;
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VideoHeroBackground(),
            // Cubre la unión hero/contenido para evitar línea clara al hacer scroll
            Container(height: 8, width: double.infinity, color: AppColors.background),
            _CreationProcess(globalMousePosition: _mousePos),
            _BusinessModel(globalMousePosition: _mousePos),
            _ScalabilityTable(globalMousePosition: _mousePos),
            _FactoryCTA(globalMousePosition: _mousePos),
            // Footer al final del scroll
            const Footer(),
          ],
        ),
      ),
    );
  }
}


/// Proceso de creación en 3 pasos
class _CreationProcess extends StatelessWidget {
  final ValueNotifier<Offset>? globalMousePosition;
  
  const _CreationProcess({this.globalMousePosition});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    final steps = [
      _StepData(
        number: '01',
        title: 'Nombre',
        description: 'Dale un nombre único a tu bot. Será su identidad.',
        icon: Icons.badge,
        color: AppColors.techCyan,
      ),
      _StepData(
        number: '02',
        title: 'Personalidad',
        description: 'Define el prompt. Qué hace, cómo habla, qué vende.',
        icon: Icons.psychology,
        color: AppColors.happy,
      ),
      _StepData(
        number: '03',
        title: 'Color',
        description: 'Elige el color del tema. Se adapta a cualquier web.',
        icon: Icons.palette,
        color: AppColors.primary,
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
                tag: 'Proceso Simple',
                title: 'Crea un Bot en 3 Pasos',
                subtitle: 'Sin código, sin complicaciones. En menos de 1 minuto tienes un empleado listo.',
                accentColor: AppColors.techCyan,
              ),

              const SizedBox(height: 64),

              // Steps
              isMobile
                  ? Column(
                      children: steps.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _StepCard(data: entry.value, delay: entry.key * 150),
                        );
                      }).toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: steps.asMap().entries.map((entry) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _StepCard(data: entry.value, delay: entry.key * 150),
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 48),

              // Arrow to demo
              GlowButton(
                text: 'CREAR MI PRIMER BOT',
                icon: Icons.add_circle_outline,
                onPressed: () => context.go(AppConstants.routeDemo),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _StepCard extends StatelessWidget {
  final _StepData data;
  final int delay;

  const _StepCard({required this.data, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Número
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: data.color.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: Text(
              data.number,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Icono
        Icon(data.icon, color: data.color, size: 32),

        const SizedBox(height: 16),

        // Título
        Text(
          data.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Descripción
        Text(
          data.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay)).slideY(begin: 0.2, end: 0);
  }
}

/// Etiqueta de subsección (ej. "Por cada bot", "Mantenimiento de la fábrica")
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

/// Modelo de negocio
class _BusinessModel extends StatelessWidget {
  final ValueNotifier<Offset>? globalMousePosition;
  
  const _BusinessModel({this.globalMousePosition});

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
                tag: 'Matemáticas Simples',
                title: 'El Modelo de Negocio',
                subtitle: 'Tú cobras al cliente. Nosotros cobramos mantenimiento del bot y mantenimiento de la fábrica.',
                accentColor: AppColors.success,
              ),

              const SizedBox(height: 48),

              // ─── Por cada bot: $50 − $20 = $30 ───
              _SectionLabel(label: 'Por cada bot'),
              const SizedBox(height: 24),
              GlowBorderCard(
                glowColor: AppColors.techCyan,
                enableHoverScale: false,
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                globalMousePosition: globalMousePosition,
                child: isMobile
                    ? Column(
                        children: [
                          _ModelCard(
                            title: 'Tú Cobras',
                            value: '\$50+',
                            subtitle: 'por bot/mes',
                            description: 'Pon el precio que quieras a tu cliente',
                            color: AppColors.techCyan,
                            icon: Icons.attach_money,
                          ),
                          const SizedBox(height: 24),
                          _ModelCard(
                            title: 'Mantenimiento del bot',
                            value: '\$20',
                            subtitle: 'por bot/mes',
                            description: 'Mantenimiento por cada bot. Incluye infraestructura, IA y soporte.',
                            color: AppColors.maintenanceRed,
                            icon: Icons.build,
                          ),
                          const SizedBox(height: 24),
                          _ModelCard(
                            title: 'Tu Ganancia',
                            value: '\$30+',
                            subtitle: 'por bot/mes',
                            description: 'Ingreso neto por cada bot (\$50 − \$20)',
                            color: AppColors.success,
                            icon: Icons.savings,
                            isHighlighted: true,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ModelCard(
                              title: 'Tú Cobras',
                              value: '\$50+',
                              subtitle: 'por bot/mes',
                              description: 'Pon el precio que quieras a tu cliente',
                              color: AppColors.techCyan,
                              icon: Icons.attach_money,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.remove, color: AppColors.textTertiary, size: 32),
                          ),
                          Expanded(
                            child: _ModelCard(
                              title: 'Mantenimiento del bot',
                              value: '\$20',
                              subtitle: 'por bot/mes',
                              description: 'Mantenimiento por cada bot. Incluye infraestructura, IA y soporte.',
                              color: AppColors.maintenanceRed,
                              icon: Icons.build,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.drag_handle, color: AppColors.textTertiary, size: 32),
                          ),
                          Expanded(
                            child: _ModelCard(
                              title: 'Tu Ganancia',
                              value: '\$30+',
                              subtitle: 'por bot/mes',
                              description: 'Ingreso neto por cada bot (\$50 − \$20)',
                              color: AppColors.success,
                              icon: Icons.savings,
                              isHighlighted: true,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 40),

              // ─── Mantenimiento de la fábrica: $90/mes fijo ───
              _SectionLabel(label: 'Mantenimiento de la fábrica'),
              const SizedBox(height: 24),
              GlowBorderCard(
                glowColor: AppColors.primary,
                enableHoverScale: false,
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                globalMousePosition: globalMousePosition,
                child: Row(
                  children: [
                    Expanded(
                      child: _ModelCard(
                        title: 'Mantenimiento de la fábrica',
                        value: '\$90',
                        subtitle: 'por mes (fijo)',
                        description: 'Mantenimiento de la plataforma. Lo pagas una vez al mes, sin importar cuántos bots tengas.',
                        color: AppColors.primary,
                        icon: Icons.factory,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Punto de equilibrio + prueba gratis
              _PricingHighlights(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destacados: punto de equilibrio (3 bots) y 2 meses gratis
class _PricingHighlights extends StatelessWidget {
  final bool isMobile;

  const _PricingHighlights({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Punto de equilibrio
        GlowBorderCard(
          glowColor: AppColors.success,
          enableHoverScale: false,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.balance, color: AppColors.success, size: 28),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punto de equilibrio',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Con 3 bots activos (cobrando \$30/mes cada uno) alcanzas el punto de equilibrio: tus ingresos cubren el mantenimiento de la fábrica (\$90) y ya no gastas nada de tu bolsillo.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 2 meses gratis
        GlowBorderCard(
          glowColor: AppColors.happy,
          enableHoverScale: false,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.happy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.card_giftcard, color: AppColors.happy, size: 28),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2 meses gratis',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.happy,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prueba la fábrica sin compromiso. Dos meses gratis para que crees tus bots, los integres, alcances el punto de equilibrio y nunca estés en pérdida.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;
  final bool isHighlighted;

  const _ModelCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Tabla de escalabilidad
class _ScalabilityTable extends StatelessWidget {
  final ValueNotifier<Offset>? globalMousePosition;
  
  const _ScalabilityTable({this.globalMousePosition});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    // Mantenimiento fijo \$90/mes; ejemplo: \$30 por bot
    const int maintenanceCost = 90;
    final rows = [
      _ScaleRow(bots: 3, revenue: 90, cost: maintenanceCost, profit: 0, isBreakEven: true),
      _ScaleRow(bots: 10, revenue: 300, cost: maintenanceCost, profit: 210),
      _ScaleRow(bots: 25, revenue: 750, cost: maintenanceCost, profit: 660),
      _ScaleRow(bots: 50, revenue: 1500, cost: maintenanceCost, profit: 1410, isHighlighted: true),
      _ScaleRow(bots: 100, revenue: 3000, cost: maintenanceCost, profit: 2910),
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
                tag: 'Proyección',
                title: 'Escala Tu Negocio',
                subtitle: 'Cuantos más bots, más ingresos. Sin límites.',
              ),

              const SizedBox(height: 48),

              // Tabla con borde brillante
              GlowBorderCard(
                glowColor: AppColors.primary,
                enableHoverScale: false,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                globalMousePosition: globalMousePosition,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          _TableHeader('BOTS', flex: 1),
                          _TableHeader('INGRESOS', flex: 2),
                          _TableHeader('COSTOS', flex: 2),
                          _TableHeader('GANANCIA', flex: 2, isHighlight: true),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.borderGlass,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    
                    // Rows
                    ...rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return Column(
                        children: [
                          _ScaleRowWidget(data: row),
                          if (index < rows.length - 1)
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              color: AppColors.borderGlass.withValues(alpha: 0.3),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Nota informativa con efecto glow
              GlowBorderCard(
                glowColor: AppColors.primary,
                enableHoverScale: false,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                globalMousePosition: globalMousePosition,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Mantenimiento de por vida. Con 53 bots activos tenés un ingreso de \$1.500 mensuales.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHighlight;

  const _TableHeader(this.text, {this.flex = 1, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isHighlight ? AppColors.success : AppColors.textSecondary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ScaleRow {
  final int bots;
  final int revenue;
  final int cost;
  final int profit;
  final bool isHighlighted;
  final bool isBreakEven;

  _ScaleRow({
    required this.bots,
    required this.revenue,
    required this.cost,
    required this.profit,
    this.isHighlighted = false,
    this.isBreakEven = false,
  });
}

class _ScaleRowWidget extends StatelessWidget {
  final _ScaleRow data;

  const _ScaleRowWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final isHighlight = data.isHighlighted || data.isBreakEven;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlight
            ? (data.isBreakEven
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.success.withValues(alpha: 0.08))
            : Colors.transparent,
        borderRadius: isHighlight ? BorderRadius.circular(8) : null,
      ),
      child: Row(
        children: [
          // Bots
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.bots}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Ingresos
          Expanded(
            flex: 2,
            child: Text(
              '\$${data.revenue}/mes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.techCyan,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          // Costos
          Expanded(
            flex: 2,
            child: Text(
              '-\$${data.cost}/mes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          // Ganancia (destacada) o "Punto de equilibrio"
          Expanded(
            flex: 2,
            child: data.isBreakEven
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Text(
                      'Punto de equilibrio',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: data.isHighlighted ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: data.isHighlighted
                          ? Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 2)
                          : null,
                    ),
                    child: Text(
                      '\$${data.profit}/mes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// CTA final — Card premium con efecto wow
class _FactoryCTA extends StatefulWidget {
  final ValueNotifier<Offset>? globalMousePosition;

  const _FactoryCTA({this.globalMousePosition});

  @override
  State<_FactoryCTA> createState() => _FactoryCTAState();
}

class _FactoryCTAState extends State<_FactoryCTA> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
        vertical: AppConstants.spacing4xl,
      ),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go(AppConstants.routeDemo),
            child: GlowBorderCard(
              glowColor: AppColors.primary,
              globalMousePosition: widget.globalMousePosition,
              enableHoverScale: true,
              borderRadius: 20,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 28 : 56,
                vertical: isMobile ? 44 : 56,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tag superior — discreto
                  Text(
                      'TU PRÓXIMA FÁBRICA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                    Text(
                      '¿Listo para construir tu imperio de bots?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12),
                    Text(
                      'Crea tu primer bot en menos de un minuto. Sin código.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 28),
                    GlowButton(
                      text: 'PROBAR DEMO',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.go(AppConstants.routeDemo),
                    ).animate().fadeIn(duration: 400.ms, delay: 240.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
