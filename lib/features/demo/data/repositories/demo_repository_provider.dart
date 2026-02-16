import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../domain/repositories/i_demo_repository.dart';
import '../data_sources/demo_local_data_source.dart';
import '../data_sources/demo_remote_data_source.dart';
import '../models/demo_bot_model.dart';
import 'demo_repository_impl.dart';

/// Provider del data source remoto (Supabase)
/// Maneja el async de Supabase con un placeholder vacío mientras se inicializa
final demoRemoteDataSourceProvider = Provider<IDemoRemoteDataSource>((ref) {
  final clientAsync = ref.watch(supabaseClientProvider);
  
  return clientAsync.when(
    data: (client) {
      if (client == null) {
        debugPrint('🔴 demoRemoteDataSourceProvider: Cliente es NULL - retornando empty data source');
        return _EmptyRemoteDataSource(isLoading: false);
      }
      debugPrint('🟢 demoRemoteDataSourceProvider: Cliente disponible - retornando data source real');
      return DemoRemoteDataSource(client);
    },
    loading: () {
      debugPrint('🟡 demoRemoteDataSourceProvider: En estado LOADING - retornando empty data source');
      return _EmptyRemoteDataSource(isLoading: true);
    },
    error: (error, stack) {
      debugPrint('🔴 demoRemoteDataSourceProvider: ERROR - $error');
      return _EmptyRemoteDataSource(isLoading: false);
    },
  );
});

/// Provider del repositorio de demo.
/// Se inicializa de forma lazy cuando se necesita SharedPreferences.
final demoRepositoryProvider = Provider<IDemoRepository>((ref) {
  // Iniciar la carga de SharedPreferences en background
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  
  // Obtener data sources
  final remoteDataSource = ref.watch(demoRemoteDataSourceProvider);
  
  // Crear data source local cuando SharedPreferences esté listo
  final localDataSource = prefsAsync.when(
    data: (prefs) => DemoLocalDataSource(prefs),
    loading: () => _EmptyLocalDataSource(),
    error: (_, __) => _EmptyLocalDataSource(),
  );
  
  return DemoRepositoryImpl(remoteDataSource, localDataSource);
});

/// Data source remoto vacío para usar mientras Supabase se inicializa
class _EmptyRemoteDataSource implements IDemoRemoteDataSource {
  final bool _isLoading;
  
  _EmptyRemoteDataSource({bool isLoading = false}) : _isLoading = isLoading;
  
  @override
  Future<DemoBotModel?> createBot(DemoBotModel bot) async => null;
  
  @override
  Future<BotBrainResponse?> sendMessage({
    required String botId,
    required String message,
    required String sessionId,
    required String chatId,
    String? botName,
    String? systemPrompt,
  }) async => null;
  
  @override
  Future<bool> deleteBot(String botId) async => false;
  
  @override
  Future<List<DemoBotModel>> getBots() async => [];
  
  @override
  Future<DemoBotModel?> getBotById(String id) async => null;
  
  @override
  bool get isAvailable => false;
  
  @override
  bool get isLoading => _isLoading;
}

/// Data source local vacío para usar mientras SharedPreferences se inicializa
class _EmptyLocalDataSource implements IDemoLocalDataSource {
  @override
  Future<void> saveBots(bots) async {}
  
  @override
  List<DemoBotModel> loadBots() => [];
  
  @override
  Future<void> saveCounter(int counter) async {}
  
  @override
  int loadCounter() => 0;
  
  @override
  Future<void> clearAll() async {}
}
