import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../mappers/bot_ui_mapper.dart';
import '../providers/demo_provider.dart';

/// Card de un bot de demo con diseño ULTRA PROFESIONAL
class DemoBotCard extends ConsumerStatefulWidget {
  final DemoBotEntity bot;
  final int delay;

  const DemoBotCard({
    super.key,
    required this.bot,
    this.delay = 0,
  });

  @override
  ConsumerState<DemoBotCard> createState() => _DemoBotCardState();
}

class _DemoBotCardState extends ConsumerState<DemoBotCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isMounted = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Dar tiempo al widget para montarse completamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isMounted = true);
        // Iniciar shimmer effect solo una vez al aparecer
        _shimmerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBotId =
        ref.watch(demoProvider.select((s) => s.selectedBotId));
    final isSelected = selectedBotId == widget.bot.id;
    final botColor = BotUIMapper.toFlutterColor(widget.bot.color);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0 && _isMounted;

        return MouseRegion(
          onEnter:
              hasValidSize ? (_) => setState(() => _isHovered = true) : null,
          onExit:
              hasValidSize ? (_) => setState(() => _isHovered = false) : null,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () =>
                ref.read(demoProvider.notifier).selectBot(widget.bot.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 180,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -8.0 : 0.0)
                ..scale(_isHovered ? 1.02 : 1.0),
              transformAlignment: Alignment.center,
              child: Stack(
                children: [
                  // Card principal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // Glassmorphism: seleccionado = color del bot; no seleccionado = gris atenuado
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                botColor.withValues(alpha: 0.15),
                                botColor.withValues(alpha: 0.08),
                                AppColors.surface.withValues(alpha: 0.9),
                              ]
                            : [
                                AppColors.surface.withValues(alpha: 0.6),
                                AppColors.surface.withValues(alpha: 0.5),
                                AppColors.background.withValues(alpha: 0.7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        width: isSelected ? 2 : 1,
                        color: isSelected
                            ? botColor
                            : (_isHovered
                                ? botColor.withValues(alpha: 0.5)
                                : AppColors.borderGlass.withValues(alpha: 0.7)),
                      ),
                      boxShadow: [
                        // Sombra profunda
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        // Glow interior solo cuando está seleccionado (no en hover si no seleccionado)
                        if (isSelected)
                          BoxShadow(
                            color: botColor.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: -5,
                            offset: const Offset(0, -5),
                          ),
                        if (!isSelected && _isHovered)
                          BoxShadow(
                            color: botColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: -2,
                            offset: const Offset(0, -2),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shimmer effect al aparecer (ignorar eventos de puntero)
                        if (_isMounted)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return ShaderMask(
                                    blendMode: BlendMode.srcATop,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent,
                                          botColor.withValues(alpha: 0.3 * (1 - _shimmerController.value)),
                                          Colors.transparent,
                                        ],
                                        stops: [
                                          _shimmerController.value - 0.3,
                                          _shimmerController.value,
                                          _shimmerController.value + 0.3,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.white.withValues(alpha: 0.2),
                                            Colors.white.withValues(alpha: 0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        
                        // Contenido
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar con efecto de pulso
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Anillo pulsante de fondo
                                if (isSelected)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: botColor.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                  )
                                      .animate(onPlay: (c) => c.repeat())
                                      .scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1.1, 1.1),
                                        duration: 2000.ms,
                                      )
                                      .fadeIn(duration: 500.ms)
                                      .then()
                                      .fadeOut(duration: 1500.ms),
                                
                                // Avatar
                                RiveBotAvatar(
                                  size: 90,
                                  useHead: true,
                                  glowColor: botColor,
                                  enableMouseTracking: isSelected && _isMounted,
                                ),
                                
                                // Badge de mensajes con bounce
                                if (widget.bot.messages.isNotEmpty)
                                  Positioned(
                                    right: -5,
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            botColor,
                                            botColor.withValues(alpha: 0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.background,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: botColor.withValues(alpha: 0.6),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${widget.bot.messages.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.background,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    )
                                        .animate()
                                        .scale(
                                          begin: const Offset(0, 0),
                                          end: const Offset(1, 1),
                                          duration: 400.ms,
                                          curve: Curves.elasticOut,
                                        ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Nombre: seleccionado = color del bot; no seleccionado = gris atenuado
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: isSelected
                                      ? [
                                          botColor,
                                          botColor.withValues(alpha: 0.8),
                                        ]
                                      : [
                                          AppColors.textSecondary,
                                          AppColors.textTertiary,
                                        ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                widget.bot.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón eliminar con efecto especial
                  if (_isMounted)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IgnorePointer(
                        ignoring: !_isHovered,
                        child: AnimatedScale(
                          scale: _isHovered ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(demoProvider.notifier).removeBot(widget.bot.id);
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.error,
                                      Color(0xFFD32F2F),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.error.withValues(alpha: 0.6),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    )
        // 🎭 ANIMACIÓN DE ENTRADA ESPECTACULAR
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 1.0,
          end: 0,
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutBack,
        )
        .rotate(
          begin: -0.1,
          end: 0,
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutCubic,
        )
        // Efecto de brillo final
        .shimmer(
          duration: 1200.ms,
          delay: Duration(milliseconds: widget.delay + 400),
          color: BotUIMapper.toFlutterColor(widget.bot.color).withValues(alpha: 0.3),
        );
  }
}
