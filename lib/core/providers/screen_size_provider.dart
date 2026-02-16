import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';

/// Enum que representa los diferentes tamaños de pantalla.
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Extensión para facilitar las comprobaciones de tamaño.
extension ScreenSizeExtension on ScreenSize {
  bool get isMobile => this == ScreenSize.mobile;
  bool get isTablet => this == ScreenSize.tablet;
  bool get isDesktop => this == ScreenSize.desktop;
  bool get isMobileOrTablet => isMobile || isTablet;
}

/// Información sobre el tamaño de la pantalla.
class ScreenSizeInfo {
  final ScreenSize size;
  final double width;
  final double height;

  const ScreenSizeInfo({
    required this.size,
    required this.width,
    required this.height,
  });

  bool get isMobile => size.isMobile;
  bool get isTablet => size.isTablet;
  bool get isDesktop => size.isDesktop;
  bool get isMobileOrTablet => size.isMobileOrTablet;

  /// Padding horizontal según el tamaño de pantalla.
  double get horizontalPadding =>
      isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding;

  /// Número de columnas recomendado para grids.
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }
}

/// Determina el tamaño de pantalla basado en el ancho.
ScreenSize _getScreenSize(double width) {
  if (width < AppConstants.tablet) {
    return ScreenSize.mobile;
  } else if (width < AppConstants.desktop) {
    return ScreenSize.tablet;
  }
  return ScreenSize.desktop;
}

/// Provider que observa el tamaño de la ventana.
/// Nota: Este provider requiere que se llame desde un widget que tenga acceso a MediaQuery.
/// Por eso se usa un widget helper ScreenSizeWidget.
class ScreenSizeNotifier extends StateNotifier<ScreenSizeInfo> {
  ScreenSizeNotifier()
      : super(const ScreenSizeInfo(
          size: ScreenSize.desktop,
          width: 1920,
          height: 1080,
        ));

  void updateSize(double width, double height) {
    final newSize = _getScreenSize(width);
    if (state.size != newSize || state.width != width || state.height != height) {
      state = ScreenSizeInfo(
        size: newSize,
        width: width,
        height: height,
      );
    }
  }
}

/// Provider del notifier de tamaño de pantalla.
final screenSizeProvider =
    StateNotifierProvider<ScreenSizeNotifier, ScreenSizeInfo>((ref) {
  return ScreenSizeNotifier();
});

/// Widget que actualiza automáticamente el tamaño de pantalla.
/// Debe envolver el contenido principal de la app.
class ScreenSizeObserver extends ConsumerWidget {
  final Widget child;

  const ScreenSizeObserver({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    
    // Actualizar el provider con el nuevo tamaño
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenSizeProvider.notifier).updateSize(
        mediaQuery.size.width,
        mediaQuery.size.height,
      );
    });

    return child;
  }
}

/// Helper para obtener el tamaño de pantalla sin provider.
/// Útil en widgets que no usan Riverpod.
class ScreenSizeHelper {
  final BuildContext context;

  ScreenSizeHelper(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  
  ScreenSize get size => _getScreenSize(width);
  
  bool get isMobile => size.isMobile;
  bool get isTablet => size.isTablet;
  bool get isDesktop => size.isDesktop;
  
  double get horizontalPadding =>
      isMobile ? AppConstants.mobilePadding : AppConstants.desktopPadding;
  
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }
}
