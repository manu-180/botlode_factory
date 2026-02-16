import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/config/app_colors.dart';

/// Splash screen inicial que se muestra mientras se cargan recursos
/// Diseño inspirado en la pantalla de arranque del sistema
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo BotLode
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'BotLode',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: Colors.white,
                    ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 16),

            // Subtítulo
            Text(
              'FÁBRICA DE BOTS IA',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 80),

            // Indicador de carga circular
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).fadeIn(
                  duration: 600.ms,
                  delay: 400.ms,
                ),

            const SizedBox(height: 24),

            // Texto de estado
            Text(
              'INICIANDO SISTEMA...',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 2,
                  ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
