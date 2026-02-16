import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/demo_bot_entity.dart';
import '../models/demo_bot_model.dart';

/// Servicio para persistir bots de demo localmente usando SharedPreferences.
class DemoStorageService {
  static const String _botsKey = 'demo_bots';
  static const String _counterKey = 'demo_bot_counter';

  final SharedPreferences _prefs;

  DemoStorageService(this._prefs);

  /// Guarda la lista de bots
  Future<void> saveBots(List<DemoBotEntity> bots) async {
    try {
      final botsJson = bots
          .map((bot) => DemoBotModel.fromEntity(bot).toJson())
          .toList();
      final jsonString = jsonEncode(botsJson);
      await _prefs.setString(_botsKey, jsonString);
    } catch (e) {
      // Silenciosamente falla si hay error de serialización
      print('Error al guardar bots: $e');
    }
  }

  /// Carga la lista de bots
  List<DemoBotEntity> loadBots() {
    try {
      final jsonString = _prefs.getString(_botsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => DemoBotModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      // Si hay error de deserialización, retorna lista vacía
      print('Error al cargar bots: $e');
      return [];
    }
  }

  /// Guarda el contador de bots
  Future<void> saveCounter(int counter) async {
    await _prefs.setInt(_counterKey, counter);
  }

  /// Carga el contador de bots
  int loadCounter() {
    return _prefs.getInt(_counterKey) ?? 0;
  }

  /// Limpia todos los datos del demo
  Future<void> clearAll() async {
    await _prefs.remove(_botsKey);
    await _prefs.remove(_counterKey);
  }
}

/// Provider del servicio de almacenamiento
final demoStorageServiceProvider = Provider<DemoStorageService>((ref) {
  throw UnimplementedError('DemoStorageService debe ser inicializado en main.dart');
});
