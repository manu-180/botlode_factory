import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/use_cases/initialize_app_use_case.dart';
import '../services/video_preloader_service.dart';
import 'rive_loader_provider.dart';
import 'shared_preferences_provider.dart';
import 'supabase_provider.dart';

/// Estado de inicialización de la app
class AppInitializationState {
  final bool isRiveReady;
  final bool isSupabaseReady;
  final bool isVideosReady;
  final bool showSplash;

  const AppInitializationState({
    this.isRiveReady = false,
    this.isSupabaseReady = false,
    this.isVideosReady = false,
    this.showSplash = true,
  });

  /// La app está lista cuando Rive y Videos están cargados (no esperamos Supabase)
  bool get isReady => isRiveReady && isVideosReady;

  AppInitializationState copyWith({
    bool? isRiveReady,
    bool? isSupabaseReady,
    bool? isVideosReady,
    bool? showSplash,
  }) {
    return AppInitializationState(
      isRiveReady: isRiveReady ?? this.isRiveReady,
      isSupabaseReady: isSupabaseReady ?? this.isSupabaseReady,
      isVideosReady: isVideosReady ?? this.isVideosReady,
      showSplash: showSplash ?? this.showSplash,
    );
  }
}

/// Notifier que controla la inicialización de la app
/// Usa InitializeAppUseCase para la lógica de inicialización
class AppInitializationNotifier extends StateNotifier<AppInitializationState> {
  final InitializeAppUseCase _initializeAppUseCase;

  AppInitializationNotifier(this._initializeAppUseCase) 
      : super(const AppInitializationState());

  /// Inicia la precarga de recursos usando el use case
  Future<void> preloadResources(WidgetRef ref) async {
    final result = await _initializeAppUseCase.execute(
      initRive: () => ref.read(riveFileLoaderProvider.future),
      initSupabase: () => ref.read(supabaseInitializationProvider.future),
      initVideos: () => VideoPreloaderService().preloadAllVideos(),
      initSharedPreferences: () => ref.read(sharedPreferencesProvider.future),
    );

    state = state.copyWith(
      isRiveReady: result.riveLoaded,
      isSupabaseReady: result.supabaseConnected,
      isVideosReady: result.videosLoaded,
      showSplash: false,
    );
  }
}

/// Provider de inicialización de la app
final appInitializationProvider =
    StateNotifierProvider<AppInitializationNotifier, AppInitializationState>(
  (ref) {
    final useCase = ref.watch(initializeAppUseCaseProvider);
    return AppInitializationNotifier(useCase);
  },
);
