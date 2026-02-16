import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

/// Provider lazy de inicialización de Rive
/// Se inicializa solo cuando se necesita usar un archivo Rive
final riveInitializationProvider = FutureProvider<void>((ref) async {
  await RiveFile.initialize();
});

/// Provider que verifica si Rive está inicializado
final isRiveReadyProvider = Provider<bool>((ref) {
  final riveInit = ref.watch(riveInitializationProvider);
  return riveInit.hasValue;
});
