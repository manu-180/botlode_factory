import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import '../router/app_router.dart';

/// Servicio de navegación que abstrae GoRouter.
/// Facilita la navegación desde cualquier parte de la app sin depender del contexto.
class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  /// Navega a una ruta.
  void go(String route) {
    _router.go(route);
  }

  /// Navega a una ruta con reemplazo.
  void goReplace(String route) {
    _router.replace(route);
  }

  /// Navega hacia atrás.
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(AppConstants.routeHome);
    }
  }

  /// Push a una ruta.
  void push(String route) {
    _router.push(route);
  }

  /// Push a una ruta con parámetros extras.
  void pushWithExtra(String route, Object extra) {
    _router.push(route, extra: extra);
  }

  /// Obtiene la ruta actual.
  String get currentRoute {
    final state = _router.routerDelegate.currentConfiguration;
    return state.uri.toString();
  }

  /// Verifica si la ruta actual es la indicada.
  bool isCurrentRoute(String route) {
    final current = currentRoute;
    if (route == AppConstants.routeHome) {
      return current == route;
    }
    return current.startsWith(route);
  }

  /// Navega a las rutas principales.
  void goHome() => go(AppConstants.routeHome);
  void goBot() => go(AppConstants.routeBot);
  void goFactory() => go(AppConstants.routeFactory);
  void goTutorial() => go(AppConstants.routeTutorial);
  void goDemo() => go(AppConstants.routeDemo);

  /// Verifica si puede ir hacia atrás.
  bool canGoBack() => _router.canPop();
}

/// Provider del servicio de navegación.
final navigationServiceProvider = Provider<NavigationService>((ref) {
  final router = ref.watch(appRouterProvider);
  return NavigationService(router);
});

/// Extension para facilitar la navegación desde BuildContext.
extension NavigationExtension on BuildContext {
  /// Navega a una ruta usando GoRouter.
  void navigate(String route) => go(route);

  /// Navega hacia atrás.
  void navigateBack() {
    if (canPop()) {
      pop();
    } else {
      go(AppConstants.routeHome);
    }
  }

  /// Navega a las rutas principales.
  void navigateHome() => go(AppConstants.routeHome);
  void navigateBot() => go(AppConstants.routeBot);
  void navigateFactory() => go(AppConstants.routeFactory);
  void navigateTutorial() => go(AppConstants.routeTutorial);
  void navigateDemo() => go(AppConstants.routeDemo);
}
