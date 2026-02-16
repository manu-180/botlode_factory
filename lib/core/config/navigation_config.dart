import 'package:flutter/material.dart';

import 'app_constants.dart';

/// Configuración de navegación de la aplicación.
class NavigationConfig {
  NavigationConfig._();

  /// Items de navegación principal.
  /// Orden: home, bot, factory, tutorial
  static const List<NavItem> mainNavItems = [
    NavItem(
      label: 'Home',
      route: AppConstants.routeHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    NavItem(
      label: 'Bot',
      route: AppConstants.routeBot,
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy,
    ),
    NavItem(
      label: 'Factory',
      route: AppConstants.routeFactory,
      icon: Icons.factory_outlined,
      activeIcon: Icons.factory,
    ),
    NavItem(
      label: 'Tutorial',
      route: AppConstants.routeTutorial,
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
    ),
  ];

  /// Item destacado (CTA).
  static const NavItem ctaItem = NavItem(
    label: 'Demo',
    route: AppConstants.routeDemo,
    icon: Icons.rocket_launch_outlined,
    activeIcon: Icons.rocket_launch,
    isHighlighted: true,
  );

  /// Todos los items incluyendo el CTA.
  static List<NavItem> get allItems => [...mainNavItems, ctaItem];

  /// Obtiene el item de navegación para una ruta.
  static NavItem? getItemForRoute(String route) {
    try {
      return allItems.firstWhere((item) => item.route == route);
    } catch (_) {
      return null;
    }
  }

  /// Determina si una ruta es la actual.
  static bool isActiveRoute(String currentPath, String itemRoute) {
    if (itemRoute == AppConstants.routeHome) {
      return currentPath == itemRoute;
    }
    return currentPath.startsWith(itemRoute);
  }
}

/// Modelo para un item de navegación.
class NavItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final bool isHighlighted;

  const NavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
    this.isHighlighted = false,
  });
}
