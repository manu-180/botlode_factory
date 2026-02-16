import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tutorial_repository_impl.dart';
import '../../domain/entities/tutorial_video.dart';
import '../../domain/repositories/i_tutorial_repository.dart';

/// Resultado de filtrar tutoriales.
class FilterTutorialsResult {
  final List<TutorialVideo> filteredVideos;
  final List<TutorialVideo> availableVideos;
  final List<TutorialVideo> upcomingVideos;

  const FilterTutorialsResult({
    required this.filteredVideos,
    required this.availableVideos,
    required this.upcomingVideos,
  });
}

/// Caso de uso para filtrar tutoriales por categoría.
/// Encapsula la lógica de filtrado y separación por disponibilidad.
class FilterTutorialsUseCase {
  final ITutorialRepository _repository;

  FilterTutorialsUseCase(this._repository);

  /// Ejecuta el filtrado de tutoriales por categoría.
  FilterTutorialsResult execute(String categoryId) {
    final filteredVideos = _repository.filterVideosByCategory(categoryId);
    
    final availableVideos = filteredVideos
        .where((video) => video.isAvailable)
        .toList();
    
    final upcomingVideos = filteredVideos
        .where((video) => !video.isAvailable)
        .toList();

    return FilterTutorialsResult(
      filteredVideos: filteredVideos,
      availableVideos: availableVideos,
      upcomingVideos: upcomingVideos,
    );
  }
}

/// Provider del caso de uso de filtrar tutoriales.
final filterTutorialsUseCaseProvider = Provider<FilterTutorialsUseCase>((ref) {
  final repository = ref.watch(tutorialRepositoryProvider);
  return FilterTutorialsUseCase(repository);
});
