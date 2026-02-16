import 'package:flutter/material.dart';

import '../../core/config/app_constants.dart';
import '../../core/providers/screen_size_provider.dart';

/// Contenedor responsive que aplica automáticamente padding y constraints
/// según el tamaño de la pantalla.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? desktopPadding;
  final bool center;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.mobilePadding,
    this.desktopPadding,
    this.center = true,
    this.backgroundColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeHelper(context);
    
    final effectivePadding = padding ??
        (screen.isMobile
            ? (mobilePadding ?? EdgeInsets.symmetric(horizontal: AppConstants.mobilePadding))
            : (desktopPadding ?? EdgeInsets.symmetric(horizontal: AppConstants.desktopPadding)));

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? AppConstants.maxContentWidth,
      ),
      child: child,
    );

    if (center) {
      content = Center(child: content);
    }

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      color: decoration == null ? backgroundColor : null,
      decoration: decoration,
      child: content,
    );
  }
}

/// Versión del container con padding vertical adicional para secciones.
class ResponsiveSection extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double verticalPadding;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  const ResponsiveSection({
    super.key,
    required this.child,
    this.maxWidth,
    this.verticalPadding = AppConstants.spacing4xl,
    this.backgroundColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeHelper(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screen.horizontalPadding,
        vertical: verticalPadding,
      ),
      color: decoration == null ? backgroundColor : null,
      decoration: decoration,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? AppConstants.maxContentWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Builder que proporciona información sobre el tamaño de pantalla.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSizeHelper screen) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, ScreenSizeHelper(context));
  }
}

/// Widget que muestra diferentes children según el tamaño de pantalla.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeHelper(context);

    if (screen.isDesktop) {
      return desktop;
    } else if (screen.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
