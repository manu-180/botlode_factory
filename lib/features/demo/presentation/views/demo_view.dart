import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/footer.dart';
import '../../../../shared/widgets/glow_border_card.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../providers/demo_provider.dart';
import '../widgets/bot_creator/bot_creator_widget.dart';
import '../widgets/demo_bot_card.dart';
import '../widgets/demo_chat_panel.dart';
import '../widgets/video_hero_demo.dart';

/// Vista principal del Demo interactivo
class DemoView extends ConsumerStatefulWidget {
  const DemoView({super.key});

  @override
  ConsumerState<DemoView> createState() => _DemoViewState();
}

class _DemoViewState extends ConsumerState<DemoView> {
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    // ⚡ OPTIMIZACIÓN: Inicializar lazy loading de bots cuando se monta la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(demoProvider.notifier).ensureInitialized();
    });
  }

  @override
  void dispose() {
    _mousePos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final demoState = ref.watch(demoProvider);

    // ✅ NO usar MouseRegion aquí - el MainLayout ya maneja el tracking global
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero con video
          const VideoHeroDemo(),
          // Cubre la unión hero/contenido para evitar línea clara al hacer scroll
          Container(height: 8, width: double.infinity, color: AppColors.background),

          // Contenido principal
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding,
              vertical: AppConstants.spacing3xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: isMobile
                    ? _buildMobileLayout(demoState)
                    : _buildDesktopLayout(demoState),
              ),
            ),
          ),

          // Footer al final del scroll
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(DemoState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel izquierdo: Solo el creador
        Expanded(
          flex: 1,
          child: const BotCreatorWidget(),
        ),

        const SizedBox(width: 32),

        // Panel derecho: Chat + Grid de bots debajo
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Chat panel con altura fija (padding para que el glow del borde no se recorte)
              SizedBox(
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: state.selectedBot != null
                      ? DemoChatPanel(bot: state.selectedBot!)
                      : const _EmptyChatState(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Grid de bots debajo del chat
              _BotsGrid(bots: state.bots),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(DemoState state) {
    return Column(
      children: [
        const BotCreatorWidget(),
        const SizedBox(height: 32),
        if (state.selectedBot != null) ...[
          // Chat panel primero en mobile (padding para que el glow no se recorte)
          SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: DemoChatPanel(bot: state.selectedBot!),
            ),
          ),
          const SizedBox(height: 32),
        ],
        // Grid de bots debajo del chat (o debajo del creador si no hay bot seleccionado)
        _BotsGrid(bots: state.bots),
      ],
    );
  }
}

// BotCreator ha sido refactorizado en widgets separados:
// - bot_creator/bot_creator_widget.dart
// - bot_creator/template_selector.dart
// - bot_creator/color_picker_section.dart
// - bot_creator/bot_creation_form.dart

/// Grid de bots creados
class _BotsGrid extends ConsumerWidget {
  final List<DemoBotEntity> bots;

  const _BotsGrid({required this.bots});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bots.isEmpty) {
      return _EmptyBotsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TUS BOTS (${bots.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: bots.asMap().entries.map((entry) {
            return SizedBox(
              width: 180,
              child: DemoBotCard(
                bot: entry.value,
                delay: entry.key * 100,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmptyBotsState extends StatefulWidget {
  @override
  State<_EmptyBotsState> createState() => _EmptyBotsStateState();
}

class _EmptyBotsStateState extends State<_EmptyBotsState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderGlass,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Icono flotante con múltiples capas
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo exterior pulsante
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Círculo medio
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: FaIcon(
                            FontAwesomeIcons.robot,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Título con gradiente
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.textPrimary,
                    AppColors.primary,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Aún no tienes bots',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              
              // Descripción
              Text(
                'Crea tu primer bot usando el formulario de la izquierda\ny comienza a experimentar con la IA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Indicador visual con pasos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(context, '1', 'Elige plantilla'),
                  _buildStepArrow(),
                  _buildStepIndicator(context, '2', 'Personaliza'),
                  _buildStepArrow(),
                  _buildStepIndicator(context, '3', 'Crea bot'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(BuildContext context, String number, String label) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }

  Widget _buildStepArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      child: Icon(
        Icons.arrow_forward,
        size: 16,
        color: AppColors.primary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _EmptyChatState extends StatefulWidget {
  const _EmptyChatState();
  
  @override
  State<_EmptyChatState> createState() => _EmptyChatStateState();
}

class _EmptyChatStateState extends State<_EmptyChatState>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particlesController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Controlador principal para el icono
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    // Controlador para partículas flotantes
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Generar partículas
    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle(
        delay: i * 0.3,
        duration: 3.0 + (i % 3),
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlowBorderCard(
      enableHoverScale: false,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: Stack(
          children: [
            // Partículas flotantes de fondo
            ...List.generate(_particles.length, (index) {
              return AnimatedBuilder(
                animation: _particlesController,
                builder: (context, child) {
                  final particle = _particles[index];
                  final progress = (_particlesController.value + particle.delay) % 1.0;
                  
                  return Positioned(
                    left: particle.startX * MediaQuery.of(context).size.width,
                    top: progress * 600,
                    child: Opacity(
                      opacity: (1 - progress) * 0.4,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.4),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Contenido principal
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono animado con múltiples efectos
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow exterior animado
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: _glowAnimation.value * 0.3,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                // Círculo con gradiente
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.3),
                                        AppColors.primary.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: _glowAnimation.value * 0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 48,
                                      color: AppColors.primary.withValues(
                                        alpha: _glowAnimation.value,
                                      ),
                                    ),
                                  ),
                                ),
                                // Anillo exterior rotatorio
                                Positioned.fill(
                                  child: Transform.rotate(
                                    angle: _mainController.value * 6.28,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Título con efecto shimmer
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.textPrimary,
                          AppColors.primary,
                          AppColors.textPrimary,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_mainController.value * 3.14),
                      ).createShader(bounds),
                      child: Text(
                        'Selecciona un bot para chatear',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    Text(
                      'Crea un bot y haz clic en él para iniciar\nuna conversación interactiva',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Indicadores de características
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeaturePill(context, Icons.psychology, 'IA Avanzada'),
                        _buildFeaturePill(context, Icons.speed, 'Respuestas rápidas'),
                        _buildFeaturePill(context, Icons.auto_awesome, 'Personalizable'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// Clase para partículas flotantes
class _Particle {
  final double delay;
  final double duration;
  final double startX;
  final double size;

  _Particle({
    required this.delay,
    required this.duration,
  })  : startX = 0.1 + (delay * 0.7) % 0.8,
        size = 4 + (delay * 6) % 8;
}

/// Card de notificación animada
class _NotificationCard extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _NotificationCard({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación principal
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    // Animar salida antes de desaparecer
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surface,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // Sombra sutil y profesional
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icono limpio
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Texto
                        Expanded(
                          child: Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
