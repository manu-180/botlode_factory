import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/use_cases/filter_tutorials_use_case.dart';
import '../../application/use_cases/get_tutorials_use_case.dart';
import '../../domain/entities/tutorial_video.dart';

/// Estado del módulo de tutoriales.
class TutorialState {
  final String selectedCategory;
  final List<TutorialVideo> allVideos;
  final List<TutorialCategory> categories;
  final List<TutorialVideo> filteredVideos;
  final List<TutorialVideo> availableVideos;
  final List<TutorialVideo> upcomingVideos;

  const TutorialState({
    required this.selectedCategory,
    required this.allVideos,
    required this.categories,
    required this.filteredVideos,
    required this.availableVideos,
    required this.upcomingVideos,
  });

  TutorialState copyWith({
    String? selectedCategory,
    List<TutorialVideo>? allVideos,
    List<TutorialCategory>? categories,
    List<TutorialVideo>? filteredVideos,
    List<TutorialVideo>? availableVideos,
    List<TutorialVideo>? upcomingVideos,
  }) {
    return TutorialState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      allVideos: allVideos ?? this.allVideos,
      categories: categories ?? this.categories,
      filteredVideos: filteredVideos ?? this.filteredVideos,
      availableVideos: availableVideos ?? this.availableVideos,
      upcomingVideos: upcomingVideos ?? this.upcomingVideos,
    );
  }
}

/// Notifier para gestionar el estado de los tutoriales.
/// Solo gestiona estado de UI y delega toda la lógica de negocio a los use cases.
class TutorialNotifier extends StateNotifier<TutorialState> {
  final GetTutorialsUseCase _getTutorialsUseCase;
  final FilterTutorialsUseCase _filterTutorialsUseCase;

  TutorialNotifier(this._getTutorialsUseCase, this._filterTutorialsUseCase)
      : super(
          const TutorialState(
            selectedCategory: 'todos',
            allVideos: [],
            categories: [],
            filteredVideos: [],
            availableVideos: [],
            upcomingVideos: [],
          ),
        ) {
    _loadTutorials();
  }

  /// Carga los tutoriales iniciales.
  void _loadTutorials() {
    final result = _getTutorialsUseCase.execute();
    final filterResult = _filterTutorialsUseCase.execute('todos');

    state = state.copyWith(
      allVideos: result.allVideos,
      categories: result.categories,
      filteredVideos: filterResult.filteredVideos,
      availableVideos: filterResult.availableVideos,
      upcomingVideos: filterResult.upcomingVideos,
    );
  }

  /// Cambia la categoría seleccionada.
  void selectCategory(String category) {
    final filterResult = _filterTutorialsUseCase.execute(category);

    state = state.copyWith(
      selectedCategory: category,
      filteredVideos: filterResult.filteredVideos,
      availableVideos: filterResult.availableVideos,
      upcomingVideos: filterResult.upcomingVideos,
    );
  }
}

/// Provider del notifier de tutoriales.
final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  final getTutorialsUseCase = ref.watch(getTutorialsUseCaseProvider);
  final filterTutorialsUseCase = ref.watch(filterTutorialsUseCaseProvider);
  return TutorialNotifier(getTutorialsUseCase, filterTutorialsUseCase);
});
