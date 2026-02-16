import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dtos/demo_bot_local_dto.dart';
import '../models/demo_bot_model.dart';

/// Data source local para operaciones con SharedPreferences.
/// Abstrae el acceso a SharedPreferences del repositorio.
abstract class IDemoLocalDataSource {
  /// Guarda la lista de bots localmente.
  Future<void> saveBots(List<DemoBotModel> bots);

  /// Carga la lista de bots desde almacenamiento local.
  List<DemoBotModel> loadBots();

  /// Guarda el contador de IDs locales.
  Future<void> saveCounter(int counter);

  /// Carga el contador de IDs locales.
  int loadCounter();

  /// Limpia todos los datos locales.
  Future<void> clearAll();
}

/// Implementación del data source local usando SharedPreferences.
/// Usa DTOs específicos para local storage para serialización/deserialización.
class DemoLocalDataSource implements IDemoLocalDataSource {
  static const String _botsKey = 'demo_bots';
  static const String _counterKey = 'demo_bot_counter';

  final SharedPreferences _prefs;

  DemoLocalDataSource(this._prefs);

  @override
  Future<void> saveBots(List<DemoBotModel> bots) async {
    try {
      final botsJson = bots
          .map((bot) => DemoBotLocalDTO.fromModel(bot).toJson())
          .toList();
      final jsonString = jsonEncode(botsJson);
      await _prefs.setString(_botsKey, jsonString);
    } catch (e) {
      debugPrint('Error al guardar bots localmente: $e');
    }
  }

  @override
  List<DemoBotModel> loadBots() {
    try {
      final jsonString = _prefs.getString(_botsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => DemoBotLocalDTO.fromJson(json as Map<String, dynamic>).toModel())
          .toList();
    } catch (e) {
      debugPrint('Error al cargar bots localmente: $e');
      return [];
    }
  }

  @override
  Future<void> saveCounter(int counter) async {
    await _prefs.setInt(_counterKey, counter);
  }

  @override
  int loadCounter() {
    return _prefs.getInt(_counterKey) ?? 0;
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_botsKey);
    await _prefs.remove(_counterKey);
  }
}
