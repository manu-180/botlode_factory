import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import 'rive_initialization_provider.dart';

/// Provider que carga el archivo Rive del robot completo (catbotlode.riv)
/// Inicializa Rive solo cuando se necesita (lazy)
final riveFileLoaderProvider = FutureProvider<RiveFile>((ref) async {
  // Inicializar Rive primero (solo se ejecuta una vez)
  await ref.watch(riveInitializationProvider.future);
  
  // Luego cargar el archivo
  final data = await rootBundle.load('assets/animations/catbotlode.riv');
  return RiveFile.import(data);
});

/// Provider que carga el archivo Rive de la cabeza del bot (cabezabot.riv)
/// Inicializa Rive solo cuando se necesita (lazy)
final riveHeadFileLoaderProvider = FutureProvider<RiveFile>((ref) async {
  // Inicializar Rive primero (solo se ejecuta una vez)
  await ref.watch(riveInitializationProvider.future);
  
  // Luego cargar el archivo
  final data = await rootBundle.load('assets/animations/cabezabot.riv');
  return RiveFile.import(data);
});

/// Estado del Rive Avatar
class RiveAvatarState {
  final RiveFile? file;
  final bool isLoading;
  final String? error;

  const RiveAvatarState({
    this.file,
    this.isLoading = false,
    this.error,
  });

  RiveAvatarState copyWith({
    RiveFile? file,
    bool? isLoading,
    String? error,
  }) {
    return RiveAvatarState(
      file: file ?? this.file,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
