import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider lazy de SharedPreferences
/// Se inicializa solo cuando se necesita (no bloquea el main)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider síncrono que espera a que SharedPreferences esté listo
/// Úsalo en widgets que necesitan acceso directo
final sharedPreferencesAsyncProvider = Provider<AsyncValue<SharedPreferences>>((ref) {
  return ref.watch(sharedPreferencesProvider);
});
