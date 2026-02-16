import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_repository_provider.dart';
import 'persist_bots_use_case.dart';

/// Provider del caso de uso para persistir bots
final persistBotsUseCaseProvider = Provider<PersistBotsUseCase>((ref) {
  final repository = ref.watch(demoRepositoryProvider);
  return PersistBotsUseCase(repository);
});
