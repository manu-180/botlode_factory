import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

/// Fallback visual cuando el video no puede cargar (ej. sin WiFi).
/// Muestra una imagen poster si existe [posterAssetPath], o un fondo sci-fi con icono.
/// Para usar el primer frame del video, exporta un frame como JPG/PNG y pásalo en [posterAssetPath].
class VideoPosterFallback extends StatelessWidget {
  final String? posterAssetPath;
  final Color? accentColor;

  const VideoPosterFallback({
    super.key,
    this.posterAssetPath,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (posterAssetPath != null && posterAssetPath!.isNotEmpty) {
      return Image.asset(
        posterAssetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildSciFiPlaceholder(),
      );
    }
    return _buildSciFiPlaceholder();
  }

  Widget _buildSciFiPlaceholder() {
    final color = accentColor ?? AppColors.primary;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surface.withValues(alpha: 0.4),
            AppColors.background,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Línea de acento sutil
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.0),
                    color.withValues(alpha: 0.5),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.videocam_outlined,
              size: 72,
              color: color.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
