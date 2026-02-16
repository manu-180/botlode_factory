import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tutorial_repository_impl.dart';
import '../../domain/entities/tutorial_video.dart';
import '../../domain/repositories/i_tutorial_repository.dart';

/// Resultado de obtener tutoriales.
class GetTutorialsResult {
  final List<TutorialVideo> allVideos;
  final List<TutorialCategory> categories;

  const GetTutorialsResult({
    required this.allVideos,
    required this.categories,
  });
}

/// Caso de uso para obtener todos los tutoriales.
/// Encapsula la lógica de carga de tutoriales y categorías.
class GetTutorialsUseCase {
  final ITutorialRepository _repository;

  GetTutorialsUseCase(this._repository);

  /// Ejecuta la obtención de tutoriales.
  GetTutorialsResult execute() {
    final allVideos = _repository.getAllVideos();
    final categories = _repository.getAllCategories();

    return GetTutorialsResult(
      allVideos: allVideos,
      categories: categories,
    );
  }
}

/// Provider del caso de uso de obtener tutoriales.
final getTutorialsUseCaseProvider = Provider<GetTutorialsUseCase>((ref) {
  final repository = ref.watch(tutorialRepositoryProvider);
  return GetTutorialsUseCase(repository);
});
