import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/tutorial_video.dart';
import '../../domain/repositories/i_tutorial_repository.dart';
import '../tutorial_videos_data.dart';

/// Implementación concreta del repositorio de tutoriales.
/// Usa datos estáticos de TutorialVideosData.
class TutorialRepositoryImpl implements ITutorialRepository {
  @override
  List<TutorialVideo> getAllVideos() {
    return TutorialVideosData.videos;
  }

  @override
  List<TutorialCategory> getAllCategories() {
    return TutorialVideosData.categories;
  }

  @override
  List<TutorialVideo> filterVideosByCategory(String categoryId) {
    if (categoryId == 'todos') {
      return TutorialVideosData.videos;
    }
    return TutorialVideosData.videos
        .where((video) => video.category == categoryId)
        .toList();
  }

  @override
  List<TutorialVideo> filterVideosByAvailability(bool isAvailable) {
    return TutorialVideosData.videos
        .where((video) => video.isAvailable == isAvailable)
        .toList();
  }
}

/// Provider del repositorio de tutoriales.
final tutorialRepositoryProvider = Provider<ITutorialRepository>((ref) {
  return TutorialRepositoryImpl();
});
