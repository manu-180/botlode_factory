import '../entities/tutorial_video.dart';

/// Interfaz abstracta del repositorio de tutoriales.
/// Define el contrato para acceder a los datos de tutoriales.
abstract class ITutorialRepository {
  /// Obtiene todos los videos de tutoriales.
  List<TutorialVideo> getAllVideos();

  /// Obtiene todas las categorías disponibles.
  List<TutorialCategory> getAllCategories();

  /// Filtra videos por categoría.
  List<TutorialVideo> filterVideosByCategory(String categoryId);

  /// Filtra videos por disponibilidad.
  List<TutorialVideo> filterVideosByAvailability(bool isAvailable);
}
