import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import '../../shared/widgets/main_layout.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/factory/presentation/views/factory_view.dart';
import '../../features/tutorial/presentation/views/tutorial_view.dart';
import '../../features/demo/presentation/views/demo_view.dart';
import '../../features/bot/presentation/views/bot_view.dart';

/// Provider del router principal
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeHome,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            name: 'home',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const HomeView(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeBot,
            name: 'bot',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const BotView(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeFactory,
            name: 'factory',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const FactoryView(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeTutorial,
            name: 'tutorial',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const TutorialView(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeDemo,
            name: 'demo',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state,
              const DemoView(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('VOLVER AL INICIO'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Construye una página con transición fade
CustomTransitionPage _buildPageWithTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppConstants.durationNormal,
    reverseTransitionDuration: AppConstants.durationFast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
