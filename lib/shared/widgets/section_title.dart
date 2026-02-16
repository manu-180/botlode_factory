import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';

/// Título de sección con estilo tecnológico y animaciones
class SectionTitle extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? tag;
  final CrossAxisAlignment alignment;
  final Color accentColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.tag,
    this.alignment = CrossAxisAlignment.center,
    this.accentColor = AppColors.primary,
  });

  @override
  State<SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;

    return Column(
      crossAxisAlignment: widget.alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título principal con barra lateral
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Barra vertical pulsante a la izquierda del título
            PulsingBar(
              color: widget.accentColor,
              width: isMobile ? 3 : 4,
              height: isMobile ? 50 : 65,
            ),
            
            SizedBox(width: isMobile ? 16 : 20),
            
            // Título principal
            Flexible(
              child: Text(
                widget.title,
                textAlign: widget.alignment == CrossAxisAlignment.center
                    ? TextAlign.center
                    : TextAlign.left,
                style: isMobile
                    ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                    : Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),

        const SizedBox(height: 20),

        // Subtítulo
        if (widget.subtitle != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              widget.subtitle!,
              textAlign: widget.alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          
          const SizedBox(height: 16),
        ],

        // Línea decorativa
        Container(
          width: widget.alignment == CrossAxisAlignment.center ? 80 : 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor,
                widget.accentColor.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).scaleX(begin: 0, end: 1),
      ],
    );
  }
}

/// Barra decorativa con animación de parpadeo profesional (público para reutilizar)
class PulsingBar extends StatefulWidget {
  final Color color;
  final double width;
  final double height;

  const PulsingBar({
    super.key,
    required this.color,
    this.width = 3.0,
    this.height = 60.0,
  });

  @override
  State<PulsingBar> createState() => _PulsingBarState();
}

class _PulsingBarState extends State<PulsingBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.4),
        weight: 5,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.color.withValues(alpha: _animation.value),
                  widget.color.withValues(alpha: _animation.value * 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(widget.width / 2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _animation.value * 0.7),
                  blurRadius: 12 * _animation.value,
                  spreadRadius: 1.5 * _animation.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Punto decorativo con animación de parpadeo profesional (público para reutilizar)
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    required this.color,
    this.size = 6.0,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Ciclo de 2 segundos
      vsync: this,
    );

    // Animación que pasa más tiempo en 1.0 (visible) que en 0.3 (semi-transparente)
    _animation = TweenSequence<double>([
      // Fade in rápido
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10, // 10% del tiempo
      ),
      // Mantener brillante (tiempo largo)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70, // 70% del tiempo - MÁS TIEMPO ENCENDIDO
      ),
      // Fade out suave
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15, // 15% del tiempo
      ),
      // Mantener apagado (tiempo corto)
      TweenSequenceItem(
        tween: ConstantTween<double>(0.4),
        weight: 5, // 5% del tiempo - MENOS TIEMPO APAGADO
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (_animation.value * 0.15), // Escala sutil
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: _animation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _animation.value * 0.7),
                    blurRadius: 8 * _animation.value,
                    spreadRadius: 1.5 * _animation.value,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de estadística destacada
class StatHighlight extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatHighlight({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ).createShader(bounds),
          child: Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }
}
